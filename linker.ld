ENTRY(_c_int00)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 2M
  RAM   (rwx) : ORIGIN = 0x08000000, LENGTH = 512K
}

SECTIONS
{
  /* Interrupt vector table (MUST be first) */
  .intvecs :
  {
    KEEP(*(.intvecs))  /* This ensures HALCoGen vector table gets pulled */
  } > FLASH

  /* Code and read-only data */
  .text :
  {
    *(.text*)
    *(.rodata*)
    _sidata = .;  /* LMA for .data */
  } > FLASH

  /* Initialized data in RAM, loaded from FLASH (_sidata) */
  .data : AT(_sidata)
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM

  /* Uninitialized data */
  .bss :
  {
    __bss_start__ = .;
    *(.bss*)
    *(COMMON)
    __bss_end__ = .;
  } > RAM

  .stack (COPY) :
  {
    *(.stack*)
  } > RAM

  _end = .;
}

/* Required by newlib/newlib stubs */
PROVIDE(_exit = 0);
PROVIDE(_fini = 0);
