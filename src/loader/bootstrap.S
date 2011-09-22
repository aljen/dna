;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: bootstrap.S
; Copyright (c) 2011, Artur Wyszyński <artur.wyszynski@hitomi.pl>
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

; [map symbols bootstrap.map]

%define LOADER_START  0x8200

use16
org 0x8000

start16:
  jmp   continue16

%include 'utils.inc'

error16:
  push  si
  mov   si, error_msg
  call  print_string
  pop   si
  call  print_string
  call  cpu_hang16

cpu_hang16:                               ; hang with infinite loop
.hang:
  hlt
  jmp   .hang

continue16:
  cli                                     ; disable interrupts

  xor   ax, ax
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax

  ; check if cpu is 64bit
  mov   eax, 0x80000000                   ; get highest extended funcion
  cpuid
  cmp   eax, 0x80000000                   ; fail if it's <= 0x80000000
  mov   si, error_long_mode_msg
  jbe   error16
  mov   eax, 0x80000001                   ; get ext. processor info & features
  cpuid
  bt    edx, 29                           ; is long mode available?
  mov   si, error_long_mode_msg
  jnc   error16

  ; enable a20 - bios
  mov   ax, 0x2401                        ; function 0x2401 - enable a20
  int   0x15
  jnc   .a20_enabled

  mov   si, error_a20_msg
  call  error16

.a20_enabled:
  mov   eax, cr0
  and   eax, 0x7fffffff                   ; first, disable paging
  mov   cr0, eax

  ; load gdt
  lgdt  [gdt]

  ; switch to 32-bit protected mode
  mov   eax, cr0
  or    eax, 1
  mov   cr0, eax

  jmp   0x08:start32

gdt_data:
  ; null descriptor
  dd    0
  dd    0

  ; code descriptor
  dw    0xffff                            ; limit low
  dw    0                                 ; base low
  db    0                                 ; base middle
  db    10011010b                         ; access
  db    11001111b                         ; granularity
  db    0                                 ; base high

  ; data descriptor
  dw    0xffff                            ; limit low
  dw    0                                 ; base low
  db    0                                 ; base middle
  db    10010010b                         ; access
  db    11001111b                         ; granularity
  db    0                                 ; base high

gdt:
  dw    gdt - gdt_data - 1
  dd    gdt_data

error_msg           db  'ERROR: ', 0
error_a20_msg       db  'Cant enable A20!', 13, 10, 0
error_long_mode_msg db  'CPU is not compatible with 64bit mode!', 13, 10, 0

align 4                                   ; align to page
use32
start32:
  mov   ax, 0x10
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax
  mov   ss, ax

  jmp   LOADER_START

times 512 - ($ - $$)  db  0
