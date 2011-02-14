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
#include <utils.h>

static gdt_entry_t sGdtEntries[NUM_SEGMENTS];
static gdt_ptr_t sGdt;

static void gdt_set_gate(uint8_t index, uint32_t base, uint32_t limit,
  uint8_t access, uint8_t granularity);

extern void gdt_flush(uint32_t ptr);

void
gdt_init()
{
  sGdt.limit = sizeof(gdt_entry_t) * NUM_SEGMENTS - 1;
  sGdt.base = (uint32_t)&sGdtEntries;

  memset(&sGdtEntries, 0, sizeof(gdt_entry_t) * NUM_SEGMENTS);

  // flat memory model, each segment starts at 0x0 and ends at 0xffffffff (4gb)
  // 0x9a = present, ring0, code, read&execute
  // 0x92 = present, ring0, data, read&write
  // 0xfa = present, ring3, code, read&execute
  // 0xf2 = present, ring3, data, read&write
  // 0xcf = 4kb page granularity, 32bits pmode
  gdt_set_gate(NULL_SEGMENT, 0, 0, 0, 0);
  gdt_set_gate(KERNEL_CODE_SEGMENT, 0, 0xffffffff, 0x9a, 0xcf);
  gdt_set_gate(KERNEL_DATA_SEGMENT, 0, 0xffffffff, 0x92, 0xcf);
  gdt_set_gate(USER_CODE_SEGMENT, 0, 0xffffffff, 0xfa, 0xcf);
  gdt_set_gate(USER_DATA_SEGMENT, 0, 0xffffffff, 0xf2, 0xcf);

  gdt_flush((uint32_t)&sGdt); // reload the global description table
}

static void
gdt_set_gate(uint8_t index, uint32_t base, uint32_t limit, uint8_t access,
  uint8_t granularity)
{
  // set lower 16bits of the base address
  sGdtEntries[index].base_low = (base & 0xffff);
  // set middle 8bits of the base address
  sGdtEntries[index].base_middle = (base >> 16) & 0xff;
  // set upper 8bits of the base address
  sGdtEntries[index].base_hight = (base >> 24) & 0xff;
  // set lower 16bits of the limit
  sGdtEntries[index].limit_low = (limit & 0xffff);
  // set upper 8bits of the limit
  sGdtEntries[index].granularity = (limit >> 16) & 0x0f;
  // set granularity & size flags
  sGdtEntries[index].granularity |= granularity & 0xf0;
  // set access flags
  sGdtEntries[index].access = access;
}
