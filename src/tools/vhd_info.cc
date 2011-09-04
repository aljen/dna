////////////////////////////////////////////////////////////////////////////////
// File: vhd_info.c
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

#include <cstdlib>
#include <iostream>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <string.h>

#ifdef _MSC_VER
#  define PACKED(x) __pragma(pack(push, 1)) x __pragma(pack(pop))
#else
#  define PACKED(x) x __attribute__((packed))
#endif

#define GET_SECTOR(sector)              (sector & 0x3f)
#define GET_CYLINDER(sector, cylinder)  (((sector ^ 0x3f) << 2) | cylinder)


typedef struct disk_geometry_t {
  uint16_t cylinder;
  uint8_t heads;
  uint8_t sectors_per_track;
} disk_geometry_t;


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


PACKED(
struct mbr_t {
    uint8_t code[446];
    mbr_entry_t partitions[4];
    uint8_t signature[2];
}
);

typedef struct mbr_t mbr_t;


void calculate_chs(disk_geometry_t &geometry, int64_t total_sectors);
void print_partition(const mbr_t &mbr, uint8_t index);

void calculate_chs(disk_geometry_t &geometry, int64_t total_sectors)
{
  const uint16_t CYLINDERS = 65535;
  const uint8_t HEADS = 16;
  const uint8_t SECTORS1 = 255;
  const uint8_t SECTORS2 = 63;
  const int64_t TOTAL_SECTORS1 = CYLINDERS * HEADS * SECTORS1;
  const int64_t TOTAL_SECTORS2 = CYLINDERS * HEADS * SECTORS2;

  uint8_t sectors_per_track = 0;
  uint8_t heads = 0;
  int64_t cylinder_times_heads = 0;
  uint16_t cylinders = 0;

  if (total_sectors > TOTAL_SECTORS1)
    total_sectors = TOTAL_SECTORS1;

  if (total_sectors >= TOTAL_SECTORS2) {
    sectors_per_track = 255;
    heads = 16;
    cylinder_times_heads = total_sectors / sectors_per_track;
  } else {
    sectors_per_track = 17;
    cylinder_times_heads = total_sectors / sectors_per_track;

    heads = (uint8_t)((cylinder_times_heads + 1023) / 1024);

    if (heads < 4)
      heads = 4;

    if (cylinder_times_heads >= (heads * 1024) || heads > 16) {
      sectors_per_track = 31;
      heads = 16;
      cylinder_times_heads = total_sectors / sectors_per_track;
    }

    if (cylinder_times_heads >= (heads * 1024)) {
      sectors_per_track = 63;
      heads = 16;
      cylinder_times_heads = total_sectors / sectors_per_track;
    }
  }

  cylinders = (uint16_t)(cylinder_times_heads / heads);

  geometry.cylinder = cylinders;
  geometry.heads = heads;
  geometry.sectors_per_track = sectors_per_track;
}

