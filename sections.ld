MEMORY {
    rom (rwx) : ORIGIN = 0x01000000, LENGTH = 0x00000400
    ram (rw)  : ORIGIN = 0x01000400, LENGTH = 0x00000400
}

SECTIONS {
    .text : {
        . = ALIGN(4);
        KEEP(*(.init)) /* Reset vector / initialization code */
        . = ALIGN(4);
        *(.text*)   /* Program code */
        . = ALIGN(4);
        *(.rodata*) /* Read-only data */
        . = ALIGN(4);
    } >rom

    /* C++ Static constructors/destructors, also used for __attribute__
     * ((constructor)) and the likes */
    .preinit_array : {
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;
    } >rom
    .init_array : {
        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;
    } >rom
    .fini_array : {
        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;
    } >rom

    . = ALIGN(4);
    _etext = .;

    .data : {
        _data = .;
        *(.data*)   /* Read-write initialized data */
        . = ALIGN(4);
        __global_pointer$ = . + 0x800;
        *(.sdata*)
        . = ALIGN(4);
        _edata = .;
    } >ram AT >rom
    _data_loadaddr = LOADADDR(.data);

    .bss : {
        *(.sbss*)
        . = ALIGN(4);
        *(.bss*)    /* Read-write zero initialized data */
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } >ram

    /*
     * The .eh_frame section appears to be used for C++ exception handling.
     * You may need to fix this if you're using C++.
     */
    /DISCARD/ : { *(.eh_frame) }

    . = ALIGN(4);
    end = .;
}

PROVIDE(_stack = ORIGIN(ram) + LENGTH(ram));
