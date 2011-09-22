////////////////////////////////////////////////////////////////////////////////
// File: pic.h
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

#ifndef KERNEL_PIC_H
#define KERNEL_PIC_H

#define PIC1            0x20        // io base address for master pic
#define PIC2            0xa0        // io base address for slave pic
#define PIC1_COMMAND    PIC1        // master pic command = 0x20
#define PIC1_DATA       (PIC1 + 1)  // master pic data = 0x21
#define PIC2_COMMAND    PIC2        // slave pic command = 0xa0
#define PIC2_DATA       (PIC2 + 1)  // slave pic data = 0xa1
#define PIC_EOI         0x20        // EOI - end of interrupt command code

#define ICW1_ICW4       0x01        // ICW4 (not) needed
#define ICW1_SINGLE     0x02        // single (cascade) mode
#define ICW1_INTERVAL4  0x04        // call address interval 4 (8)
#define ICW1_LEVEL      0x08        // level triggered (edge) mode
#define ICW1_INIT       0x10        // initialization command

#define ICW4_8086       0x01        // 8086/88 (MCS-80/85) mode
#define ICW4_AUTO       0x02        // auto (normal) EOI
#define ICW4_BUF_SLAVE  0x08        // buffered mode/slave
#define ICW4_BUF_MASTER 0x0c        // buffered mode/master
#define ICW4_SFNM       0x10        // special fully nested (not)

#ifdef __cplusplus
extern "C" {
#endif

void pic_remap();

#ifdef __cplusplus
}
#endif

#endif // KERNEL_PIC_H
