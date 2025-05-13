from PIL import Image

def to_rgb444(r, g, b):
    r4 = (r >> 4) & 0x0F
    g4 = (g >> 4) & 0x0F
    b4 = (b >> 4) & 0x0F
    return (r4 << 8) | (g4 << 4) | b4  # 12-bit RGB444 packed into 16-bit

# Load image and convert to RGB
img = Image.open("chula.png").convert("RGB")

# Resize for testing (e.g., 64x64)
img = img.resize((320, 240))

# Save as 2-byte per pixel (upper 12 bits used)
with open("output_rgb444.bin", "wb") as f:
    for y in range(img.height):
        for x in range(img.width):
            r, g, b = img.getpixel((x, y))
            rgb444 = to_rgb444(r, g, b)
            f.write(rgb444.to_bytes(2, byteorder="big"))  # 16-bit write


