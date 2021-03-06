////////////////////////////////////////////////////////////////////////////////
// File: idt.c
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

#include <idt.h>
#include <pic.h>
#include <irq.h>
#include <string.h>

static idt_entry_t sIdtEntries[MAX_IDT_GATES];
static idt_ptr_t sIdt;

static void
idt_set_gate(uint8_t index, uint32_t base, uint16_t selector,
  uint8_t flags)
{
  // set lower 16bits of the address to jump to on interrupt
  sIdtEntries[index].base_low = base & 0xffff;
  // set upper 16 bits of that address
  sIdtEntries[index].base_high = (base >> 16) & 0xffff;
  // set kernel segment selector
  sIdtEntries[index].selector = selector;
  sIdtEntries[index].always0 = 0;
  // set flags
  sIdtEntries[index].flags = flags;
}

void
idt_init()
{
  sIdt.limit = sizeof(idt_entry_t) * MAX_IDT_GATES - 1;
  sIdt.base = (uint32_t)&sIdtEntries;

  memset(&sIdtEntries, 0, sizeof(idt_entry_t) * MAX_IDT_GATES);

  pic_remap(); // remap irqs

  // 0x08 = kernel code gdt descriptor
  // 0x8e = interrupt gate, ring0

  // set first 32 interrupts for traps, faults & exceptions
  idt_set_gate( 0, (uint32_t)isr00, 0x08, 0x8e);
  idt_set_gate( 1, (uint32_t)isr01, 0x08, 0x8e);
  idt_set_gate( 2, (uint32_t)isr02, 0x08, 0x8e);
  idt_set_gate( 3, (uint32_t)isr03, 0x08, 0x8e);
  idt_set_gate( 4, (uint32_t)isr04, 0x08, 0x8e);
  idt_set_gate( 5, (uint32_t)isr05, 0x08, 0x8e);
  idt_set_gate( 6, (uint32_t)isr06, 0x08, 0x8e);
  idt_set_gate( 7, (uint32_t)isr07, 0x08, 0x8e);
  idt_set_gate( 8, (uint32_t)isr08, 0x08, 0x8e);
  idt_set_gate( 9, (uint32_t)isr09, 0x08, 0x8e);
  idt_set_gate(10, (uint32_t)isr10, 0x08, 0x8e);
  idt_set_gate(11, (uint32_t)isr11, 0x08, 0x8e);
  idt_set_gate(12, (uint32_t)isr12, 0x08, 0x8e);
  idt_set_gate(13, (uint32_t)isr13, 0x08, 0x8e);
  idt_set_gate(14, (uint32_t)isr14, 0x08, 0x8e);
  idt_set_gate(15, (uint32_t)isr15, 0x08, 0x8e);
  idt_set_gate(16, (uint32_t)isr16, 0x08, 0x8e);
  idt_set_gate(17, (uint32_t)isr17, 0x08, 0x8e);
  idt_set_gate(18, (uint32_t)isr18, 0x08, 0x8e);
  idt_set_gate(19, (uint32_t)isr19, 0x08, 0x8e);
  idt_set_gate(20, (uint32_t)isr20, 0x08, 0x8e);
  idt_set_gate(21, (uint32_t)isr21, 0x08, 0x8e);
  idt_set_gate(22, (uint32_t)isr22, 0x08, 0x8e);
  idt_set_gate(23, (uint32_t)isr23, 0x08, 0x8e);
  idt_set_gate(24, (uint32_t)isr24, 0x08, 0x8e);
  idt_set_gate(25, (uint32_t)isr25, 0x08, 0x8e);
  idt_set_gate(26, (uint32_t)isr26, 0x08, 0x8e);
  idt_set_gate(27, (uint32_t)isr27, 0x08, 0x8e);
  idt_set_gate(28, (uint32_t)isr28, 0x08, 0x8e);
  idt_set_gate(29, (uint32_t)isr29, 0x08, 0x8e);
  idt_set_gate(30, (uint32_t)isr30, 0x08, 0x8e);
  idt_set_gate(31, (uint32_t)isr31, 0x08, 0x8e);

  // set remapped irqs
  idt_set_gate(32, (uint32_t)irq00, 0x08, 0x8e);
  idt_set_gate(33, (uint32_t)irq01, 0x08, 0x8e);
  idt_set_gate(34, (uint32_t)irq02, 0x08, 0x8e);
  idt_set_gate(35, (uint32_t)irq03, 0x08, 0x8e);
  idt_set_gate(36, (uint32_t)irq04, 0x08, 0x8e);
  idt_set_gate(37, (uint32_t)irq05, 0x08, 0x8e);
  idt_set_gate(38, (uint32_t)irq06, 0x08, 0x8e);
  idt_set_gate(39, (uint32_t)irq07, 0x08, 0x8e);
  idt_set_gate(40, (uint32_t)irq08, 0x08, 0x8e);
  idt_set_gate(41, (uint32_t)irq09, 0x08, 0x8e);
  idt_set_gate(42, (uint32_t)irq10, 0x08, 0x8e);
  idt_set_gate(43, (uint32_t)irq11, 0x08, 0x8e);
  idt_set_gate(44, (uint32_t)irq12, 0x08, 0x8e);
  idt_set_gate(45, (uint32_t)irq13, 0x08, 0x8e);
  idt_set_gate(46, (uint32_t)irq14, 0x08, 0x8e);
  idt_set_gate(47, (uint32_t)irq15, 0x08, 0x8e);

  idt_flush((uint32_t)&sIdt); // reload the interrupts description table
}
