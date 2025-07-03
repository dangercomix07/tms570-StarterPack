#include "HL_sys_common.h"
#include "HL_gio.h"

void _exit(int status) {
    while (1);  // hang forever
}

// --- Stub out TI auto‐init and exit for a bare‐metal blink demo ---
void __TI_auto_init(void) {
    // if you’re manually initializing .data/.bss in your startup,
    // this can be empty. Otherwise, call your own init routine here.
}

int exit(int status) {
    // never return: loop forever
    (void)status;
    while (1) { }
}

void delay(void)
{
    volatile int i;
    for (i = 0; i < 500000; ++i)
    {
        __asm(" nop");  // Prevent optimization
    }
}

int user_main(void)
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

