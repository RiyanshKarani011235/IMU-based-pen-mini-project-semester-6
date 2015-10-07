import serial
import time

avr = serial.Serial('/dev/tty.HC-05-DevB')
avr.baudrate = 9600

def tp() :
    previous_value = 0
    value = 0
    while(1) :
        value = avr.inWaiting()
        if(value != previous_value) :
            value = avr.inWaiting()
            previous_value = value
            print(value)

def read() :

    while(avr.inWaiting() < 28) :
        i = 0
    data = []
    for i in range(28) :
        data.append(char_to_int(avr.read(1)))
        
##    acc_x = ((data[1]*256) + data[3])
##    acc_y = ((data[5]*256) + data[7])
##    acc_z = ((data[9]*256) + data[11])
##    temp = ((data[13]*256) + data[15])
##    gyro_x = ((data[17]*256) + data[19])
##    gyro_y = ((data[21]*256) + data[23])
##    gyro_z = ((data[25]*256) + data[27])

    acc_x = correct((data[1]*256) + data[3])
    acc_y = correct((data[5]*256) + data[7])
    acc_z = correct((data[9]*256) + data[11])
    temp = correct((data[13]*256) + data[15])
    gyro_x = correct((data[17]*256) + data[19])
    gyro_y = correct((data[21]*256) + data[23])
    gyro_z = correct((data[25]*256) + data[27])

    print ('acc_x --> ' + str(acc_x) + 'g' + ' acc_y --> ' + str(acc_y) + 'g'+ ' acc_z --> ' + str(acc_z)+ 'g' + ' gyro_x --> ' + str(gyro_x) + '˚/s' + ' gyro_y --> ' + str(gyro_y) + '˚/s'  +' gyro_z --> ' + str(gyro_z) + '˚/s' )
##    print(data)
##    print(data[0])
##    print(data[9]*256 + data[11])
##    print(acc_z)
##    print(str(acc_z))/Applications/GitHub.app
    
def correct(data) :

    sensitivity = 4
    if(data > 32768) :
        data -= 65536
    data = ((data*1.0)/65536)*sensitivity
    return(data)


def char_to_int(char) :
    for i in range(0,256) :
        if(chr(i) == char) :
            return i
