#include "HL_sys_common.h"
#include "HL_gio.h"

void delay(void)
{
    volatile int i;
    for (i = 0; i < 1000000; ++i)
    {
        __asm(" nop");  // Prevent optimization
    }
}


int main(void)
{
    // Initialize GIO module (calls muxInit inside)
    gioInit();

    // Set GIOB pins 7 and 6 as outputs
    gioSetDirection(gioPORTB, (1 << 7) | (1 << 6));

    while (1)
    {
        // Turn GIOB7 ON and GIOB6 OFF
        gioSetBit(gioPORTB, 7, 1);
        gioSetBit(gioPORTB, 6, 0);
        delay();

        // Turn GIOB7 OFF and GIOB6 ON
        gioSetBit(gioPORTB, 7, 0);
        gioSetBit(gioPORTB, 6, 1);
        delay();
    }
    return 0;
}