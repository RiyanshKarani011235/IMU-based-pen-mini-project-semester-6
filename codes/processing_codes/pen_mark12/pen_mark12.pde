//----------------------- { INITIALIZATION } ---------------------------- 

import processing.serial.*;
Serial avr;

//-----------------------------------------------------------------------

//--------------------------- { CONSTANTS } -----------------------------

int okay_sirji = 0;

int[] data = new int[14];
float[] acc_data = new float[3];
float[] gyro_data = new float[3];

int accelerometer_sensitivity = 4;
int gyroscope_sensitivity = 500;

int window_width = 1280;
int window_height = 718;

float acc_x = 0;
float acc_y = 0;
float acc_z = 0;

float ax = 0.98;
float ay = 0.98;
float az = 0.98;

float a_roll = 0.95;
float a_pitch = 0.95;
float sampling_period = 0.037;

int x = 0;

float theta_rad = 0;
float theta_deg = 0;
float phi_rad = 0;
float phi_deg = 0;

float pitch = 0;
float roll = 0;
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
  avr.write(0xff);
  acc_data[0] = 1;
  acc_data[1] = 0;
  acc_data[2] = 1;
  gyro_data[0] = 0;
  gyro_data[1] = 0;
  gyro_data[2] = 0;
  
}

//---------------------------- { FUNCTIONS } ------------------------------

float scaled_data(int data,String sensor) {

  int sensitivity = 1;
  int data_ = data;
  
  if(sensor == "accelerometer") {
    sensitivity = accelerometer_sensitivity;
  }
  if(sensor == "gyroscope") {
    sensitivity = gyroscope_sensitivity;
  }
  
  if(data > 32767) {
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


void draw_x_axis() {
  
  stroke(0,0,0);
  for(int i=0;i<window_width;i++) {
    point(i,350);
  }
  
}

float limit(float data) {
  
  float data_ = data;
  if(data>1) {
    data_ = 1;
  }
  if(data<-1) {
    data_ = -1;
  }
  return data_;
  
}

//-----------------------------------------------------------------------

//------------------------ { DRAWING FUNCTIONS } ------------------------

void plot(float data,float previous_data,int R,int G, int B,float multiplier) {
  
  stroke(R,G,B);
  line(x-2,350-(previous_data*multiplier),x,350-(data*multiplier));
  if(x > window_width) {
    x = 2;
    background(255);
    draw_x_axis();
  }
  
}

//-----------------------------------------------------------------------

void draw() {
   
  if(avr.available() >= 14) {
    for(int i=0;i<14;i++) {
    
      int val = avr.read();
      data[i] = val;
      
    }
    calculate_sensor_values(data);
    
  }  
  
  //low pass filter coefficients a_x, a_y and a_z
  ax = 0.9;
  ay = 0.9;
  az = 0.9;
  
  //implementing low pass filter on x, y and z axis accelerometer values
  float previous_acc_x = acc_x;
  float previous_acc_y = acc_y;
  float previous_acc_z = acc_z;
  
  acc_x = ax*acc_x + (1-ax)*acc_data[0];
  acc_y = ay*acc_y + (1-ay)*acc_data[1];
  acc_z = az*acc_z + (1-az)*acc_data[2];
  
  
  x += 2;
  
  float previous_theta = theta_deg;
  float previous_phi = phi_deg;
  float previous_roll = roll;
  float previous_pitch = pitch;
  
  theta_rad = asin(limit(acc_y));
  theta_deg = theta_rad*57.2974;
  phi_rad  = atan((acc_x/acc_z)*(-1));
  phi_deg = phi_rad*57.2974;
  
  pitch =  a_pitch*(pitch + (gyro_data[0]*sampling_period)) + (1-a_pitch)*theta_deg;
  roll = a_roll*(roll + (gyro_data[1]*sampling_period)) + (1-a_roll)*phi_deg;
  
  println(gyro_data[1]);
  plot(pitch,previous_pitch,51,102,200,1);  //BLUE
  plot(roll,previous_roll,200,20,200,1);  //MAGENTA
  //plot(acc_z,previous_acc_z,200,102,51,100);  //ORANGE
  
}






