;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: stage2.S
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

; [map symbols stage2.map]

; SB    - ext2_superblock_t
; BGD   - ext2_block_group_desc_t
; IN    - ext2_inode_t
; DE    - ext2_dir_entry_t
; SS    - SECTOR_SIZE
; BS    - block size
; FPS   - first partition sector

%assign BUFFER1                     0x500
%assign BUFFER2                     0x8000
%define EXT2_MAGIC                  0xef53
%define SECTOR_SIZE                 0x200
%define SB_OFFSET                   0x02
%define SB_BLOCK_SIZE_OFFSET        0x18
%define SB_INODES_PER_GROUP_OFFSET  0x28
%define SB_MAGIC_OFFSET             0x38
%define SB_INODE_SIZE_OFFSET        0x58
%define GD_INODE_TABLE_OFFSET       0x08
%define IN_MODE_OFFSET              0x00
%define IN_SIZE_OFFSET              0x04
%define IN_BLOCKS_OFFSET            0x1c
%define IN_BLOCK_DATA_OFFSET        0x28
%define DE_INODE_OFFSET             0x00
%define DE_REC_LEN_OFFSET           0x04
%define DE_NAME_LEN_OFFSET          0x06
%define DE_NAME_OFFSET              0x08
%define EXT2_S_IFDIR                0x4000

%define SB_SIZE                     0x02
%define GD_SIZE                     0x20
%define ROOT_INODE                  0x02

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
org 0x7c00
main:
  jmp   0x0000:start

%include 'utils.inc'

start:
  cli                                     ; disable interrupts
  cld                                     ; clear direction flag

  xor   ax, ax
  mov   ds, ax
  mov   es, ax
  mov   fs, ax
  mov   gs, ax

  mov   [boot_device], dl                 ; save boot device
  mov   [first_partition_sector], si      ; ds:si points to an active partition
                                          ; entry in mbr

  ; setup stack
  mov   ss, ax
  mov   sp, main

  mov   si, loader_msg
  call  print_string
  jmp   continue

error:
  mov   si, error_msg
  call  print_string
  call  cpu_hang

continue:
  ; read ext2 SB
  mov   si, [first_partition_sector]      ; pointer to active partition in mbr
  add   si, 0x08                          ; offset to the FPS field
  mov   ax, [si]
  mov   [first_partition_sector], ax      ; FPS now holds
                                          ; partition's first sector number
  add   ax, SB_OFFSET                     ; offset to SB start sector
  mov   [sector], ax
  mov   bx, 2                             ; SB size is 2 * SS
  mov   di, BUFFER2
  call  read_sectors

  ; parse ext2 SB
  mov   ax, [BUFFER2 + SB_MAGIC_OFFSET]   ; load SB magic
  cmp   ax, EXT2_MAGIC                    ; compare with ext2 SB magic
  je    .magic_ok                         ; is SB magic correct ?
  jmp   error
.magic_ok:
  mov   eax, [BUFFER2 + SB_INODES_PER_GROUP_OFFSET]  ; get IPG
  mov   [inodes_per_group], eax
  mov   eax, [BUFFER2 + SB_INODE_SIZE_OFFSET]        ; get IN size
  mov   [inode_size], eax
  mov   eax, 1024                                    ; calculate BS
  mov   cl, [BUFFER2 + SB_BLOCK_SIZE_OFFSET]         ; BS = 1024 << size
  shl   eax, cl
  mov   [block_size], ax

  mov   bx, SECTOR_SIZE
  xor   dx, dx
  div   bx
  mov   [block_size_in_sectors], ax

  mov   eax, ROOT_INODE                   ; first, load root inode
  call  load_inode
  mov   di, BUFFER2
  call  load_data_blocks                  ; load inode's DE entries
  mov   si, loader_directory
  mov   bx, 6
  call  find_entry                        ; find "System" directory

  mov   eax, [inode]                      ; load "System" inode
  call  load_inode
  mov   di, BUFFER2
  call  load_data_blocks                  ; load inode's DE entries
  mov   si, loader_filename
  mov   bx, 6
  call  find_entry                        ; find "loader" files

  mov   eax, [inode]                      ; load "loader" inode
  call  load_inode
  mov   di, BUFFER2
  call  load_data_blocks

  xor   ax, ax
  mov   ds, ax
  mov   di, ax
  push  di                                ; our desired code segment
  push  BUFFER2                           ; our desired code pointer
  retf                                    ; pops cs:cp and do a far return

