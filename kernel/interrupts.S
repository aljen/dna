;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: interrupts.S
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

global isr00, isr01, isr02, isr03, isr04, isr05, isr06, isr07, isr08, isr09
global isr10, isr11, isr12, isr13, isr14, isr15, isr16, isr17, isr18, isr19
global isr20, isr21, isr22, isr23, isr24, isr25, isr26, isr27, isr28, isr29
global isr30, isr31
extern isr_handler

%macro isr_noerrcode 1                  ; macro for interrupt without error code
  cli                                   ; disable interrupts
  push  byte 0                          ; push dummy error code
  push  byte %1                         ; push interrupt number
  jmp   isr_common_stub                 ; call common handler stub
%endmacro

%macro isr_errcode 1                    ; macro for interrupt with error code
  cli                                   ; disable interrupts
  push  byte %1                         ; push interrupt number
  jmp   isr_common_stub                 ; call common handler stub
%endmacro

isr00:                                  ; division by zero
  isr_noerrcode 0

isr01:                                  ; debug
  isr_noerrcode 1

isr02:                                  ; non maskable interrupt
  isr_noerrcode 2

isr03:                                  ; breakpoint
  isr_noerrcode 3

isr04:                                  ; overflow
  isr_noerrcode 4

isr05:                                  ; out of bounds
  isr_noerrcode 5

isr06:                                  ; invalid opcode
  isr_noerrcode 6

isr07:                                  ; device not available
  isr_noerrcode 7

isr08:                                  ; double fault
  isr_errcode 8

isr09:                                  ; coprocessor segment overrun
  isr_noerrcode 9

isr10:                                  ; invalid tss
  isr_errcode 10

isr11:                                  ; segment not present
  isr_errcode 11

isr12:                                  ; stack-segment fault
  isr_errcode 12

isr13:                                  ; general protection fault
  isr_errcode 13

isr14:                                  ; page fault
  isr_errcode 14

isr15:                                  ; unknown interrupt
  isr_noerrcode 15

isr16:                                  ; x87 floating-point exception
  isr_noerrcode 16

isr17:                                  ; alignment check
  isr_noerrcode 17

isr18:                                  ; machine check
  isr_noerrcode 18

isr19:                                  ; SIMD floating-point exception
  isr_noerrcode 19

isr20:                                  ; reserved
  isr_noerrcode 20

isr21:                                  ; reserved
  isr_noerrcode 21

isr22:                                  ; reserved
  isr_noerrcode 22

isr23:                                  ; reserved
  isr_noerrcode 23

isr24:                                  ; reserved
  isr_noerrcode 24

isr25:                                  ; reserved
  isr_noerrcode 25

isr26:                                  ; reserved
  isr_noerrcode 26

isr27:                                  ; reserved
  isr_noerrcode 27

isr28:                                  ; reserved
  isr_noerrcode 28

isr29:                                  ; reserved
  isr_noerrcode 29

isr30:                                  ; security exception
  isr_noerrcode 30

isr31:                                  ; reserved
  isr_noerrcode 31

isr_common_stub:
  pusha                                 ; pushes edi, esi, ebp, esp, eax, ebx
                                        ; ecx, edx

  mov   ax, ds                          ; lower 16bits of eax = ds
  push  eax                             ; save the data segment descriptor

  mov   ax, 0x10                        ; load the kernel data segment
                                        ; descriptor, 0x10 - 3rd entry in gdt
                                        ; table
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax

  call  isr_handler                     ; call isr handler

  pop   eax                             ; reload the original data segment
                                        ; descriptor
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax

  popa                                  ; pops edi, esi, ebp, esp, eax, ebx
                                        ; ecx, edx
  add   esp, 8                          ; cleans up pushed error code and
                                        ; interrupt index
  sti                                   ; enable interrupts
  iret                                  ; pop cs, eip, eflags, ss, esp
