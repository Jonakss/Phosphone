/* ~PHOSPHOR LINKER SCRIPT */
ENTRY(kmain)

MEMORY
{
    /* Definimos dónde carga el Bootloader de Samsung el payload de Recovery */
    /* Generalmente es 0x10008000 en dispositivos Marvell/Samsung de esa era */
    DDR_RAM (rwx) : ORIGIN = 0x10008000, LENGTH = 512M
}

SECTIONS
{
    . = 0x10008000;
    
    /* Código del Kernel */
    .text : { *(.text) } > DDR_RAM
    
    /* Datos estáticos */
    .data : { *(.data) } > DDR_RAM
    
    /* Variables vacías */
    .bss  : { *(.bss)  } > DDR_RAM
    
    /* Stack Pointer (16KB) */
    . = ALIGN(8);
    . = . + 0x4000; 
}