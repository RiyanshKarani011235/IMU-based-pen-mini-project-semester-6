#include<avr/io.h>
#include<avr/interrupt.h>

#define CTC_highest_value                   62500
#define F_CPU                               16000000

void timer_initialize(float time_delay) {
    
    int count = (int)((time_delay*(F_CPU*1.0))/256);
    
    TCCR1B |= (1<<CS12);                    // USING INTERNAL CLOCK SOURCE WITH PRESCALER   256
    TCCR1B |= (1<<WGM12);                   // SETTING TIMER IN CTC MODE OF OPERATION
    
    sei();                                  // ENABLE GLOBAL INTERRUPTS
    TIMSK |= (1<<OCIE1A);                   // ENABLE OUTPUT COMPARE A MATCH INTERRUPT
    
    OCR1AH |= 2875>>8;         // SETTING TIMER RESET FREQUENCY
    OCR1AL |= 2875;            // TO 1 Hz
    
}

ISR(TIMER1_COMPA_vect) {
    
    //PORTB ^= (1<<0);
    TIFR |= (1<<OCF1A);                     // CLEARING THE OCFIA INTERRUPT FLAG BY STRANGELY
    // WRITING 1 TO IT
    
    timer_interrupt_service_routine();
}



void timer_disable() {
    
    TIMSK &= ~(1<<OCIE1A);
    
}
