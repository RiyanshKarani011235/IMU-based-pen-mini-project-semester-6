
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

//------------------------------------- { CONSTANTS } ---------------------------------

#define SLAVE_ADDRESS               0x68
#define CLOCK_DELAY                 1

#define START_STOP_DELAY            1
#define DELAY                       1
#define SDA                         0b00000001
#define SCL                         0b00000010
#define ACK                         0b00000100
#define ERR                         0b00001000
#define FIN                         0b00010000

#define BIT(x)                      (0x01 << (x))
#define bit_set(port,bit)           ((port) |= BIT(bit))
#define bit_clear(port,bit)         ((port) &= ~BIT(bit))
#define bit_flip(port,bit)          ((port) ^= BIT(bit))
#define bit_get(port,bit)           ((port) & BIT(bit))

#define F_CPU                               18432000


enum boolean {FALSE,TRUE};

enum boolean START_BYTE_COUNT = FALSE;
enum boolean START_BYTE_FLAG = FALSE;
/*enum boolean INSTRUCTION_BYTE_FLAG = FALSE;
 char INSTRUCTION_BYTE_VALUE = 0;
 enum boolean PARAMETRIC_COUNT_UPDATE_FLAG = FALSE;
 int PARAMETRIC_COUNT = 0;
 int EXPECTED_PARAMETRIC_COUNT = 0;
 int baud_value_;
 */

int MPU6050_data[14];
int acc_x;
int acc_y;
int acc_z;
int gyro_x;
int gyro_y;
int gyro_z;

float angle = 0;
float a = 0.98;

//-------------------------------------- { I2C } --------------------------------------

void set_SDA() {
    bit_set(PORTB,0);
}

void clear_SDA(void) {
    bit_clear(PORTB,0);
}

void set_SDA_output(void) {
    bit_set(DDRB,0);
}

void set_SDA_input(void) {
    bit_clear(DDRB,0);
}

void set_SCL(void) {
    bit_set(PORTB,1);
}

void clear_SCL(void) {
    bit_clear(PORTB,1);
}

void send_start_sequence() {
    
    set_SDA();
    set_SDA_output();
    _delay_us(DELAY);
    set_SCL();
    _delay_us(DELAY);
    clear_SDA();
    _delay_us(START_STOP_DELAY);
    clear_SCL();
    _delay_us(DELAY);
    
}

void send_stop_sequence() {
    
    set_SDA();                                                          // THIS IS THE
    set_SDA_output();                                                   // ONLY FUNCTION
    _delay_us(DELAY);                                                   // AFTER WHICH
    clear_SDA();                                                        // SCL IS KEPT HIGH.
    _delay_us(DELAY);                                                   // ANY FUNCTION AFTER
    set_SCL();                                                          // THIS SHOULD CONSIDER
    _delay_us(DELAY);                                                   // THIS FACT
    set_SDA();                                                          // (THE START SEQUENCE FUNCTION
    _delay_us(START_STOP_DELAY);                                        // ALREADY DOES THIS)
    
}

int check_ACK() {
    
    set_SDA_input();
    clear_SDA();                                                        // DISABLE PULLUP RESISTOR
    _delay_us(DELAY);
    set_SCL();
    _delay_us(CLOCK_DELAY);
    int data;
    if(PINB&SDA) {
        data = 0;
    }
    else {
        data = 1;
    }
    clear_SCL();
    _delay_us(DELAY);
    return data;
    
}

void send_ACK(void) {
    
    clear_SDA();
    set_SDA_output();
    _delay_us(DELAY);
    send_SCL_pulse();
    
}


void send_SCL_pulse(void) {
    
    set_SCL();
    _delay_us(CLOCK_DELAY);
    clear_SCL();
    _delay_us(DELAY);
    
}

void write_to_port(int data) {
    
    _delay_us(10);
    
    
}

void error_routine(void) {
    
    int i = 0;
    for(i=0;i<5;i++) {
        bit_set(PORTB,3);
        _delay_us(5);
        bit_clear(PORTB,3);
        _delay_us(5);
    }
}

void acknowledge_routine(void) {
    
    int i;
    for(i=0;i<5;i++) {
        bit_set(PORTB,2);
        _delay_us(DELAY);
        bit_clear(PORTB,2);
        _delay_us(DELAY);
    }
    
}

void fin_routine(void) {
    
    int i;
    for(i=0;i<5;i++) {
        bit_set(PORTB,4);
        _delay_us(5);
        bit_clear(PORTB,4);
        _delay_us(5);
    }
    
}

void write_byte(int data_byte) {
    
    int byte = data_byte;
    _delay_us(1000);
    int data;
    set_SDA_output();
    
    int i;
    for(i=0;i<8;i++) {
        data = ((byte)&(0x80))>>7;
        PORTB |= data;
        PORTB &= data;
        _delay_us(DELAY);
        byte <<= 1;
        send_SCL_pulse();
    }
    
}


