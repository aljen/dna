////////////////////////////////////////////////////////////////////////////////
// File: console.c
// Copyright (c) 2011, Artur Wyszyński <harakash@gmail.com>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of Artur Wyszyński nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////

#include <console.h>
#include <serial.h>
#include <utils.h>

static const int COLUMNS = 80;
static const int ROWS = 25;
static const int ATTRIBUTE = 7;
static const int VIDEO = 0xb8000;
static int sPosX = 0;
static int sPosY = 0;
static volatile unsigned char* sVideo;

void
console_init()
{
  sVideo = (unsigned char*)VIDEO;
  sPosX = sPosY = 0;
}

void
console_clear()
{
  memset((void*)sVideo, 0, COLUMNS * ROWS * 2);
  sPosX = sPosY = 0;
}

void
console_putchar(int c)
{
  if (c == '\n' || c == '\r') {
newline:
      sPosX = 0;
      sPosY++;
      if (sPosY >= ROWS)
        sPosY = 0;
      return;
  }

  *(sVideo + (sPosX + sPosY * COLUMNS) * 2) = c & 0xff;
  *(sVideo + (sPosX + sPosY * COLUMNS) * 2 + 1) = ATTRIBUTE;

  sPosX++;
  if (sPosX > COLUMNS)
    goto newline;
}

void
console_moveto(uint8_t x, uint8_t y)
{
  sPosX = x;
  sPosY = y;
}

void
console_getposition(uint8_t *x, uint8_t *y)
{
  if (x != NULL)
    *x = sPosX;
  if (y != NULL)
    *y = sPosY;
}

int
itoa(char* buf, int base, int d)
{
  int chars = 0;
  char *p = buf, *p1, *p2;
  unsigned long ud = d;
  int divisor = 10;

  if (base == 'd' && d < 0) {
    *p++ = '-';
    buf++;
    ud = -d;
  } else if (base == 'x') {
    divisor = 16;
  }

  do {
    int remainder = ud % divisor;
    *p++ = (remainder < 10) ? remainder + '0' : remainder + 'a' - 10;
    chars++;
  } while (ud /= divisor);

  *p = 0;

  p1 = buf;
  p2 = p - 1;
  while (p1 < p2) {
    char tmp = *p1;
    *p1 = *p2;
    *p2 = tmp;
    p1++;
    p2--;
  }

  return chars;
}

int32_t
vsnprintf(char *buffer, size_t size, const char *format, va_list args)
{
  unsigned int bytes_written = 0;
  unsigned int buffer_position = 0;
  int c;
  int inside_format = 0;
  int fill_count = 0;
  int is_hex = 0;
  int chars = 0;
  char buf[20];

  while ((c = *format++) != 0) {
    if (c != '%' && inside_format == 0) {
      if (buffer_position < size)
        buffer[buffer_position++] = c;
      bytes_written++;
    } else {
      char *p;

      if (inside_format == 0) {
        inside_format = 1;
        c = *format++;
      }

      switch (c) {
        case 'd':
        case 'u':
        case 'x':
          if (c == 'x')
            is_hex = 1;
          const int number = va_arg(args, int);
          chars = itoa(buf, c, number);
          p = buf;
          inside_format = 0;
          goto string;
          break;

        case 's':
          p = va_arg(args, char*);
          if (!p)
            p = (char*)"(null)";
          inside_format = 0;
          goto string;
          break;

        case '1':
        case '2':
        case '4':
        case '8':
          if (inside_format && fill_count == 0)
            fill_count = c - '0';
          break;

      string:
          if (fill_count != 0) {
              if (is_hex)
                fill_count *= 2;
              const int count = fill_count - chars;
              if (count > 0) {
                  for (int i = 0; i < count; i++) {
                    if (buffer_position < size)
                      buffer[buffer_position++] = '0';
                    bytes_written++;
                  }
              }
              fill_count = 0;
          }
          while (*p) {
            if (buffer_position < size)
              buffer[buffer_position++] = *p++;
            bytes_written++;
          }
          break;

        default:
          if (buffer_position < size)
            buffer[buffer_position++] = va_arg(args, int);
          bytes_written++;
          break;
      }
    }
  }

  if (buffer_position < size)
    buffer[buffer_position] = '\0';
  else
    buffer[size] = '\0';

  return bytes_written;
}

void
kprintf(const char* format, ...)
{
  int length = 0;
  char buffer[1024];
  va_list args;
  va_start(args, format);
  length = vsnprintf((char*)&buffer, 1024, format, args);
  va_end(args);
  for (int i = 0; i < length; i++)
    console_putchar(buffer[i]);
  serial_puts(buffer, length);
}
