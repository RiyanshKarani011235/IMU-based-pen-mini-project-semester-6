
//----------------------- { INITIALIZATION } ---------------------------- 

import processing.serial.*;
Serial avr;

//-----------------------------------------------------------------------

//--------------------------- { CONSTANTS } -----------------------------

int val;
int[] data = new int[12];
int count = 0;

float acc_x;
float acc_y;
float acc_z;
float gyro_x=10;
float gyro_y;
float gyro_z;
int start_condition_flag = 0;
int start_condition_count = 0;

//-----------------------------------------------------------------------

void setup() {
  
  println(avr.list());
  String portname = Serial.list()[3];
  println(portname);
  avr = new Serial(this,portname,9600);
  avr.clear();
  
}

float scaled_data(int data,String sensor) {

  int sensitivity = 1;
  int data_ = data;
  
  if(sensor == "accelerometer") {
    sensitivity = 4;
  }
  if(sensor == "gyroscope") {
    sensitivity = 500;
  }
  
  if(data > 32768) {
    data_ = data - 65536;
  }
  
  float scaled_data_;
  scaled_data_ = ((data_*1.0)/65536)*sensitivity;
  return scaled_data_; 
  //return data_; 
}

void calculate_sensor_values(int[] data) {
  
//  acc_x = (((data[1])*256) + data[3]);
//  acc_y = (((data[5])*256) + data[7]);
//  acc_z = (((data[9])*256) + data[11]);
//  gyro_x = (((data[17])*256) + data[19]);
//  gyro_y = (((data[21])*256) + data[23]);
//  gyro_z = (((data[25])*256) + data[27]);
  
//    acc_x = scaled_data((((data[0])*256) + data[1]),"accelerometer");
//    acc_y = scaled_data((((data[2])*256) + data[3]),"accelerometer");
//    acc_z = scaled_data((((data[4])*256) + data[5]),"accelerometer");
//    gyro_x = scaled_data((((data[6])*256) + data[7]),"gyroscope");
//    gyro_y = scaled_data((((data[10])*256) + data[11]),"gyroscope");
//    gyro_z = scaled_data((((data[12])*256) + data[13]),"gyroscope");

    acc_x = data[0]*256 + data[1];
    acc_y = data[2]*256 + data[3];
    acc_z = data[4]*256 + data[5];
    gyro_x = data[6]*256 + data[7];
    gyro_y = data[8]*256 + data[9];
    gyro_z = data[10]*256 + data[11];

}

void print_() {
  
  print ("acc_x --> ");
  print(acc_x);
  print("g ");
  print ("acc_y --> ");
  print(acc_y);
  print("g ");
  print ("acc_z --> ");
  print(acc_z);
  print("g ");
  print ("gyro_x --> ");
  print(gyro_x);
  print("˚/s ");
  print ("gyro_y --> ");
  print(gyro_y);
  print("˚/s ");
  print ("gyro_z --> ");  
  print(gyro_z);
  print("˚/s ");  
   
  println();
    
}

void draw() {
  
  if(avr.available() >=12) {
    for(int i=0;i<12;i++) {
    
      val = avr.read();
      data[i] = val;
      
    }
    
    calculate_sensor_values(data);
    print_();
    
  }
    
    
}






