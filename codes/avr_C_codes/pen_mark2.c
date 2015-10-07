#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

#include "USART.c"
#include "I2C.C"
#include "timer.c"


//------------------------------- { MPU6050 FUNCTIONS } -----------------------------------

void get_up_from_deep_sleep() {
    
    write_byte_to_slave(SLAVE_ADDRESS,0x6B,0x00);
    
}

void MPU6050_initialize() {
    
    read_byte_from_slave(0x68,0x6B);
    get_up_from_deep_sleep();
    read_byte_from_slave(0x68,0x6B);
    write_byte_to_slave(0x68,0x1B,0b00000000);          // SET ACCELEROMETER SENSITIVITY TO 4g
    write_byte_to_slave(0x68,0x1C,0b00000101);          // SET GYROSCOPE SENSITIVITY TO 500˚/sec
}



void blink() {
    
    PORTB |= (1<<0);
    _delay_ms(1000);
    PORTB &= ~(1<<0);
    _delay_ms(1000);
    
}

void send_MPU6050_all_data() {
    
    int j;
    int data;
    for(j=0;j<1;j++) {
        
        int address = 0x3B;
        int i;
        for(i=0;i<14;i++) {
            
            //USART_transmit_byte(address);
            data = read_byte_from_slave(0x68,address);
            address += 1;
            USART_transmit_byte(data);
            
        }
        
    }
    
    
}

//-----------------------------------------------------------------------------------------

//--------------------------------- { ISR FUNCTIONS } -------------------------------------

void timer_interrupt_service_routine(void) {
    
    int i;
    //for(i=0;i<3;i++) {
    //USART_transmit_byte('\xff');
    //}
    send_MPU6050_all_data();
    PORTD ^= (1<<5);
    
}

ISR(USART_RX_vect) {
    
    int data = UDR;
    PORTD |= (1<<4);
    _delay_ms(250);
    PORTD &= ~(1<<4);
    //int data1 = read_byte_from_slave(0x68,0x1C);
    //USART_transmit_byte(data1);
    timer_initialize(0.01);
    
}

//-----------------------------------------------------------------------------------------

int main(void) {
    
    DDRB = 0Xff;
    DDRD = 0xff;
    
    MPU6050_initialize();
    USART_initialize();
    
    //int data;
    
    //data = read_byte_from_slave(0x68,0x1B);
    //USART_transmit_byte(data);
    //data = read_byte_from_slave(0x68,0x1C);
    //USART_transmit_byte(data);
    
    
    while(1) {
        
        //USART_transmit_byte('\xff');
        //_delay_ms(1000);
        //PORTD ^= (1<<5);
        
    }
    
    return(0);
    
}
