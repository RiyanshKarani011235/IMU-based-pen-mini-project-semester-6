#define SLAVE_ADDRESS               0x68
#define CLOCK_DELAY                 1

#define START_STOP_DELAY            1
#define DELAY                       1
#define SDA                         0b00000001
#define SCL                         0b00000010
#define ACK                         0b00000100
#define ERR                         0b00001000
#define FIN                         0b00010000
;
#define BIT(x)                      (0x01 << (x))
#define bit_set(port,bit)           ((port) |= BIT(bit))
#define bit_clear(port,bit)         ((port) &= ~BIT(bit))
#define bit_flip(port,bit)          ((port) ^= BIT(bit))
#define bit_get(port,bit)           ((port) & BIT(bit))

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

