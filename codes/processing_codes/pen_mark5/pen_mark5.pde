
//----------------------- { INITIALIZATION } ---------------------------- 

import processing.serial.*;
Serial avr;

//-----------------------------------------------------------------------

//--------------------------- { CONSTANTS } -----------------------------

int val;
int[] data = new int[14];
float[] acc_data = new float[3];
float[] gyro_data = new float[3];

int window_width = 1280;
int window_height = 718;

float sampling_period = 0.001;    // IN SECONDS
float time_constant = 2;        // IN SECONDS

float a = time_constant/(time_constant+sampling_period);

float angle;

float x = 0;
float previous_x = 0;
float previous_y = 0;
float lpf_x = 0;
float lpf_previous_x = 0;
float lpf_previous_y = 0;
float lpf_y = 0;
float integrator_y = 0;
float integrator_x = 0;
float integrator_previous_x = 0;
float integrator_previous_y = 0;

//-----------------------------------------------------------------------

void setup() {
  //a = 0.02;
  
  print("a --> ");
  print(a);
  println();
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
  
    acc_data[0] = scaled_data((((data[0])*256) + data[1]),"accelerometer");
    acc_data[1] = scaled_data((((data[2])*256) + data[3]),"accelerometer");
    acc_data[2] = scaled_data((((data[4])*256) + data[5]),"accelerometer");
    gyro_data[0] = scaled_data((((data[8])*256) + data[9]),"gyroscope");
    gyro_data[1] = scaled_data((((data[10])*256) + data[11]),"gyroscope");
    gyro_data[2] = scaled_data((((data[12])*256) + data[13]),"gyroscope");

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
  
  float y = 1*data;
  
  x += 2;
  stroke(51, 102, 200);
  line(previous_x,350-previous_y,x,350-y);
  if(x > window_width) {
    x = 0;
    background(255);
  }
  previous_x = x;
  previous_y = y;
 
}

void lpf_plot(float data) {
  
  float a = 0.97;
  lpf_y = a*lpf_y + (1-a)*data;
  
  lpf_x += 2;
  stroke(200, 102, 51);
  line(lpf_previous_x,350-lpf_previous_y,lpf_x,350-lpf_y);
  if(lpf_x > window_width) {
    lpf_x = 0;
    background(255);
  }
  lpf_previous_x = lpf_x;
  lpf_previous_y = lpf_y;

}

void integrator_plot(float data) {
  
  float dt = 0.01;
  integrator_y += (data*dt);
  integrator_x += 2;
  stroke (51,200,100);
  line(integrator_previous_x,350-integrator_previous_y,integrator_x,350-integrator_y);
  if(integrator_x > window_width) {
    integrator_x = 0;
    background(255);
  }
  integrator_previous_x = integrator_x;
  integrator_previous_y = integrator_y;
  
}

//-----------------------------------------------------------------------

void draw() {
 
  if(avr.available() >= 14) {
    for(int i=0;i<14;i++) {
    
      val = avr.read();
      data[i] = val;
      
    }
    calculate_sensor_values(data);
    print_();
  }  
  
  float angle_acc = asin(acc_data[0]);
  angle = a*(angle+gyro_data[0]*sampling_period) + (1-a)*(angle_acc);
  plot(gyro_data[0]);
  lpf_plot(gyro_data[0]);
  integrator_plot(gyro_data[0]);
   
}






