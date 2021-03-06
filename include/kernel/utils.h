////////////////////////////////////////////////////////////////////////////////
// File: utils.h
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

#ifndef KERNEL_UTILS_H
#define KERNEL_UTILS_H

#include <stdint.h>

#define TEST_BIT(flags, bit)      ((flags) & (1 << (bit)))

#ifdef __cplusplus
extern "C" {
#endif

static inline uint8_t
in8(uint16_t port)
{
  uint8_t ret;
  __asm__ __volatile__("inb %1, %0" : "=a"(ret) : "dN"(port));
  return ret;
}

static inline void
out8(uint16_t port, uint8_t data)
{
  __asm__ __volatile__("outb %1, %0" : : "dN"(port), "a"(data));
}

static inline uint16_t
in16(uint16_t port)
{
  uint16_t ret;
  __asm__ __volatile__("inw %1, %0" : "=a"(ret) : "dN"(port));
  return ret;
}

static inline void
out16(uint16_t port, uint16_t data)
{
  __asm__ __volatile__("outw %1, %0" : : "dN"(port), "a"(data));
}

static inline void
io_wait()
{
  __asm__ __volatile__("outb %%al, $0x80" : : "a"(0));
}

void  __attribute__((noreturn)) panic(const char* format, ...);

#ifdef __cplusplus
}
#endif

#endif // KERNEL_UTILS_H
