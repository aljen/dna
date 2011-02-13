////////////////////////////////////////////////////////////////////////////////

#include "isr.h"

// File: irq.c
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

#include <irq.h>
#include <pic.h>
#include <utils.h>
#include <console.h>

isr_t sInterruptHandlers[256];

void
irq_init()
{
  memset(&sInterruptHandlers, 0, sizeof(isr_t) * 256);
}

void
irq_handler(registers_t registers)
{
  // send EOI to PICs
  if (registers.int_no >= 40) // send to slave
    out8(PIC2_COMMAND, PIC_EOI);

  out8(PIC1_COMMAND, PIC_EOI); // send to master

  // call registered handler
  if (sInterruptHandlers[registers.int_no] != 0) {
    isr_t handler = sInterruptHandlers[registers.int_no];
    handler(registers);
  } else {
    kprintf(KLOG "recieved irq: %d (original irq: %d)\n", registers.int_no,
        registers.int_no - 32);
//    unhandled_interrupt(registers);
  }
}

void
register_interrupt_handler(uint8_t number, isr_t handler)
{
  if (sInterruptHandlers[number] != 0)
    kprintf(KWARN "Handler for an interrupt %d is already registered!\n", number);
  kprintf(KLOG "Registering handler for an interrupt %d\n", number);
  sInterruptHandlers[number] = handler;
}

void
unregister_interrupt_handler(uint8_t number)
{
  kprintf(KLOG "Unregistering handler for an interrupt %d\n", number);
  sInterruptHandlers[number] = NULL;
}
