;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: irqs.S
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

global irq00, irq01, irq02, irq03, irq04, irq05, irq06, irq07, irq08, irq09
global irq10, irq11, irq12, irq13, irq14, irq15
extern irq_handler

%macro irq_body 1                       ; macro for common interrupt body
  cli                                   ; disable interrupts
  push  byte 0                          ; push dummy error code
  push  byte %1                         ; push isr index
  jmp   irq_common_stub                 ; call common handler stub
%endmacro

irq00:
  irq_body 32

irq01:
  irq_body 33

irq02:
  irq_body 34

irq03:
  irq_body 35

irq04:
  irq_body 36

irq05:
  irq_body 37

irq06:
  irq_body 38

irq07:
  irq_body 39

irq08:
  irq_body 40

irq09:
  irq_body 41

irq10:
  irq_body 42

irq11:
  irq_body 43

irq12:
  irq_body 44

irq13:
  irq_body 45

irq14:
  irq_body 46

irq15:
  irq_body 47

irq_common_stub:
  pusha                                 ; pushes edi, esi, ebp, esp, eax, ebx
                                        ; ecx, edx

  mov   ax, 0x10                        ; lower 16bits of eax = ds
  push  eax                             ; save the data segment descriptor

  mov   ds, ax                          ; load the kernel data segment
                                        ; descriptor
  mov   es, ax
  mov   fs, ax
  mov   gs, ax

  call  irq_handler                     ; call irq handler

  pop   ebx                             ; reload the original data segment
                                        ; descriptor
  mov   ds, bx
  mov   es, bx
  mov   fs, bx
  mov   gs, bx

  popa                                  ; pops edi, esi, ebp, esp, eax, ebx
                                        ; ecx, edx
  add   esp, 8                          ; cleans up pushed error code and
                                        ; isr index
  sti                                   ; enable interrupts
  iret                                  ; pop cs, eip, eflags, ss, esp
