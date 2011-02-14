////////////////////////////////////////////////////////////////////////////////
// File: serial.h
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

#ifndef KERNEL_SERIAL_H
#define KERNEL_SERIAL_H

#include <stddef.h>
#include <stdbool.h>

#define SERIAL_PORT_BASE      0x3f8
#define SERIAL_READ_BUFFER    0
#define SERIAL_WRITE_BUFFER   0
#define SERIAL_FIFO_CONTROL   2
#define SERIAL_LINE_CONTROL   3
#define SERIAL_MODEM_CONTROL  4
#define SERIAL_LINE_STATUS    5
#define SERIAL_MODEM_STATUS   6
#define SERIAL_DLAB_HIGH      1
#define SERIAL_DLAB_LOW       0

#ifdef __cplusplus
extern "C" {
#endif

void serial_init();
void serial_enable();
void serial_disable();
bool serial_enabled();
void serial_puts(const char *string, size_t count);

#ifdef __cplusplus
}
#endif

#endif // KERNEL_SERIAL_H
