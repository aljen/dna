#!/bin/bash
export PATH=$PATH:"/c/Program Files (x86)/Bochs-2.4.5/"
echo "Type in bochs:"
echo "kernel 200+30"
echo "boot"
bochs -q -f image/bochsrc.bxrc