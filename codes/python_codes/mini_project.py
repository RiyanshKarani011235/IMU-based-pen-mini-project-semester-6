import serial
import time

avr = serial.Serial('/dev/tty.HC-05-DevB')
avr.baudrate = 9600
           
def char_to_int(string) :
    for i in range(0,256) :
        if(chr(i) == string) :
            return i

def check() :
    avr.write('\xff')
    while(avr.inWaiting() == 0) :
        print('waiting')
    data = char_to_int(avr.read(avr.inWaiting()))
    print data

#--------------------------- INSTRUCTION SET ----------------------------------

def send_start_condition() :
    check()
    check()

def read_bytes_from_MPU6050() :
    
    iterations = 1
    start_time = time.time()
    send_start_condition()
    while(avr.inWaiting() != (iterations*14)) :
        print('waiting for data :/ ')
    data = []
    for i in range(iterations*14) :
        data.append(avr.read(1))
    print data
    print(time.time() - start_time)
def check_() :
    for i in range(10) :
        read_bytes_from_MPU6050()