; convert block to sector, block number stored in eax
block_to_sector:
  pusha
  mov   ebx, [block_size]                 ; sector = block_nr * BS
  mul   ebx
  mov   ebx, SECTOR_SIZE                  ; sector = sector / SS
  xor   edx, edx
  div   ebx
  mov   [sector], eax                     ; save it
  popa
  ret

; load inode, inode number stored in eax
load_inode:
  pusha
  dec   eax                               ; inode = inode -1
  mov   ecx, [inodes_per_group]           ; calculate block group & index
  xor   edx, edx
  div   ecx
  mov   [inode_block_group], eax          ; group = inode / IPG
  mov   [inode_index], edx                ; index = inode % IPG

  ; read inode's BGD
  mov   eax, [inode_block_group]          ; calculate sector & offset
  mov   ebx, GD_SIZE                      ; offset = inode_block_group * GD_SIZE
  mul   ebx
  xor   edx, edx
  mov   ebx, SECTOR_SIZE                  ; sector = offset / SS
  div   ebx
  mov   [offset], edx                     ; offset = offset % SS
  mov   ebx, dword [first_partition_sector]
  and   ebx, 0x0000ffff                   ; sector += FPS
  add   eax, ebx
  add   eax, SB_SIZE                      ; sector += 1 block = SB
  add   eax, SB_SIZE                      ; sector += 1 block = BGD
  mov   [sector], eax
  mov   bx, 1                             ; read only one sector
  mov   di, BUFFER1
  call  read_sectors

  ; load actual IN
  mov   si, [offset]                      ; load block number of inode
  mov   eax, [BUFFER1 + si + GD_INODE_TABLE_OFFSET]
  call  block_to_sector                   ; conver to sector number

  mov   eax, dword [first_partition_sector]
  and   eax, 0x0000ffff                   ; sector += FPS
  add   eax, [sector]
  mov   [sector], eax

  mov   eax, [inode_size]                 ; offset = inode_size * inode_index
  mov   ebx, [inode_index]
  mul   ebx
  xor   edx, edx
  mov   ebx, SECTOR_SIZE                  ; sector += offset / SS
  div   ebx                               ; offset = offset % SS
  add   eax, [sector]
  mov   [sector], eax
  mov   [offset], edx

  mov   bx, 1                             ; read only one sector
  mov   di, BUFFER1
  call  read_sectors

  mov   si, [offset]
  mov   ax, [BUFFER1 + si + IN_MODE_OFFSET]
  mov   [mode], ax                        ; save inode's mode
  mov   eax, [BUFFER1 + si + IN_SIZE_OFFSET]
  mov   [size], eax                       ; save inode's size
  mov   eax, [BUFFER1 + si + IN_BLOCKS_OFFSET]
  dec   eax
  mov   [blocks], eax                     ; save inode's number of blocks

  popa
  ret

; loads inode's data blocks
; BUFFER1   - must point to already readed IN
; [offset]  - offset to IN structure
; di        - destination buffer
load_data_blocks:
  pusha
  mov   si, BUFFER1                       ; inode's data is in BUFFER1
  add   si, [offset]                      ; offset to actual IN structure
  add   si, IN_BLOCK_DATA_OFFSET          ; offset to data blocks fields

  xor   cx, cx                            ; zero counter
  xor   dx, dx                            ; zero destination buffer offset
