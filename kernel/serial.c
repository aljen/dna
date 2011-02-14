////////////////////////////////////////////////////////////////////////////////
// File: serial.c
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

#include <serial.h>
#include <utils.h>

static bool sSerialEnabled = false;

void
serial_init()
{
  // disable all interrupts
  out8(SERIAL_PORT_BASE + SERIAL_DLAB_HIGH, 0x00);
  // enable dlab
  out8(SERIAL_PORT_BASE + SERIAL_LINE_CONTROL, 0x80);
  // set divisor to 1, 115200 baud rate
  out8(SERIAL_PORT_BASE + SERIAL_DLAB_LOW, 0x01); // dlab low byte
  out8(SERIAL_PORT_BASE + SERIAL_DLAB_HIGH, 0x00); // dlab high byte
  // set 8n1
  out8(SERIAL_PORT_BASE + SERIAL_LINE_CONTROL, 0x03);
  // enable fifo, clear them, with 14byte threshold
  out8(SERIAL_PORT_BASE + SERIAL_FIFO_CONTROL, 0xc7);
}

void
serial_enable()
{
  sSerialEnabled = true;
}

void serial_disable()
{
  sSerialEnabled = false;
}

bool serial_enabled()
{
  return sSerialEnabled;
}

static void
serial_putchar(char c)
{
  while ((in8(SERIAL_PORT_BASE + SERIAL_LINE_STATUS) & 0x20) == 0);
  out8(SERIAL_PORT_BASE + SERIAL_WRITE_BUFFER, c);
}

void
serial_printf(const char *string, size_t count)
{
  if (!sSerialEnabled)
    return;

  while (count-- != 0) {
    char c = string[0];
    if (c == '\n') {
      serial_putchar('\r');
      serial_putchar('\n');
    } else {
      serial_putchar(c);
    }
    string++;
  }
}
