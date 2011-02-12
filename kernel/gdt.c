////////////////////////////////////////////////////////////////////////////////
// File: gdt.c
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

#include <gdt.h>

static gdt_entry_t sGdtEntries[5];
static gdt_ptr_t sGdt;

static void gdt_set_gate(uint8_t index, uint32_t base, uint32_t limit,
  uint8_t access, uint8_t granularity);

extern void gdt_flush(uint32_t ptr);

void
gdt_init()
{
  sGdt.limit = sizeof(gdt_entry_t) * 5 - 1;
  sGdt.base = (uint32_t)&sGdtEntries;

  gdt_set_gate(0, 0, 0, 0, 0);
  gdt_set_gate(1, 0, 0xffffffff, 0x9a, 0xcf);
  gdt_set_gate(2, 0, 0xffffffff, 0x92, 0xcf);
  gdt_set_gate(3, 0, 0xffffffff, 0xfa, 0xcf);
  gdt_set_gate(4, 0, 0xffffffff, 0xf2, 0xcf);

  gdt_flush((uint32_t)&sGdt);
}

static void
gdt_set_gate(uint8_t index, uint32_t base, uint32_t limit, uint8_t access,
  uint8_t granularity)
{
  sGdtEntries[index].base_low = (base & 0xffff);
  sGdtEntries[index].base_middle = (base >> 16) & 0xff;
  sGdtEntries[index].base_hight = (base >> 24) & 0xff;
  sGdtEntries[index].limit_low = (limit & 0xffff);
  sGdtEntries[index].granularity = (limit >> 16) & 0x0f;
  sGdtEntries[index].granularity |= granularity & 0xf0;
  sGdtEntries[index].access = access;
}
