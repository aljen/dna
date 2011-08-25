////////////////////////////////////////////////////////////////////////////////
// File: writebootloader.c
// Copyright (c) 2011, Artur Wyszyñski <artur.wyszynski@hitomi.pl>
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
// * Neither the name of Artur Wyszyñski nor the names of its contributors
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
#define LOADER_SIZE 446

int main(int argc, const char **argv)
{
  mbr_t mbr;
  FILE *image = NULL, *loader = NULL;
  uint8_t loaderBuffer[LOADER_SIZE];
  size_t count = 0;

  if (argc < 3) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "%s <disk.vhd> <loader.bin>\n", argv[0]);
    return EXIT_FAILURE;
  }

  memset(&mbr, 0, MBR_SIZE);
  memset(&loaderBuffer, 0, LOADER_SIZE);

  image = fopen(argv[1], "r+b");
  if (!image) {
    fprintf(stderr, "Can't open %s!\n", argv[1]);
    return EXIT_FAILURE;
  }

  loader = fopen(argv[2], "rb");
  if (!loader) {
    fclose(image);
    fprintf(stderr, "Can't open %s!\n", argv[2]);
    return EXIT_FAILURE;
  }

  count = fread(&mbr, 1, MBR_SIZE, image);
  if (count != MBR_SIZE) {
    fclose(image);
    fclose(loader);
    fprintf(stderr, "Wrong MBR size (%d), should be %d!\n", count, MBR_SIZE);
    return EXIT_FAILURE;
  }

  if (mbr.signature[1] != 0xaa && mbr.signature[0] != 0x55) {
    fclose(image);
    fclose(loader);
    fprintf(stderr, "Wrong MBR signature (0x%2x%2x), should be 0x%2x%2x!\n",
      count, mbr.signature[1], mbr.signature[0], 0xaa, 0x55);
    return EXIT_FAILURE;
  }
  
  count = fread(&loaderBuffer, 1, LOADER_SIZE, loader);
  if (count != LOADER_SIZE) {
    fclose(image);
    fclose(loader);
    fprintf(stderr, "Wrong loader size (%d), should be %d!\n", count,
      LOADER_SIZE);
    return EXIT_FAILURE;
  }
  fclose(loader);

  memcpy(&mbr.code, &loaderBuffer, LOADER_SIZE);

  fseek(image, 0, SEEK_SET);
  count = fwrite(&mbr, MBR_SIZE, 1, image);
  if (count != 1) {
    fclose(image);
    fprintf(stderr, "Can't write MBR!\n");
    return EXIT_FAILURE;
  }

  fclose(image);
}