.read_block:
  mov   eax, [si]                         ; load sector number from data block
  cmp   eax, 0                            ; if it's zero, we're done
  je    .done
  call  block_to_sector                   ; convert it to sector number
  mov   eax, dword [first_partition_sector]
  and   eax, 0x0000ffff                   ; sector += FPS
  add   eax, [sector]
  mov   [sector], eax                     ; save it

  mov   bx, [block_size_in_sectors]       ; read BS in sectors
  call  read_sectors                      ; read data block from disk
  cmp   cx, [blocks]                      ; do we read all blocks?
  je    .done
  add   si, 4                             ; if not, offset to next data block
  add   di, [block_size]                  ; buffer = buffer + BS
  inc   cx                                ; increase counter
  jmp   .read_block
.done:
  popa
  ret

; find an entry in BUFFER2
; [mode]    - must be a directory
; BUFFER2   - must point to already readed DE entries from IN
; bx        - entry length
; si        - entry to find
find_entry:
  pusha
  mov   ax, [mode]                        ; check if current IN is a dir
  and   ax, EXT2_S_IFDIR
  cmp   ax, EXT2_S_IFDIR
  je    .is_dir                           ; if it's not, print error & halt
  jmp   error

.is_dir:
  xor   di, di                            ; di is offset in dir entries, zero it
  xor   cx, cx

.next_entry:
  cmp   cx, bx                            ; are we done?
  je    .done
  mov   ax, [BUFFER2 + di + DE_REC_LEN_OFFSET]
  cmp   ax, 0                             ; we're done if rec_len is zero
  je    .done

  mov   dx, [BUFFER2 + di + DE_NAME_LEN_OFFSET]
  and   dx, 0x00ff                        ; get current DE's name length

  cmp   dx, bx                            ; if name_len != entry_len, skip it
  jne   .search_done

  mov   ebx, [BUFFER2 + di + DE_INODE_OFFSET]
  mov   [inode], ebx                      ; save inode number

  add   di, BUFFER2                       ; offse to name's first letter
  add   di, DE_NAME_OFFSET

  mov   cx, dx
  pusha
  repe  cmpsb
  popa
  je   .done

.search_done:
  add   di, ax                            ; increase offset by rec_len
  jmp   .next_entry
.done
  popa
  ret

; read sectors, using extended sectors read bios function
; [sector]  - start from this sector
; bx        - number of sectors to read
; di        - destination buffer address
read_sectors:
  pusha
  mov   eax, [sector]                     ; start reading from sector
  mov   [dap + DAP.lba1], eax
  mov   word [dap + DAP.no_of_sectors], bx
  mov   word [dap + DAP.buffer], di
  mov   ah, 0x42                          ; extended read sectors function
  mov   dl, [boot_device]                 ; set boot drive number
  mov   si, dap                           ; dap's address
  int   0x13                              ; disk services interrupt
  jnc  .done
  jmp   error
.done:
  popa
  ret

loader_msg              db  'Loading Hitomi..', 13, 10, 0
error_msg               db  'ERROR!', 0
loader_directory        db  'System'
loader_filename         db  'loader'
boot_device             db  0
first_partition_sector  dw  0
block_size              dd  0
block_size_in_sectors   dw  0
num_of_block_groups     dd  0
inodes_per_group        dd  0
inode_size              dd  0
inode                   dd  0
sector                  dd  0
offset                  dd  0
mode                    dw  0
size                    dd  0
blocks                  dw  0
inode_block_group       dd  0
inode_index             dd  0
dap:
istruc DAP
  at DAP.size,          db 0x10
  at DAP.zero,          db 0
  at DAP.no_of_sectors, dw 1
  at DAP.buffer,        dd 0
  at DAP.lba1,          dd 0
  at DAP.lba2,          dd 0
iend

times 1024 - ($ - $$)  db  0
