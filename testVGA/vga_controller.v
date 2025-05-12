module vga_controller(
    input clk,           // 25 MHz for standard 640x480 @ 60Hz
    input rst,
    output reg [9:0] h_cnt,
    output reg [9:0] v_cnt,
    output hsync,
    output vsync,
    output visible
);

    // VGA 640x480 timing parameters
    localparam H_VISIBLE = 640;
    localparam H_FRONT = 16;
    localparam H_SYNC = 96;
    localparam H_BACK = 48;
    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    localparam V_VISIBLE = 480;
    localparam V_FRONT = 10;
    localparam V_SYNC = 2;
    localparam V_BACK = 33;
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    assign hsync = ~(h_cnt >= H_VISIBLE + H_FRONT && h_cnt < H_VISIBLE + H_FRONT + H_SYNC);
    assign vsync = ~(v_cnt >= V_VISIBLE + V_FRONT && v_cnt < V_VISIBLE + V_FRONT + V_SYNC);
    assign visible = (h_cnt < H_VISIBLE && v_cnt < V_VISIBLE);

endmodule