module loader.main;

extern(C) void main()
{
  int x = 0;
  int y = 0;
  const uint COLUMNS = 80;
  const uint ROWS = 25;

  ubyte *video = cast(ubyte*)0xb8000;
  for (int i = 0; i < COLUMNS * ROWS * 2; i++) {
    volatile *(video + i) = 0;
  }

  volatile *(video + (x + y * COLUMNS) * 2) = 'D' & 0xFF;
  volatile *(video + (x + y * COLUMNS) * 2 + 1) = 0x07;
}

