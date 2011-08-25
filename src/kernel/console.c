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
#include <string.h>

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
      if (sPosY >= ROWS) {
        sPosY = ROWS - 1;
        console_scrollup();
      }
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

void
console_scrollup()
{
  for (int i = 0; i < ROWS - 1; i++) {
    unsigned char *src = (unsigned char*)sVideo + ((i + 1) * COLUMNS * 2);
    unsigned char *dst = (unsigned char*)sVideo + (i * COLUMNS * 2);
    memcpy(dst, src, COLUMNS * 2);
  }
  unsigned char *line = (unsigned char*)sVideo + (((ROWS - 1) * COLUMNS) * 2);
  memset((void*)line, 0, COLUMNS * 2);
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
