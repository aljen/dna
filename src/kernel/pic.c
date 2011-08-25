////////////////////////////////////////////////////////////////////////////////
// File: pic.c
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

#include <pic.h>
#include <utils.h>

void
pic_remap()
{
  uint8_t mask1 = in8(PIC1_DATA); // save masks
  uint8_t mask2 = in8(PIC2_DATA);

  out8(PIC1_COMMAND, ICW1_INIT + ICW1_ICW4);  // send init command to master
  io_wait();
  out8(PIC2_COMMAND, ICW1_INIT + ICW1_ICW4);  // send init command to slave
  io_wait();

  // remap irqs:
  // irq 0..7  from int 0x08..0x0f to int 0x20..0x27
  // irq 8..15 from int 0x70..0x77 to int 0x28..0x2f
  out8(PIC1_DATA, 0x20);  // set pic vectors for master to int 32 (0x20)
  io_wait();
  out8(PIC2_DATA, 0x28);  // set pic vectors for slave to int 40 (0x28)
  io_wait();

  out8(PIC1_DATA, 0x04);  // continue initialization code
  io_wait();
  out8(PIC2_DATA, 0x02);
  io_wait();

  out8(PIC1_DATA, ICW4_8086); // set mode
  io_wait();
  out8(PIC2_DATA, ICW4_8086);
  io_wait();

  out8(PIC1_DATA, mask1);
  out8(PIC2_DATA, mask2);
}
