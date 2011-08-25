////////////////////////////////////////////////////////////////////////////////
// File: timer.c
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

#include <timer.h>
#include <irq.h>
#include <utils.h>
#include <console.h>

static uint64_t sTicks = 0;

static void
timer_callback(registers_t registers)
{
  (void)registers;
  sTicks++;
}

void
timer_init(uint32_t frequency)
{
  register_interrupt_handler(IRQ0, &timer_callback);

  uint32_t divisor = 1193180 / frequency;

  // 0x36 = 00110110
  // bit     0: bcd/binary mode: 0 - 16bit binary
  // bits 1..3: operating mode: 011 - mode 3 (square wave generator)
  // bits 4..5: access mode: 11 - lo/hi byte
  // bits 6..7: channel: 00 - channel 0
  out8(PIT_COMMAND, 0x36);

  uint8_t low = (uint8_t)(divisor &0xff);
  uint8_t high = (uint8_t)((divisor >> 8) & 0xff);

  out8(PIT_DATA0, low);
  out8(PIT_DATA0, high);
}
