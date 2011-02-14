ENTRY(loader)

SECTIONS {
  . = 0x100000;

  .text ALIGN(0x1000) : {
    *(.text)
    *(.gnu.linkonce.t.*)
  }

  .rodata ALIGN(0x1000) : {
    start_ctors = .;
    *(.ctor*)
    end_ctors = .;

    start_dtors = .;
    *(.dtor*)
    end_dtors = .;

    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
  }

  .data ALIGN(0x1000) : {
    *(.data)
    *(.gnu.linkonce.d.*)
  }

  .bss ALIGN(0x1000) : {
    start_bss = .;
    *(.COMMON)
    *(.bss)
    *(.gnu.linkonce.b.*)
	end_bss = .;
  }

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame)
  }
}
