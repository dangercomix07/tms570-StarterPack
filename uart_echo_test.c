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
    unsigned char rx_byte; 

    _enable_IRQ();      // Not needed for blocking SCI but good practice
    gioInit();          // Initialize GPIO
    sciInit();          // Initialize SCI1 (default config from HALCoGen)

    // Set GIOB6 as output (LED)
    gioSetDirection(gioPORTB, (1 << 6));

    // Welcome message
    unsigned char msg[] = "UART Echo Ready\r\n";
    unsigned char newline[] = "\r\n";
    unsigned char prefix[] = "You typed: ";

    sciSend(sciREG1, sizeof(msg) - 1, msg);
    sciSend(sciREG1, sizeof(newline) - 1, newline);

    while (1)
    {
        // // Non-Blocking receive
        // sciReceive(sciREG1, 1, &rx_byte);

        // Blocking wait until byte received
        rx_byte = sciReceiveByte(sciREG1);

        // Echo back
        sciSend(sciREG1, sizeof(prefix) - 1, prefix);
        sciSend(sciREG1, 1, &rx_byte);
        sciSend(sciREG1, sizeof(newline) - 1, newline);

        // Toggle LED on GIOB6 to confirm byte received
        gioSetBit(gioPORTB, 6, 1);
        delay();
        gioSetBit(gioPORTB, 6, 0);
        delay();
    }

    return 0;
}
