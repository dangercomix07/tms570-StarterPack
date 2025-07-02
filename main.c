#include "HL_sys_common.h"
#include "HL_gio.h"


void delay(void)
{
    volatile int i;
    for (i = 0; i < 500000; ++i)
    {
        __asm(" nop");  // Prevent optimization
    }
}

int main(void)
{
    gioInit();

    // Set GIOB pin 7 (User LED3 on ball F1) as output
    gioSetDirection(gioPORTB, 1 << 7);  // Sets only bit 7 as output

    while (1)
    {
        gioSetBit(gioPORTB, 7, 1);  // Turn LED ON
        delay();

        gioSetBit(gioPORTB, 7, 0);  // Turn LED OFF
        delay();
    }
    return 0;
}

void _exit(int status) {
    while (1);  // hang forever
}

void _fini() {}

void __libc_init_array() {}
void __libc_fini_array() {}