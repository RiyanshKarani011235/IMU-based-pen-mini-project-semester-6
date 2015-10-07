#include<avr/io.h>
#include<util/delay.h>

int main(void) {
    
    DDRB |= 0XFF;
    while(1) {
        PORTB |= (1<<2);
        _delay_ms(500);
        PORTB &= ~(1<<2);
        _delay_ms(500);
    }
}