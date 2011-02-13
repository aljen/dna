;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: boot.S
; Copyright (c) 2011, Artur Wyszyński <harakash@gmail.com>
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; * Redistributions of source code must retain the above copyright notice,
;   this list of conditions and the following disclaimer.
; * Redistributions in binary form must reproduce the above copyright notice,
;   this list of conditions and the following disclaimer in the documentation
;   and/or other materials provided with the distribution.
; * Neither the name of Artur Wyszyński nor the names of its contributors
;   may be used to endorse or promote products derived from this software
;   without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
; OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
; IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global loader, cpu_hang, gdt_flush, idt_flush
extern start_ctors, end_ctors, start_dtors, end_dtors, kmain

MODULE_ALIGN  equ 1 << 0                  ; kernel and modules are aligned
MEM_INFO      equ 1 << 1                  ; provide memory info
FLAGS         equ MODULE_ALIGN | MEM_INFO ; setup flags
MAGIC         equ 0x1badb002              ; multiboot magic
CHECKSUM      equ -(MAGIC + FLAGS)        ; checksum

section .text
align 4                                   ; align to page
MultiBootHeader:
  dd MAGIC
  dd FLAGS
  dd CHECKSUM

STACKSIZE equ 0x4000                      ; 16kb

loader:
  mov   esp, stack + STACKSIZE            ; setup stack
  push  ebx                               ; push multiboot magic value
  push  eax                               ; push multiboot header

static_ctors_loop:                        ; call c++ ctors
  mov   ebx, start_ctors
  jmp   .test
.body:
  call  [ebx]
  add   ebx, 4
.test:
  cmp   ebx, end_ctors
  jb    .body

  cli                                     ; disable interrupts
  call  kmain                             ; call kernel main function

static_dtors_loop:                        ; call c++ dtors
  mov   ebx, start_dtors
  jmp   .test
.body:
  call  [ebx]
  add   ebx, 4
.test:
  cmp   ebx, end_dtors
  jmp   .body

  cli                                     ; disable interrupts

cpu_hang:                                 ; hang with infinite loop
.hang:
  hlt
  jmp .hang

gdt_flush:                                ; load gdt table
  mov   eax, [esp + 4]
  lgdt  [eax]

  mov   ax, 0x10
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax
  mov   ss, ax
  jmp   0x08:.flush
.flush:
  ret

idt_flush:                                ; load idt table
  mov   eax, [esp + 4]
  lidt  [eax]
  ret

section .bss
align 4                                   ; align to page
stack:
  resb  STACKSIZE
