;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: stage1.S
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

; memory map, for details see http://wiki.osdev.org/Memory_Map_(x86):
; 0x00000000 - 0x000003ff - ivt, 1kb
; 0x00000400 - 0x000004ff - bda, 256b
; 0x00000500 - 0x00007bff - free, stage1 will be there, ~30kb
; 0x00007c00 - 0x00007dff - stage1 before being relocated, later stage2, 512b
; 0x00007e00 - 0x0007ffff - free, 480.5kb

; things that we will try do:
; - relocate to 0x500 to make room for active partition's vbr
; - setup stack
; - find an anctive partition
; - try to load first two sectors (1024 bytes) from it into 0x7c00
; - set ds:si pointing to the selected partition entry in mbr
; - set cs to 0, dl to the boot drive number
; - jump into 0x7c00 and execute (hopefully) stage2 loader

; [map symbols stage1.map]

%assign STAGE1_START_SEGMENT  0x7c0
%assign STAGE1_TARGET_SEGMENT 0x50
%assign STAGE1_TARGET_ADDRESS 0x500
%assign STAGE2_START_SEGMENT  STAGE1_START_SEGMENT
%assign STAGE2_START_ADDRESS  0x7c00
%assign STAGE1_SIZE           512
%assign STAGE2_SIZE           1024
%assign SECTOR_SIZE           512
%assign STACK_START           0x700
%assign STACK_SIZE            0x1000 ; 4kb
%assign MAX_BOOT_CODE_SIZE    446

; disk address packet needed for extended read sectors
struc DAP
  .size                       resb 1
  .zero                       resb 1
  .no_of_sectors              resw 1
  .buffer                     resd 1
  .lba1                       resd 1
  .lba2                       resd 1
endstruc

use16
  jmp   start
  nop

%include 'utils.inc'

start:
  ; relocate ourselves
  cli                                     ; disable interrupts
  cld                                     ; clear direction flag
  mov   ax, STAGE1_START_SEGMENT
  mov   ds, ax                            ; set source segment
  mov   [boot_device], dl                 ; save drive number
  mov   ah, 0x00                          ; set video mode function, clear screen
  mov   al, 0x02                          ; 80x25
  int   0x10                              ; video services interrupt
  mov   ax, STAGE1_TARGET_SEGMENT
  mov   es, ax                            ; set destination segment
  xor   si, si                            ; zero source index
  xor   di, di                            ; zero destination index
  mov   cx, STAGE1_SIZE                   ; set size
  shr   cx, 1                             ; we're moving words, so div by 2
  rep   movsw

  ; jump to the place we've been relocated and continue from there
  push  STAGE1_TARGET_SEGMENT             ; our desired code segment
  push  relocated                         ; our desired code pointer
  retf                                    ; pops cs:cp and do a far return

relocated:
  ; set data segment
  push  cs
  pop   ds

  ; setup stack
  mov   ax, STACK_START
  mov   ss, ax                            ; set stack segment
  mov   sp, STACK_START + STACK_SIZE      ; 4KB stack

  mov   si, loader_start_msg
  call  print_string

  call  find_active_partition
  call  load_stage2

  call  cpu_hang

find_active_partition:
  pusha
  xor   cx, cx                            ; set current partition index to zero
  mov   bx, 0x1be                         ; offset to the partition table
.try:
  mov   al, [bx]
  cmp   al, 0x80                          ; is partition active?
  je    .done                             ; we're done
  add   bx, 0x10                          ; try next partition
  inc   cx                                ; increment current partition index
  cmp   cx, 0x04                          ; are we out of partitions?
  je    .error
  jmp   .try
.error:
  mov   si, error_msg
  call  print_string
  mov   si, no_active_partition_msg
  call  print_string
  call  cpu_hang
.done:
  mov   [active_partition], bx            ; save active partition offset
  add   bx, 0x08                          ; offset to partition's start sector
  mov   ax, [bx]
  mov   word [first_partition_sector], ax
  popa
  ret

load_stage2:
  call  get_disk_geometry
  call  read_sectors

  mov   dl, [boot_device]                 ; restore boot drive number
  xor   ax, ax
  mov   ds, ax                            ; zero data segment
  mov   ax, STAGE1_TARGET_ADDRESS
  add   ax, [active_partition]
  mov   si, ax                            ; set ds:si to active partition in mbr

  ; jump to the loaded stage2 and continue from there
  xor   di, di
  push  di                                ; our desired code segment
  push  STAGE2_START_ADDRESS              ; our desired code pointer
  retf                                    ; pops cs:cp and do a far return

get_disk_geometry:
  pusha
  xor   di, di                            ; zero destination index
  mov   dl, [boot_device]                 ; set drive number
  mov   ah, 0x08                          ; get drive geometry function
  int   0x13                              ; disk services interrupt
  jnc   .save_geometry
  mov   si, error_msg
  call  print_string
  mov   si, error_disk_geometry_msg
  call  print_string
  call  cpu_hang
.save_geometry:
  mov   [sectors_per_track], cl           ; sectors count is in bits 0-5
  and   byte [sectors_per_track], 0x3f    ; bits 6-7 belongs to cylinders
  mov   [cylinders], cl                   ; calculate cylinders
  xor   byte [cylinders], 0x3f
  shl   word [cylinders], 2
  or    [cylinders], ch
  mov   byte [heads], dh                  ; get heads
  popa
  ret

read_sectors:
  pusha
  mov   bx, [first_partition_sector]      ; set partition's start sector in dap
  mov   word [dap + DAP.lba1], bx
  mov   ah, 0x42                          ; extended read sectors function
  mov   dl, [boot_device]                 ; set boot drive number
  mov   si, dap                           ; dap's address
  int   0x13                              ; disk services interrupt
  popa
  ret

loader_start_msg        db  'Loading..', 13, 10, 0
error_msg               db  'ERROR: ', 0
no_active_partition_msg db  'no active partition', 13, 10, 0
error_disk_geometry_msg db  'disk geometry', 13, 10, 0
cylinders               dw  0
heads                   db  0
sectors_per_track       db  0
first_partition_sector  dw  0
boot_device             db  0
active_partition        dw  0
dap:
istruc DAP
  at DAP.size,          db 0x10
  at DAP.zero,          db 0
  at DAP.no_of_sectors, dw 2
  at DAP.buffer,        dd STAGE2_START_ADDRESS
  at DAP.lba1,          dd 0
  at DAP.lba2,          dd 0
iend

times MAX_BOOT_CODE_SIZE - ($ - $$)  db  0

