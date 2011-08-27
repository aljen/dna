////////////////////////////////////////////////////////////////////////////////
// File: writebootloader.c
// Copyright (c) 2011, Artur Wyszyński <artur.wyszynski@hitomi.pl>
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

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#ifdef _MSC_VER
#  define PACKED(x) __pragma(pack(push, 1)) x __pragma(pack(pop))
#else
#  define PACKED(x) x __attribute__((packed))
#endif

#define GET_SECTOR(sector)              (sector & 0x3f)
#define GET_CYLINDER(sector, cylinder)  (((sector ^ 0x3f) << 2) | cylinder)

PACKED(
typedef struct mbr_entry_t {
    uint8_t status;
    uint8_t start_head;
    uint8_t start_sector;
    uint8_t start_cylinder;
    uint8_t type;
    uint8_t end_head;
    uint8_t end_sector;
    uint8_t end_cylinder;
    uint32_t lba_of_first_sector;
    uint32_t number_of_sectors;
} mbr_entry_t;
)

PACKED(
typedef struct mbr_t {
    uint8_t code[446];
    mbr_entry_t partitions[4];
    uint8_t signature[2];
} mbr_t;
)

#define MBR_SIZE    512
#define SECTOR_SIZE 512
#define STAGE1_SIZE 446   // MBR's code block size
#define STAGE2_SIZE 1024  // ext2 has free 2 sectors for VBR before superblock

int32_t load_stage(const char *filename, void *buffer, size_t max_size)
{
  int32_t ret = -1;
  size_t size = 0;
  FILE *file = fopen(filename, "rb");

  fprintf(stderr, "Loading %s\n", filename);

  if (!file) {
    fprintf(stderr, "Can't open %s!\n", filename);
    return ret;
  }

  fseek(file, 0, SEEK_END);
  size = ftell(file);
  fseek(file, 0, SEEK_SET);

  if (size != max_size) {
    fclose(file);
    fprintf(stderr, "%s has wrong size, should be %d!\n", filename, max_size);
    return ret;
  }

  ret = fread(buffer, 1, max_size, file);
  fclose(file);
  
  return ret;
}

int32_t write_stage(FILE *file, int32_t offset, const void *src, size_t max_size)
{
  fseek(file, offset, SEEK_SET);
  return fwrite(src, max_size, 1, file);
}

int main(int argc, const char **argv)
{
  mbr_t mbr;
  size_t count = 0;
  FILE *image = NULL;
  uint8_t stage1Buffer[STAGE1_SIZE];
  uint8_t stage2Buffer[STAGE2_SIZE];
  int8_t activePartition = -1;
  uint32_t offset = 0;
  uint32_t sector = 0;
  uint8_t type = 0;
  int8_t i = 0;

  if (argc < 4) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "%s <disk.vhd> <stage1.bin> <stage2.bin>\n", argv[0]);
    return EXIT_FAILURE;
  }

  memset(&mbr, 0, MBR_SIZE);
  memset(&stage1Buffer, 0, STAGE1_SIZE);
  memset(&stage2Buffer, 0, STAGE2_SIZE);

  if (load_stage(argv[2], &stage1Buffer, STAGE1_SIZE) < 0)
    return EXIT_FAILURE;
  
  if (load_stage(argv[3], &stage2Buffer, STAGE2_SIZE) < 0)
    return EXIT_FAILURE;

  fprintf(stderr, "Opening %s\n", argv[1]);
  image = fopen(argv[1], "r+b");
  if (!image) {
    fprintf(stderr, "Can't open %s!\n", argv[1]);
    return EXIT_FAILURE;
  }

  count = fread(&mbr, 1, MBR_SIZE, image);
  if (count != MBR_SIZE) {
    fclose(image);
    fprintf(stderr, "Can't read MBR from %s!\n", argv[1]);
    return EXIT_FAILURE;
  }

  if (mbr.signature[1] != 0xaa && mbr.signature[0] != 0x55) {
    fclose(image);
    fprintf(stderr, "Wrong MBR boot signature, should be 0x%2x%2x!\n", 0xaa,
      0x55);
    return EXIT_FAILURE;
  }

  for (i = 0; i < 4; i++) {
    if (mbr.partitions[i].status == 0x80) {
      activePartition = i;
      break;
    }
  }

  if (activePartition == -1) {
    fclose(image);
    fprintf(stderr, "Can't find an active partition!\n");
    return EXIT_FAILURE;
  }

  type = mbr.partitions[activePartition].type;
  sector = mbr.partitions[activePartition].lba_of_first_sector;
  offset = sector * SECTOR_SIZE;
  
  fprintf(stderr, "Found active partition: %d\n", activePartition);
  fprintf(stderr, "Partition type        : 0x%x (%d)\n", type, type);
  fprintf(stderr, "First sector          : 0x%x (%d)\n", sector, sector);
  fprintf(stderr, "VBR's offset          : 0x%x (%d)\n", offset, offset);

  fprintf(stderr, "Writing stage1 loader to MBR\n");
  write_stage(image, 0, &stage1Buffer, STAGE1_SIZE);

  fprintf(stderr, "Writing stage2 loader to active partition's VBR\n");
  write_stage(image, offset, &stage2Buffer, STAGE2_SIZE);

  fclose(image);
}