void write_byte_to_slave(int slave_address, int register_address, int data_byte) {
    
    
    int acknowledge = 0;
    send_start_sequence();
    write_byte((slave_address)<<1);
    acknowledge = check_ACK();
    if(acknowledge == 0) {
        error_routine();
    }
    else {
        acknowledge_routine();
        write_byte(register_address);
        acknowledge = check_ACK();
        if(acknowledge == 0) {
            error_routine();
        }
        else {
            acknowledge_routine();
            write_byte(data_byte);
            acknowledge = check_ACK();
            if(acknowledge == 0) {
                error_routine();
            }
            else {
                fin_routine();
                send_stop_sequence();
            }
        }
    }
    
}

int read_byte(void) {
    
    int byte = 0b00000000;
    int bit;
    set_SDA_input();
    clear_SDA();
    _delay_us(DELAY);
    
    int i;
    for(i=0;i<7;i++) {
        
        bit = check_bit();
        byte |= bit;
        byte <<= 1;
        _delay_us(DELAY);
        
    }
    
    bit = check_bit();
    byte |= bit;
    write_to_port(byte);
    _delay_us(DELAY);
    return(byte);
}

int check_bit() {
    int bit;
    set_SCL();
    _delay_us(DELAY);
    if(PINB&SDA) {
        bit = 1;
    }
    else {
        bit = 0;
    }
    clear_SCL();
    return bit;
}

int read_byte_from_slave(int slave_address, int register_address) {
    
    int acknowledge = 0;
    send_start_sequence();
    write_byte((slave_address)<<1);
    acknowledge = check_ACK();
    if(acknowledge == 0) {
        error_routine();
    }
    else {
        acknowledge_routine();
        write_byte(register_address);
        acknowledge = check_ACK();
        if(acknowledge == 0) {
            error_routine();
        }
        else {
            acknowledge_routine();
            send_start_sequence();
            write_byte(((slave_address)<<1)|1);
            acknowledge = check_ACK();
            if(acknowledge == 0) {
                error_routine();
            }
            else {
                acknowledge_routine();
                int data = read_byte();
                fin_routine();
                send_stop_sequence();
                return data;
            }
        }
    }
    
}

//-----------------------------------------------------------------------------------


//----------------------------------- { TIMER } -------------------------------------


void timer_initialize() {
    
    
    TCCR1B |= (1<<CS12);                    // USING INTERNAL CLOCK SOURCE WITH PRESCALER   256
    TCCR1B |= (1<<WGM12);                   // SETTING TIMER IN CTC MODE OF OPERATION
    
    sei();                                  // ENABLE GLOBAL INTERRUPTS
    TIMSK1 |= (1<<OCIE1A);                  // ENABLE OUTPUT COMPARE A MATCH INTERRUPT
    
    OCR1AH |= 2875>>8;                      // SETTING TIMER RESET FREQUENCY
    OCR1AL |= 2875;                         // TO 1 Hz
    
}

ISR(TIMER1_COMPA_vect) {
    
    //PORTB ^= (1<<0);
    TIFR1 |= (1<<OCF1A);                     // CLEARING THE OCFIA INTERRUPT FLAG BY STRANGELY
    // WRITING 1 TO IT
    
    timer_interrupt_service_routine();
}



void timer_disable() {
    
    TIMSK1 &= ~(1<<OCIE1A);
    
}

//----------------------------------------------------------------------------------



//----------------------------------- { USART } ------------------------------------

void USART_initialize() {
    
    UCSR0C &= ~(1<<UMSEL00);
    UCSR0C &= ~(1<<UMSEL01);
                                                                        // MODE OF COMMUNICATION (SYNCHRONOUS --> (USMEL = 1), ASYNCHRONOUS --> (USMEL = 0))
    UBRR0H = 0x00;                                                      // SETTING BAUD
    UBRR0L = 0x77;                                                      // RATE
    UCSR0A &= ~(1<<U2X0);                                               // NORMAL ASYNCHRONOUS MODE OF COMMUNICATION
    
    UCSR0B = (1<<TXEN0);                                                // ENABLE TRANSMITTER
    
    UCSR0C |= (3<<UCSZ00);                                              // 8-bit DATA
    
    UCSR0C &= ~(1<<UPM01);                                              // DISABLE PARITY
    UCSR0C &= ~(1<<UPM00);
    
    UCSR0C &= ~(1<<USBS0);                                              // 1 STOP BIT
    
    sei();                                                              // ENABLE GLOBAL INTERRUPT
    UCSR0B &= ~(1<<RXCIE0);                                             // DISABLE RECEIVE COMPLETE INTERRUPT
    
}

void USART_transmit_byte(int byte) {
    
    while(!(UCSR0A & (1<< UDRE0)));                                       // WAIT UNTIL TRANSMITTER READY
    UDR0 = byte;
    
    
}

