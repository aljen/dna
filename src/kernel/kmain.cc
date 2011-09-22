////////////////////////////////////////////////////////////////////////////////
// File: kmain.cc
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

#include <multiboot.h>
#include <gdt.h>
#include <idt.h>
#include <irq.h>
#include <isr.h>
#include <timer.h>
#include <keyboard.h>
#include <console.h>
#include <serial.h>
#include <string.h>
#include <utils.h>

extern "C" uint16_t start_bss, end_bss;

extern "C" void
kmain(uint32_t magic, multiboot_info_t* info)
{
  (void)info;

  memset(&start_bss, 0, &end_bss - &start_bss);

  console_init();
  console_clear();

  serial_init();
  serial_enable();

  kprintf(KINFO "Loading DNA...\n");

  if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
    kprintf(KWARN "Bad MBH magic number: 0x%08x!\n", magic);
    panic("Bad MBH magic number");
  }

  gdt_init();
  idt_init();
  irq_init();

  timer_init(100); // 1193180Hz / 100Hz = 11931 ~= tick each 11ms
  keyboard_init();

  enable_interrupts();

  for (;;) {}

  return;
}
