MEMORY
{
    sharedram(rwx)  : ORIGIN = 0x20000000, LENGTH = 256
    ram (rwx)       : ORIGIN = 0x20000100, LENGTH = 48K - LENGTH(sharedram)
    bl1 (rw)        : ORIGIN = 0x8000000, LENGTH = 36K
    app1 (rx)       : ORIGIN = 0x8009000, LENGTH = 44K
    app2 (rx)       : ORIGIN = 0x8014000, LENGTH = 44K
    commondata(rwx) : ORIGIN = 0x801F000, LENGTH = 4K
}

SECTIONS
{
    .shared_memory (NOLOAD) : {
        KEEP(*(.shared_memory))
    } >sharedram
}

SECTIONS
{
    .common_data (NOLOAD) :
    {
        KEEP(*(.common_data))
    } > commondata
}

__sharedram_start__ = ORIGIN(sharedram);
__sharedram_size__ = LENGTH(sharedram);
__bootloader_start__ = ORIGIN(bl1);
__bootloader_size__ = LENGTH(bl1);
__app1_start__ = ORIGIN(app1);
__app1_size__ = LENGTH(app1);
__app2_start__ = ORIGIN(app2);
__app2_size__ = LENGTH(app2);
__commondata_start__ = ORIGIN(commondata);