/*

ISR(USART_RX_vect) {
    
    int data = UDR;
    USART_transmit_byte(data);
    
    //RXC_ISR_routine(data);
    check_start_condition(data);
    if(START_BYTE_FLAG == TRUE) {
        
        START_BYTE_FLAG = FALSE;
        send_MPU6050_data();
        
    }
    
}


void check_start_condition(char data) {
    
    if((data == '\xff') & (START_BYTE_FLAG == FALSE)) {
        
        
        if(START_BYTE_COUNT == TRUE) {
            
            START_BYTE_COUNT = FALSE;
            START_BYTE_FLAG = TRUE;
            
        }
        
        else {
            
            START_BYTE_COUNT = TRUE;
            
        }
    }
    
}
 
*/

void send_MPU6050_data() {
    
    int j;
    int data;
    for(j=0;j<1;j++) {
        
        int address = 0x3B;
        int i;
        for(i=0;i<14;i++) {
            
            //USART_transmit_byte(address);
            data = read_byte_from_slave(0x68,address);
            MPU6050_data[i] = data;
            address += 1;
            USART_transmit_byte(data);
            
        }
        
    }
    
}

/*
 void RXC_ISR_routine(char data) {
 
 if(START_BYTE_FLAG == TRUE) {
 
 if(INSTRUCTION_BYTE_FLAG == TRUE) {
 
 if(PARAMETRIC_COUNT_UPDATE_FLAG == TRUE) {
 
 
 
 }
 
 else {
 
 USART_transmit_byte('E');
 USART_transmit_byte('R');
 USART_transmit_byte('R');
 USART_transmit_byte('0');
 USART_transmit_byte('R');
 
 }
 
 }
 else {
 
 INSTRUCTION_BYTE_VALUE = data;
 INSTRUCTION_BYTE_FLAG = TRUE;
 expected_parametric_count_update(INSTRUCTION_BYTE_VALUE);
 PARAMETRIC_COUNT_UPDATE_FLAG = TRUE;
 blink(5);
 
 }
 }
 
 }
 
 void expected_parametric_count_update(char instruction_byte_value) {
 
 switch (instruction_byte_value) {
 
 case '\x00':
 blink(3);
 USART_transmit_byte('\x00');
 break;
 
 default:
 break;
 
 }
 
 }
 */


//---------------------------------------------------------------------------

//------------------------------- { MPU6050 FUNCTIONS } -----------------------------------

void get_up_from_deep_sleep() {
    
    write_byte_to_slave(SLAVE_ADDRESS,0x6B,0x00);
    
}

void MPU6050_initialize() {
    
    read_byte_from_slave(0x68,0x6B);
    get_up_from_deep_sleep();
    read_byte_from_slave(0x68,0x6B);
    write_byte_to_slave(0x68,0x1B,0b00000000);          // SET ACCELEROMETER SENSITIVITY TO 4g
    write_byte_to_slave(0x68,0x1C,0b00000000);          // SET GYROSCOPE SENSITIVITY TO 500˚/sec
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
            //USART_transmit_byte(data);
            
        }
        
        
    }
    
    acc_x = (MPU6050_data[0]<<8) + MPU6050_data[1];
    acc_y = (MPU6050_data[2]<<8) + MPU6050_data[3];
    acc_z = (MPU6050_data[4]<<8) + MPU6050_data[5];
    gyro_x = (MPU6050_data[8]<<8) + MPU6050_data[9];
    gyro_y = (MPU6050_data[10]<<8) + MPU6050_data[11];
    gyro_z = (MPU6050_data[12]<<8) + MPU6050_data[13];
    USART_transmit_byte(acc_x>>8);
    USART_transmit_byte(acc_x);
    USART_transmit_byte(acc_y>>8);
    USART_transmit_byte(acc_y);
    USART_transmit_byte(acc_z>>8);
    USART_transmit_byte(acc_z);
    USART_transmit_byte(gyro_x>>8);
    USART_transmit_byte(gyro_x);
    USART_transmit_byte(gyro_y>>8);
    USART_transmit_byte(gyro_y);
    USART_transmit_byte(gyro_z>>8);
    USART_transmit_byte(gyro_z);
    
    angle = a*(angle - gyro_y) + (1-a)*(acc_x);
    USART_transmit_byte(angle);
    
    
    
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

//-----------------------------------------------------------------------------------------

int main(void) {
    
    DDRB = 0Xff;
    DDRD = 0xff;
    
    MPU6050_initialize();
    USART_initialize();
    
    int data;
    
    //data = read_byte_from_slave(0x68,0x1B);
    //USART_transmit_byte(data);
    //data = read_byte_from_slave(0x68,0x1C);
    //USART_transmit_byte(data);
    
    timer_initialize(0.01);
    
    while(1) {
        
        
        //USART_transmit_byte('\xff');
        //_delay_ms(1000);
        //PORTD ^= (1<<5);
        
    }
    
    return(0);
    
}




