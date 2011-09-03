#! /usr/bin/env python
# encoding: utf-8
# Artur Wyszyński, 2011

import os, struct, sys, array, uuid, time

# vhd creation based on vhd specification from microsoft
def calculate_chs(total_sectors):
    max_cylinders = 65535
    max_heads = 16
    max_sectors_per_track1 = 255
    max_sectors_per_track2 = 63
    max_total_sectors1 = max_cylinders * max_heads * max_sectors_per_track1
    max_total_sectors2 = max_cylinders * max_heads * max_sectors_per_track2

    sectors = total_sectors
    cylinders = 0
    heads = 0
    sectors_per_track = 0
    cylinder_times_heads = 0

    if sectors > max_total_sectors1:
        sectors = max_total_sectors1

    if sectors >= max_total_sectors2:
        sectors_per_track = 255
        heads = 16
        cylinder_times_heads = sectors / sectors_per_track
    else:
        sectors_per_track = 17
        cylinder_times_heads = sectors / sectors_per_track

        heads = (cylinder_times_heads + 1023) / 1024

    if heads < 4:
        heads = 4

    if (cylinder_times_heads >= (heads * 1024)) or (heads > 16):
        sectors_per_track = 31
        heads = 16
        cylinder_times_heads = sectors / sectors_per_track

    if cylinder_times_heads >= (heads * 1024):
        sectors_per_track = 63
        heads = 16
        cylinder_times_heads = sectors / sectors_per_track

    cylinders = cylinder_times_heads / heads

    return (cylinders, heads, sectors_per_track)


def main():
    argc = len(sys.argv)
    if argc < 4:
        print 'Usage: %s <disk.vhd> <size MB> <mnt point>' % sys.argv[0]
        sys.exit(1)

    image_file = sys.argv[1]
    image_size = int(sys.argv[2])
    image_mnt = sys.argv[3]

    if os.path.isfile(image_file):
        sys.exit(0)

    vhd_footer_size = 512
    sector_size = 512
    vhd_be_format = '>8sIIQI4sI4sQQHBBIi16sB427s'

    requested_image_size = image_size * 1024 * 1024
    requested_total_sectors = requested_image_size / sector_size

    cylinders, heads, sectors_per_track = calculate_chs(requested_total_sectors)

    image_size = cylinders * sector_size * heads * sectors_per_track
    image_total_sectors = image_size / sector_size

    print('Requested image size: %d KB' % (requested_image_size / 1024))
    print('Rounded image size  : %d KB' % (image_size / 1024))
    print('Total sectors       : %d' % image_total_sectors)
    print('Cylinders           : %d' % cylinders)
    print('Heads               : %d' % heads)
    print('Sectors per track   : %d' % sectors_per_track)

    seconds_now = time.mktime(time.localtime())
    seconds_start = time.mktime(time.strptime('1 Jan 00 12', '%d %b %y %H'))
    seconds_since = seconds_now - seconds_start

    cookie = 'conectix'
    features = 0x2
    file_format_version = 0x10000
    data_offset = 0xffffffffffffffff
    time_stamp = seconds_since
    creator_application = 'dna '
    creator_version = 0x1000
    creator_host_os = 'DNA '
    original_size = image_size - vhd_footer_size
    current_size = image_size - vhd_footer_size
    disk_geometry_cylinder = cylinders
    disk_geometry_heads = heads
    disk_geometry_cylinder_sectors_per_track = sectors_per_track
    disk_type = 2
    checksum = 0
    unique_id = uuid.uuid4().bytes
    saved_state = 0
    reserved = ''

    vhd_footer = struct.pack(vhd_be_format, cookie, features, file_format_version,
        data_offset, time_stamp, creator_application, creator_version,
        creator_host_os, original_size, current_size, disk_geometry_cylinder,
        disk_geometry_heads, disk_geometry_cylinder_sectors_per_track, disk_type,
        checksum, unique_id, saved_state, reserved)

    bytes_array = array.array('B', vhd_footer)
    for i in range(len(vhd_footer)):
        checksum = checksum + bytes_array[i]
    checksum = ~checksum

    vhd_footer = struct.pack(vhd_be_format, cookie, features, file_format_version,
        data_offset, time_stamp, creator_application, creator_version,
        creator_host_os, original_size, current_size, disk_geometry_cylinder,
        disk_geometry_heads, disk_geometry_cylinder_sectors_per_track, disk_type,
        checksum, unique_id, saved_state, reserved)

    print('Checksum            : %d' % checksum)
    print('Footer length       : %d' % len(vhd_footer))

    image = open(image_file, 'w')
    image.truncate(image_size)
    image.seek(image_size - vhd_footer_size, os.SEEK_SET)
    image.write(vhd_footer)
    image.close()

    cmd = """sfdisk -C{0} -H{1} -S{2} -uS {3} > /dev/null << EOF
1,,,*
;
;
;
EOF""".format(cylinders, heads, sectors_per_track, image_file)
    os.system(cmd)

    cmd = 'mkdir -p %s' % image_mnt
    os.system(cmd)

    cmd = 'losetup /dev/loop0 -o 512 %s' % image_file
    os.system(cmd)

    cmd = 'sleep 1'
    os.system(cmd)

    cmd = 'mkfs.ext2 /dev/loop0 > /dev/null'
    os.system(cmd)

    cmd = 'sleep 1'
    os.system(cmd)

    cmd = 'losetup -d /dev/loop0'
    os.system(cmd)

if __name__ == "__main__":
    main()

