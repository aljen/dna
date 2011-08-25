////////////////////////////////////////////////////////////////////////////////
// File: gdt.h
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

#ifndef KERNEL_GDT_H
#define KERNEL_GDT_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum gdt_segments {
  NULL_SEGMENT = 0,
  KERNEL_CODE_SEGMENT,
  KERNEL_DATA_SEGMENT,
  USER_CODE_SEGMENT,
  USER_DATA_SEGMENT,
  NUM_SEGMENTS
};

typedef struct gdt_entry_t {
  uint16_t limit_low;   // lower 16bits of the limit
  uint16_t base_low;    // lower 16bits of the base address
  uint8_t base_middle;  // middle 8bits of the base address
  uint8_t access;       // access flags
  uint8_t granularity;  // upper 8bits of the limit and granularity&size flags
  uint8_t base_hight;   // upper 8bits of the base address
} __attribute__((packed)) gdt_entry_t;

typedef struct gdt_ptr_t {
  uint16_t limit;       // upper 16bits of all selector limits
  uint32_t base;        // address of the first entry in gdt table
} __attribute__((packed)) gdt_ptr_t;

void gdt_init();

#ifdef __cplusplus
}
#endif

#endif // KERNEL_GDT_H
