
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



