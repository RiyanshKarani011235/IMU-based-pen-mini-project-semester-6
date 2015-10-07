
//----------------------- { INITIALIZATION } ---------------------------- 

import processing.serial.*;
Serial avr;

//-----------------------------------------------------------------------

//--------------------------- { CONSTANTS } -----------------------------

int window_width = 1280;
int window_height = 718;


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

float x1 = 0;
float previous_x1 = 0;
float previous_y1 = 0;
float x2 = 0;
float previous_x2 = 0;
float previous_y2 = 0;


//-----------------------------------------------------------------------

void setup() {
  
  background(255);
  size(window_width,window_height);
  draw_x_axis();
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

    acc_x = (scaled_data((data[0]*256 + data[1]),"accelerometer"))*57.29;
    acc_y = (scaled_data((data[2]*256 + data[3]),"accelerometer"))*57.29;
    acc_z = (scaled_data((data[4]*256 + data[5]),"accelerometer"))*57.29;
    gyro_x = scaled_data((data[6]*256 + data[7]),"gyroscope");
    gyro_y = scaled_data((data[8]*256 + data[9]),"gyroscope");
    gyro_z = scaled_data((data[10]*256 + data[11]),"gyroscope");

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

void plot1(float data) {
  
  int multiplier = 1;
  float y = data*multiplier;
  
  x1 += 2;
  stroke(51, 102, 200);                      // BLUE
  line(previous_x1,350-previous_y1,x1,350-y);
  if(x1 > window_width) {
    x1 = 0;
    background(255);
    draw_x_axis();
  }
  previous_x1 = x1;
  previous_y1 = y;
 
}

void plot2(float data) {
  
  int multiplier = 1;
  float y = data*multiplier;
  
  x2 += 2;
  stroke(200, 20, 200);                      // MAGENTA
  line(previous_x2,350-previous_y2,x2,350-y);
  if(x2 > window_width) {
    x2 = 0;
    background(255);
    draw_x_axis();
  }
  previous_x2 = x2;
  previous_y2 = y;
 
}

void draw_x_axis() {
  
  stroke(0,0,0);
  for(int i=0;i<window_width;i++) {
    point(i,350);
  }
  
}


void draw() {

  if(avr.available() >= 2) {
    int data_high = avr.read();
    int data_low = avr.read();
    float data_ =  data_high*256 + data_low;
    if(data_ > 32767) {
      data_ = data_ - 65536;
    }
    data_ = data_/100;
    println(data_);
    plot1(data_);
  }
      
}






