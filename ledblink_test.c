#include "HL_sys_common.h"
#include "HL_gio.h"
#include "HL_sci.h"

void delay(void)
{
    volatile int i;
    for (i = 0; i < 1000000; ++i)
    {
        __asm(" nop");
    }
}

int main(void)
{
    sciInit();           // Initialize UART module (configured in HALCoGen)
    gioInit();           // Initialize GIO module

    // Set GIOB pins 6 and 7 as outputs (for LEDs)
    gioSetDirection(gioPORTB, (1 << 6) | (1 << 7));

    // Message to send over UART
    unsigned char hello[] = "Hello World!\r\n";

    while (1)
    {
        // Send message over UART — replace sciREG2 with sciREG1 or sciREGx as needed
        sciSend(sciREG1, sizeof(hello) - 1, hello);

        // Blink pattern: LED on GIOB7 ON, GIOB6 OFF
        gioSetBit(gioPORTB, 7, 1);
        gioSetBit(gioPORTB, 6, 0);
        delay();

        // Blink pattern: LED on GIOB7 OFF, GIOB6 ON
        gioSetBit(gioPORTB, 7, 0);
        gioSetBit(gioPORTB, 6, 1);
        delay();
    }

    return 0;
}

