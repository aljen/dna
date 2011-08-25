////////////////////////////////////////////////////////////////////////////////
// File: isr.c
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

#include <isr.h>
#include <console.h>
#include <utils.h>
#include <irq.h>

extern isr_t sInterruptHandlers[MAX_INTERRUPT_HANDLERS];

const char*
exception_descriptions[RESERVED_INTERRUPTS] = {
  "Division by zero",               //  0
  "Debug",                          //  1
  "Non maskable interrupt",         //  2
  "Breakpoint",                     //  3
  "Overflow",                       //  4
  "Out of bounds",                  //  5
  "Invalid opcode",                 //  6
  "Device not available",           //  7
  "Double fault",                   //  8
  "Coprocessor segment overrun",    //  9
  "Invalid TSS",                    // 10
  "Segment not present",            // 11
  "Stack-segment fault",            // 12
  "General protection fault",       // 13
  "Page fault",                     // 14
  "Unknow interrupt",               // 15
  "x87 floating-point exception",   // 16
  "Alignment check",                // 17
  "Machine check",                  // 18
  "SIMD floating-point exception"   // 19
  "Reserved"                        // 20
  "Reserved"                        // 21
  "Reserved"                        // 22
  "Reserved"                        // 23
  "Reserved"                        // 24
  "Reserved"                        // 25
  "Reserved"                        // 26
  "Reserved"                        // 27
  "Reserved"                        // 28
  "Reserved"                        // 29
  "Security exception"              // 30
  "Reserved"                        // 31
};

void
isr_handler(registers_t registers)
{
  if (sInterruptHandlers[registers.int_no] != 0) {
    isr_t handler = sInterruptHandlers[registers.int_no];
    handler(registers);
  } else {
    kprintf(KLOG "recieved interrupt: %d\n", registers.int_no);
    unhandled_interrupt(registers);
  }
}

void
unhandled_interrupt(registers_t registers)
{
  kprintf(KWARN "Unhandled interrupt 0x%02x ('%s')\n",
    registers.int_no, exception_descriptions[registers.int_no]);
  if (registers.int_no == 8 || (registers.int_no >= 10
      && registers.int_no <= 14)) {
    kprintf(KWARN "Error code: 0x%08x\n", registers.err_code);
  }
  kprintf(KWARN "eax: 0x%08x esi: 0x%08x ebp: 0x%08x eflags: 0x%08x\n",
    registers.eax, registers.esi, registers.ebp, registers.eflags);
  kprintf(KWARN "ebx: 0x%08x edi: 0x%08x  cs: 0x%08x usersp: 0x%08x\n",
    registers.ebx, registers.edi, registers.cs, registers.usersp);
  kprintf(KWARN "ecx: 0x%08x esp: 0x%08x  ds: 0x%08x\n",
    registers.ecx, registers.esp, registers.ds);
  kprintf(KWARN "edx: 0x%08x eip: 0x%08x  ss: 0x%08x\n",
    registers.edx, registers.eip, registers.ss);

  panic("Unhandled interrupt");
}

void
enable_interrupts()
{
  __asm__ __volatile__("sti");
}

void
disable_interrupts()
{
  __asm__ __volatile__("cli");
}
