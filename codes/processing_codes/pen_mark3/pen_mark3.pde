
//----------------------- { INITIALIZATION } ---------------------------- 

import processing.serial.*;
Serial avr;

//-----------------------------------------------------------------------

//--------------------------- { CONSTANTS } -----------------------------

int val;
int[] data = new int[28];
float[] acc_data = new float[3];
float[] gyro_data = new float[3];
int count = 0;

int start_condition_flag = 0;
int start_condition_count = 0;

int window_width = 1280;
int window_height = 718;

int x = 0;
float previous_x = 0;
float previous_y = 0;
float lpf_y = 0;
float previous_lpf_y = 0;
//-----------------------------------------------------------------------

void setup() {
  
  background(255);
  size(window_width,window_height);
  println(avr.list());
  String portname = Serial.list()[3];
  println(portname);
  avr = new Serial(this,portname,9600);
  avr.clear();
  
}

//---------------------------- { FUNCTIONS } ------------------------------

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
  
    acc_data[0] = scaled_data((((data[1])*256) + data[3]),"accelerometer");
    acc_data[1] = scaled_data((((data[5])*256) + data[7]),"accelerometer");
    acc_data[2] = scaled_data((((data[9])*256) + data[11]),"accelerometer");
    gyro_data[0] = scaled_data((((data[17])*256) + data[19]),"gyroscope");
    gyro_data[1] = scaled_data((((data[21])*256) + data[23]),"gyroscope");
    gyro_data[2] = scaled_data((((data[25])*256) + data[27]),"gyroscope");

}

void print_() {
  
  print ("acc_x --> ");
  print(acc_data[0]);
  print("g ");
  print ("acc_y --> ");
  print(acc_data[1]);
  print("g ");
  print ("acc_z --> ");
  print(acc_data[2]);
  print("g ");
  print ("gyro_x --> ");
  print(gyro_data[0]);
  print("˚/s ");
  print ("gyro_y --> ");
  print(gyro_data[1]);
  print("˚/s ");
  print ("gyro_z --> ");  
  print(gyro_data[2]);
  print("˚/s ");  
   
  println();
    
}

void plot(float data) {
  
  float y = data*300;
//  float lpf_y = previous_lpf_y + (y*0.1);

  lpf_y = 0.93*lpf_y + 0.07*y;
//  for(int i=0;i<10;i++) {
//    point(x,data);
//    data++;
//  }
  x += 2;
  stroke(51, 102, 200);
  line(previous_x,350-previous_y,x,350-y);
  stroke(200, 102, 51);
  line(previous_x,350-previous_lpf_y,x,350-lpf_y);
  if(x > window_width) {
    x = 0;
    background(255);
  }
  previous_x = x;
  previous_y = y;
  previous_lpf_y = lpf_y;
  
}

//-----------------------------------------------------------------------

void draw() {
 
  if(avr.available() >= 28) {
    for(int i=0;i<28;i++) {
    
      val = avr.read();
      data[i] = val;
      
    }
    calculate_sensor_values(data);
    print_();
  }
  plot(acc_data[0]);
    
    
}






