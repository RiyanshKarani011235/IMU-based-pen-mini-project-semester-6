#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

//#include<string.h>

//---------------------------------- { INITIALIZATION} ------------------------------------

#define SLAVE_ADDRESS               0x68
#define CLOCK_DELAY                 2

#define START_STOP_DELAY            2
#define DELAY                       2
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

//-----------------------------------------------------------------------------------------

//----------------------------------- { ENUMERATIONS }-------------------------------------

enum boolean {FALSE,TRUE};

//-----------------------------------------------------------------------------------------




//----------------------------------- { CONSTANTS } ---------------------------------------

enum boolean START_BYTE_COUNT = FALSE;
enum boolean START_BYTE_FLAG = FALSE;
/*enum boolean INSTRUCTION_BYTE_FLAG = FALSE;
 char INSTRUCTION_BYTE_VALUE = 0;
 enum boolean PARAMETRIC_COUNT_UPDATE_FLAG = FALSE;
 int PARAMETRIC_COUNT = 0;
 int EXPECTED_PARAMETRIC_COUNT = 0;
 int baud_value_;
 */

//-----------------------------------------------------------------------------------------




//-------------------------------------- { ISR } ------------------------------------------

ISR(USART_RX_vect) {
    
    int data = UDR;
    USART_transmit_byte(data);
    
    //RXC_ISR_routine(data);
    check_start_condition(data);
    if(START_BYTE_FLAG == TRUE) {
        
        START_BYTE_FLAG = FALSE;
        blink(4);
        send_MPU6050_data();
        
    }
    
}

//-----------------------------------------------------------------------------------------


//------------------------------------- { USART } -----------------------------------------

void USART_initialize() {
    
    UCSRC &= ~(1<<UMSEL);                                               // MODE OF COMMUNICATION (SYNCHRONOUS --> (USMEL = 1), ASYNCHRONOUS --> (USMEL = 0))
    UBRRH = (unsigned char)(103 >> 8);                                  // SETTING BAUD
    UBRRL = (unsigned char)(103);                                       // RATE
    UCSRA &= ~(1<<U2X);                                                 // NORMAL ASYNCHRONOUS MODE OF COMMUNICATION
    
    UCSRB = (1<<RXEN)|(1<<TXEN);                                        // ENABLE RECEIVER & TRANSMITTER
    
    UCSRC |= (3<<UCSZ0);                                                // 8-bit
    UCSRB &= ~(UCSZ2);                                                  // DATA
    
    UCSRC &= ~(1<<UPM1);                                                // DISABLE PARITY
    UCSRC &= ~(1<<UPM0);
    
    UCSRC |= (1<<USBS);                                                 // 1 STOP BIT
    
    sei();                                                              // ENABLE GLOBAL INTERRUPT
    UCSRB |= (1<<RXCIE);                                                // ENABLE RECEIVE COMPLETE INTERRUPT
    
}

void USART_transmit_byte(int byte) {
    
    while(!(UCSRA & (1<< UDRE)));                                       // WAIT UNTIL TRANSMITTER READY
    UDR = byte;
    
    
}

//-----------------------------------------------------------------------------------------

//--------------------------------------- { I2C } -----------------------------------------

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


//-----------------------------------------------------------------------------------------


//----------------------------------- { FUNCTIONS } ---------------------------------------

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

void send_MPU6050_data() {
    
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

void blink(int data) {
    
    PORTD |= (1<<data);
    _delay_ms(40);
    PORTD  &= ~(1<<data);
    _delay_ms(40);
    
}

void get_up_from_deep_sleep() {
    
    write_byte_to_slave(SLAVE_ADDRESS,0x6B,0x00);
    
}

void MPU6050_initialize() {
    
    read_byte_from_slave(0x68,0x6B);
    get_up_from_deep_sleep();
    read_byte_from_slave(0x68,0x6B);
    
}


//-----------------------------------------------------------------------------------------

int main(void) {
    
    DDRB = 0Xff;
    DDRD = 0xff;
    
    MPU6050_initialize();
    USART_initialize(9600);
    
    while(1) {
        
        
        
    }
    return(0);
    
}