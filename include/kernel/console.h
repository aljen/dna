////////////////////////////////////////////////////////////////////////////////
// File: console.h
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

#ifndef KERNEL_CONSOLE_H
#define KERNEL_CONSOLE_H

#include <stdint.h>
#include <stdarg.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

static const uint8_t COLOR_BLACK           = 0;
static const uint8_t COLOR_BLUE            = 1;
static const uint8_t COLOR_GREEN           = 2;
static const uint8_t COLOR_CYAN            = 3;
static const uint8_t COLOR_RED             = 4;
static const uint8_t COLOR_MAGENTA         = 5;
static const uint8_t COLOR_BROWN           = 6;
static const uint8_t COLOR_LIGHT_GREY      = 7;
static const uint8_t COLOR_DARK_GREY       = 8;
static const uint8_t COLOR_LIGHT_BLUE      = 9;
static const uint8_t COLOR_LIGHT_GREEN     = 10;
static const uint8_t COLOR_LIGHT_CYAN      = 11;
static const uint8_t COLOR_LIGHT_RED       = 12;
static const uint8_t COLOR_LIGHT_MAGENTA   = 13;
static const uint8_t COLOR_LIGHT_BROWN     = 14;
static const uint8_t COLOR_WHITE           = 15;

#define KERROR  "[ERROR] "
#define KWARN   "[ WARN] "
#define KINFO   "[ INFO] "
#define KLOG    "[  LOG] "

void console_init();
void console_clear();
void console_putchar(int c);
void console_moveto(uint8_t x, uint8_t y);
void console_getposition(uint8_t *x, uint8_t *y);
void console_scrollup();

void kprintf(const char* format, ...);

#ifdef __cplusplus
}
#endif

#endif // KERNEL_CONSOLE_H