void print_partition(const mbr_t &mbr, uint8_t index)
{
  const uint8_t status = mbr.partitions[index].status;
  const uint8_t start_head = mbr.partitions[index].start_head;
  const uint8_t start_sector = mbr.partitions[index].start_sector;
  const uint8_t start_cylinder = mbr.partitions[index].start_cylinder;
  const uint8_t type = mbr.partitions[index].type;
  const uint8_t end_head = mbr.partitions[index].end_head;
  const uint8_t end_sector = mbr.partitions[index].end_sector;
  const uint8_t end_cylinder = mbr.partitions[index].end_cylinder;
  const uint32_t lba_of_first_sector = mbr.partitions[index].lba_of_first_sector;
  const uint32_t number_of_sectors = mbr.partitions[index].number_of_sectors;

  if (mbr.partitions[index].type != 0) {
    if (index != 3) {
      fprintf(stderr, " |-.[ partition #%d:\n", index);
      fprintf(stderr, " | `.[ status               : 0x%02x (%3d)\n", status,
        status);
      fprintf(stderr, " |  |-[ type                : 0x%02x (%3d)\n", type,
        type);
      fprintf(stderr, " |  |-[ start head          : 0x%02x (%3d)\n",
        start_head, start_head);
      fprintf(stderr, " |  |-[ start sector        : 0x%02x (%3d)\n",
        GET_SECTOR(start_sector), GET_SECTOR(start_sector));
      fprintf(stderr, " |  |-[ start cylinder      : 0x%02x (%3d)\n",
        GET_CYLINDER(start_sector, start_cylinder), GET_CYLINDER(start_sector,
        start_cylinder));
      fprintf(stderr, " |  |-[ end head            : 0x%02x (%3d)\n", end_head,
        end_head);
      fprintf(stderr, " |  |-[ end sector          : 0x%02x (%3d)\n",
        GET_SECTOR(end_sector), GET_SECTOR(end_sector));
      fprintf(stderr, " |  |-[ end cylinder        : 0x%02x (%3d)\n",
        GET_CYLINDER(end_sector, end_cylinder), GET_CYLINDER(end_sector,
        end_cylinder));
      fprintf(stderr, " |  |-[ lba of first sector : 0x%02x (%3d)\n",
        lba_of_first_sector, lba_of_first_sector);
      fprintf(stderr, " |  `-[ number of sectors   : 0x%02x (%3d)\n",
        number_of_sectors, number_of_sectors);
    } else {
      fprintf(stderr, " `-.[ partition #%d:\n", index);
      fprintf(stderr, "   `.[ status               : 0x%02x (%3d)\n", status,
        status);
      fprintf(stderr, "    |-[ type                : 0x%02x (%3d)\n", type,
        type);
      fprintf(stderr, "    |-[ start head          : 0x%02x (%3d)\n",
        start_head, start_head);
      fprintf(stderr, "    |-[ start sector        : 0x%02x (%3d)\n",
        GET_SECTOR(start_sector), GET_SECTOR(start_sector));
      fprintf(stderr, "    |-[ start cylinder      : 0x%02x (%3d)\n",
        GET_CYLINDER(start_sector, start_cylinder), GET_CYLINDER(start_sector,
        start_cylinder));
      fprintf(stderr, "    |-[ end head            : 0x%02x (%3d)\n", end_head,
        end_head);
      fprintf(stderr, "    |-[ end sector          : 0x%02x (%3d)\n",
        GET_SECTOR(end_sector), GET_SECTOR(end_sector));
      fprintf(stderr, "    |-[ end cylinder        : 0x%02x (%3d)\n",
        GET_CYLINDER(end_sector, end_cylinder), GET_CYLINDER(end_sector,
        end_cylinder));
      fprintf(stderr, "    |-[ lba of first sector : 0x%02x (%3d)\n",
        lba_of_first_sector, lba_of_first_sector);
      fprintf(stderr, "    `-[ number of sectors   : 0x%02x (%3d)\n",
        number_of_sectors, number_of_sectors);
    }
  } else {
    if (index != 3)
      fprintf(stderr, " |-[ partition #%d (empty)\n", index);
	else
      fprintf(stderr, " `-[ partition #%d (empty)\n", index);
  }
}

int main(int argc, const char **argv)
{
  if (argc < 2) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "%s <disk.vhd>\n", argv[0]);
    return EXIT_FAILURE;
  }

  const char *image_name = argv[1];

  mbr_t mbr;
    memset(&mbr, 0, sizeof(mbr));

  FILE *image = fopen(image_name, "rb");
  if (image == NULL) {
    fprintf(stderr, "%s: ERROR: Can't open image!\n", image_name);
    return EXIT_FAILURE;
  }

  size_t count = fread(&mbr, 1, sizeof(mbr), image);
  if (count != sizeof(mbr)) {
    fclose(image);
    fprintf(stderr, "%s: ERROR: Can't read MBR!\n", image_name);
    return EXIT_FAILURE;
  }

  if (mbr.signature[1] != 0xaa && mbr.signature[0] != 0x55) {
    fprintf(stderr, "%s: WARNING: MBR boot signature should be 0xaa55!\n",
      image_name);
  }

  fseek(image, 0, SEEK_END);
  int64_t image_size = ftell(image);

  const uint16_t sector_size = 512;
  int64_t total_sectors = image_size / sector_size;
  disk_geometry_t geometry;
  calculate_chs(geometry, total_sectors);

  fprintf(stderr, "%s [cylinders: %d] [heads: %d] [spt: %d] [sectors: %ld]\n",
    image_name, geometry.cylinder, geometry.heads, geometry.sectors_per_track,
    total_sectors);
  fprintf(stderr, "[*] Partitions table (boot signature: 0x%02x%02x)\n",
    mbr.signature[1], mbr.signature[0]);
  print_partition(mbr, 0);
  print_partition(mbr, 1);
  print_partition(mbr, 2);
  print_partition(mbr, 3);

  fclose(image);

  return EXIT_SUCCESS;
}

