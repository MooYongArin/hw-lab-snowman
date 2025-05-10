module sd_card_reader (
    input wire clk,              // System clock (100 MHz)
    input wire rst_n,            // Active-low reset
    input wire miso,             // SPI MISO from SD card
    input wire start_read,       // Start read request from controller
    input wire [31:0] sector_addr, // Starting sector address
    input wire [7:0] block_count, // Number of 512-byte blocks to read (1-255, 0 invalid)
    output reg cs_n,             // SPI chip select (active low)
    output reg sck,              // SPI clock (400 kHz init, 12.5 MHz read)
    output reg mosi,             // SPI MOSI to SD card
    output reg [7:0] data_out,   // 8-bit data to controller
    output reg data_valid,       // Data valid signal
    output reg busy,             // Module busy
    output reg error,             // Error flag

    output reg [7:0] debug_led
);

    // Clock divider parameters
    localparam CLK_FREQ = 100_000_000; // 100 MHz
    localparam SCK_INIT_FREQ = 400_000; // 400 kHz for initialization
    localparam SCK_READ_FREQ = 12_500_000; // 12.5 MHz for reading
    localparam INIT_DIV = CLK_FREQ / (2 * SCK_INIT_FREQ); // 125
    localparam READ_DIV = CLK_FREQ / (2 * SCK_READ_FREQ); // 4

    // State machine states
    localparam [3:0]
        S_INIT_POWER = 0,    // Power-up delay (>74 clocks)
        S_INIT_CMD0 = 1,     // Send CMD0 (go idle)
        S_INIT_CMD8 = 2,     // Send CMD8 (voltage check)
        S_INIT_CMD55 = 3,    // Send CMD55 (app command)
        S_INIT_ACMD41 = 4,   // Send ACMD41 (initialize)
        S_INIT_CMD16 = 5,    // Send CMD16 (set block length)
        S_IDLE = 6,          // Wait for read request
        S_SEND_CMD17 = 7,    // Send CMD17 (read single block)
        S_WAIT_TOKEN = 8,    // Wait for data token (0xFE)
        S_READ_DATA = 9,     // Read 512-byte block
        S_NEXT_BLOCK = 10,   // Prepare for next block
        S_DONE = 11,         // Read complete
        S_ERROR = 12;        // Error state

    // Registers
    reg [3:0] state, next_state;
    reg [7:0] cmd_buffer [0:5]; // Command buffer (6 bytes: 01, cmd, 32-bit arg, CRC)
    reg [7:0] resp_buffer [0:4]; // Response buffer (up to 5 bytes for R7)
    reg [9:0] byte_count;       // Counter for bytes in block (512 + 2 CRC)
    reg [15:0] div_counter;     // Clock divider counter
    reg [7:0] shift_reg;        // SPI shift register
    reg [6:0] bit_count;        // Bit counter for SPI
    reg [15:0] delay_count;     // Delay counter for timeouts
    reg sck_en;                 // Enable SCK generation
    reg [31:0] current_sector;  // Current sector address
    reg [7:0] block_counter;    // Remaining blocks to read
    reg [7:0] resp_byte;        // Current response byte
    reg resp_valid;             // Response byte valid

    always @(posedge clk) begin
        if (data_valid)
            debug_led <= 1;
        else 
            debug_led <= 0;
    end

    // Clock divider
    reg sck_toggle;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_counter <= 0;
            sck_toggle <= 0;
        end else begin
            // Use 400 kHz for initialization, 12.5 MHz for reading
            if (state <= S_INIT_CMD16) begin // init phase
                if (div_counter == INIT_DIV - 1) begin
                    div_counter <= 0;
                    sck_toggle <= ~sck_toggle; //toggle sclk bit
                end else begin
                    div_counter <= div_counter + 1;
                end
            end else begin //communacation phase
                if (div_counter == READ_DIV - 1) begin
                    div_counter <= 0;
                    sck_toggle <= ~sck_toggle; //toggle sclk bit
                end else begin
                    div_counter <= div_counter + 1;
                end
            end
        end
    end

    // Generate SCK (SPI Mode 0: idle low, sample on rising, shift on falling)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // reset: reset low
            sck <= 0;
        end else if (sck_en && div_counter == 0) begin //toggle SCLK 1 clock after sck_toggle
            sck <= sck_toggle;
        end else begin //sck not enable || counter counting
            sck <= 0; // Idle low when not enabled
        end
    end

    // SPI shift register (send MOSI, receive MISO)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'hFF;
            mosi <= 1;
            bit_count <= 0;
        end else if (sck_en && div_counter == 0 && sck) begin // Falling edge: shift out
            if (bit_count == 0) begin
                shift_reg <= cmd_buffer[byte_count[2:0]]; // Load next byte
                mosi <= cmd_buffer[byte_count[2:0]][7];
                bit_count <= 7;
            end else begin
                shift_reg <= {shift_reg[6:0], 1'b0};
                mosi <= shift_reg[6];
                bit_count <= bit_count - 1;
            end
        end else if (sck_en && div_counter == 0 && !sck) begin // Rising edge: sample in
            shift_reg[bit_count] <= miso;
        end
    end

    // Response handling
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            resp_byte <= 8'hFF;
            resp_valid <= 0;
        end else if (sck_en && div_counter == 0 && sck && bit_count == 0) begin
            resp_byte <= {shift_reg[6:0], miso};
            resp_valid <= 1;
        end else begin
            resp_valid <= 0;
        end
    end

    // State machine: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_INIT_POWER: begin
                if (delay_count >= 1000) // ~10ms at 100 MHz, >74 clocks
                    next_state = S_INIT_CMD0;
            end
            S_INIT_CMD0: begin
                if (resp_valid && resp_byte == 8'h01) // R1: idle
                    //next_state = S_INIT_CMD8; bypass voltage check
                    next_state = S_INIT_CMD8;
                else if (delay_count >= 10000) // Timeout ~100us
                    next_state = S_ERROR;
            end
            S_INIT_CMD8: begin
                if (resp_valid && resp_byte == 8'h01 && byte_count == 5) // R7 complete
                    next_state = S_INIT_CMD55;
                else if (delay_count >= 10000)
                    next_state = S_ERROR;
            end
            S_INIT_CMD55: begin
                if (resp_valid && resp_byte == 8'h01)
                    next_state = S_INIT_ACMD41;
                else if (delay_count >= 10000)
                    next_state = S_ERROR;
            end
            S_INIT_ACMD41: begin
                if (resp_valid && resp_byte == 8'h00) // Card ready
                    next_state = S_INIT_CMD16;
                else if (resp_valid && resp_byte == 8'h01)
                    next_state = S_INIT_CMD55;
                else if (delay_count >= 100000) // Longer timeout for init
                    next_state = S_ERROR;
            end
            S_INIT_CMD16: begin
                if (resp_valid && resp_byte == 8'h00)
                    next_state = S_IDLE;
                else if (delay_count >= 10000)
                    next_state = S_ERROR;
            end
            S_IDLE: begin
                if (start_read && block_count > 0)
                    next_state = S_SEND_CMD17;
            end
            S_SEND_CMD17: begin
                next_state = S_WAIT_TOKEN;
                //TODO: fix back
                if (resp_valid && resp_byte == 8'h00)
                    next_state = S_WAIT_TOKEN;
                else if (delay_count >= 10000)
                    next_state = S_ERROR;
            end
            S_WAIT_TOKEN: begin
                next_state = S_READ_DATA;
                //TODO: fix back
                if (resp_valid && resp_byte == 8'hFE)
                    next_state = S_READ_DATA;
                else if (delay_count >= 10000)
                    next_state = S_ERROR;
            end
            S_READ_DATA: begin
                if (byte_count >= 514) // 512 data + 2 CRC
                    next_state = S_NEXT_BLOCK;
            end
            S_NEXT_BLOCK: begin
                if (block_counter > 0)
                    next_state = S_SEND_CMD17;
                else
                    next_state = S_DONE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            S_ERROR: begin
                next_state = S_ERROR; // Stay until reset
            end
            default: next_state = S_ERROR;
        endcase
    end

    // State machine: State update and control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_INIT_POWER;
            cs_n <= 1;
            sck_en <= 0;
            byte_count <= 0;
            delay_count <= 0;
            data_out <= 0;
            data_valid <= 0;
            busy <= 1;
            error <= 0;
            current_sector <= 0;
            block_counter <= 0;
            cmd_buffer[0] <= 8'hFF;
            cmd_buffer[1] <= 8'hFF;
            cmd_buffer[2] <= 8'hFF;
            cmd_buffer[3] <= 8'hFF;
            cmd_buffer[4] <= 8'hFF;
            cmd_buffer[5] <= 8'hFF;
        end else begin
            state <= next_state;
            data_valid <= 0; // Default: no valid data
            case (state)
                S_INIT_POWER: begin
                    cs_n <= 1;
                    sck_en <= 1;
                    mosi <= 1;
                    delay_count <= delay_count + 1;
                    busy <= 1;
                end
                S_INIT_CMD0: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h40; // CMD0: Go idle
                    cmd_buffer[1] <= 8'h00;
                    cmd_buffer[2] <= 8'h00;
                    cmd_buffer[3] <= 8'h00;
                    cmd_buffer[4] <= 8'h00;
                    cmd_buffer[5] <= 8'h95; // CRC
                    byte_count <= (byte_count < 6) ? byte_count + 1 : 0;
                    if (resp_valid && resp_byte != 8'h01)
                        delay_count <= delay_count + 1;
                    else if (resp_valid)
                        delay_count <= 0;
                end
                S_INIT_CMD8: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h48; // CMD8: Voltage check
                    cmd_buffer[1] <= 8'h00;
                    cmd_buffer[2] <= 8'h00;
                    cmd_buffer[3] <= 8'h01; // 2.7-3.6V
                    cmd_buffer[4] <= 8'hAA; // Check pattern
                    cmd_buffer[5] <= 8'h87; // CRC
                    byte_count <= (byte_count < 10) ? byte_count + 1 : 0;
                    if (resp_valid && byte_count > 5)
                        resp_buffer[byte_count-6] <= resp_byte;
                    if (resp_valid && byte_count < 6 && resp_byte != 8'h01)
                        delay_count <= delay_count + 1;
                    else if (resp_valid)
                        delay_count <= 0;
                end
                S_INIT_CMD55: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h77; // CMD55: App command
                    cmd_buffer[1] <= 8'h00;
                    cmd_buffer[2] <= 8'h00;
                    cmd_buffer[3] <= 8'h00;
                    cmd_buffer[4] <= 8'h00;
                    cmd_buffer[5] <= 8'hFF;
                    byte_count <= (byte_count < 6) ? byte_count + 1 : 0;
                    if (resp_valid && resp_byte != 8'h01)
                        delay_count <= delay_count + 1;
                    else if (resp_valid)
                        delay_count <= 0;
                end
                S_INIT_ACMD41: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h69; // ACMD41: Initialize
                    cmd_buffer[1] <= 8'h40; // HCS=1 (high capacity)
                    cmd_buffer[2] <= 8'h00;
                    cmd_buffer[3] <= 8'h00;
                    cmd_buffer[4] <= 8'h00;
                    cmd_buffer[5] <= 8'hFF;
                    byte_count <= (byte_count < 6) ? byte_count + 1 : 0;
                    if (resp_valid && resp_byte != 8'h00 && resp_byte != 8'h01)
                        delay_count <= delay_count + 1;
                    else if (resp_valid)
                        delay_count <= 0;
                end
                S_INIT_CMD16: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h50; // CMD16: Set block length
                    cmd_buffer[1] <= 8'h00;
                    cmd_buffer[2] <= 8'h00;
                    cmd_buffer[3] <= 8'h02; // 512 bytes
                    cmd_buffer[4] <= 8'h00;
                    cmd_buffer[5] <= 8'hFF;
                    byte_count <= (byte_count < 6) ? byte_count + 1 : 0;
                    if (resp_valid && resp_byte != 8'h00)
                        delay_count <= delay_count + 1;
                    else if (resp_valid)
                        delay_count <= 0;
                end
                S_IDLE: begin
                    cs_n <= 1;
                    sck_en <= 0;
                    busy <= 0;
                    byte_count <= 0;
                    delay_count <= 0;
                    if (start_read && block_count > 0) begin
                        current_sector <= sector_addr;
                        block_counter <= block_count;
                        busy <= 1;
                    end
                end
                S_SEND_CMD17: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'h51; // CMD17: Read single block
                    cmd_buffer[1] <= current_sector[31:24];
                    cmd_buffer[2] <= current_sector[23:16];
                    cmd_buffer[3] <= current_sector[15:8];
                    cmd_buffer[4] <= current_sector[7:0];
                    cmd_buffer[5] <= 8'hFF; // CRC ignored
                    byte_count <= (byte_count < 6) ? byte_count + 1 : 6; // Hold at 6
                    if (byte_count == 6 && resp_valid && resp_byte == 8'h00) begin
                        next_state = S_WAIT_TOKEN;
                        delay_count <= 0;
                    end else if (delay_count >= 10000) begin
                        next_state = S_ERROR;
                    end else begin
                        delay_count <= delay_count + 1;
                    end
                end
                S_WAIT_TOKEN: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'hFF;
                    if (resp_valid && resp_byte == 8'hFE && bit_count == 0) begin
                        byte_count <= 0;
                        next_state = S_READ_DATA;
                    end else if (resp_valid) begin
                        delay_count <= 0;
                    end else if (delay_count >= 1000) begin // Reduce timeout to 10 μs for faster feedback
                        next_state = S_ERROR;
                    end else begin
                        delay_count <= delay_count + 1;
                    end
                end

                S_READ_DATA: begin
                    cs_n <= 0;
                    sck_en <= 1;
                    cmd_buffer[0] <= 8'hFF;
                    if (resp_valid && bit_count == 0) begin
                        byte_count <= byte_count + 1;
                        if (byte_count <= 511) begin
                            data_out <= resp_byte;
                            data_valid <= 1;
                        end
                    end
                    if (byte_count >= 513) begin
                        next_state = S_NEXT_BLOCK;
                    end else if (delay_count >= 10000) begin
                        next_state = S_ERROR;
                    end else begin
                        delay_count <= delay_count + 1;
                    end
                end
                S_NEXT_BLOCK: begin
                    cs_n <= 0;
                    sck_en <= 0;
                    byte_count <= 0;
                    delay_count <= 0;
                    if (block_counter > 0) begin
                        current_sector <= current_sector + 1;
                        block_counter <= block_counter - 1;
                    end
                end
                S_DONE: begin
                    cs_n <= 1;
                    sck_en <= 0;
                    busy <= 0;
                    byte_count <= 0;
                    delay_count <= 0;
                end
                S_ERROR: begin
                    cs_n <= 1;
                    sck_en <= 0;
                    busy <= 0;
                    error <= 1;
                    byte_count <= 0;
                    delay_count <= 0;
                end
            endcase
        end
    end

endmodule