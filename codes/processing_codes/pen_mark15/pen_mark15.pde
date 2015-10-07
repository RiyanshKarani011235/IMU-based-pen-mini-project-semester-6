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

float a_roll = 0.98;
float a_pitch = 0.95;
float sampling_period = 0.037;

int x = 0;

float theta_rad = 0;
float theta_deg = 0;
float phi_rad = 0;
float phi_deg = 0;

float pitch = 0;
float roll = 0;

float vel_x = 0;

float acc_y_ = 0;

float integrator_y = 0;
float integrator_x = 0;
float integrator_previous_x = 0;
float integrator_previous_y = 0;

float previous_x = 0;
float x_ = 0;
float previous_z = 0;
float z_ = 0;

int x_positive_flag = 0;
int x_negative_flag = 0;
int z_positive_flag = 0;
int z_negative_flag = 0;

int count_x = 0;
int count_z = 0;

int position_x = 0;
int position_z = 0;

int r = 100;
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
  acc_data[0] = 0.001;
  acc_data[1] = 0;
  acc_data[2] = 0.001;
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

void integrator_plot(float data) {
  
  int multiplier = 1;
  float dt = 0.05;
  integrator_y += (data*dt);
  integrator_x += 2;
  stroke (51,200,100);                        // GREEN
  line(integrator_previous_x,350-(integrator_previous_y*multiplier),integrator_x,350-(integrator_y*multiplier));
  if(integrator_x > window_width) {
    integrator_x = 0;
    background(255);
    draw_x_axis();
  }
  //println(integrator_y);
  integrator_previous_x = integrator_x;
  integrator_previous_y = integrator_y;
  
}

void pitch_and_roll() {
  
  int r = 100;
  
  float x_pitch = 400;
  float y_pitch = 359;
  background(100,100,100);
  stroke(0,0,0);
  
  fill(100,200,70);
  ellipse(x_pitch,y_pitch,2*r,2*r);
  line(x_pitch-r,y_pitch,x_pitch+r,y_pitch);
  line(x_pitch,y_pitch - r,x_pitch, y_pitch + r);
  
  stroke(200,102,51);
  line(x_pitch - (r*cos(phi_rad)),y_pitch + (r*sin(phi_rad)),(x_pitch + (r*cos(phi_rad))),(y_pitch - (r*sin(phi_rad))));
  
  float x_roll = 800;
  float y_roll = 359;
  
  stroke(0,0,0);

  fill(200,102,51);
  ellipse(x_roll,y_roll,2*r,2*r);
  line(x_roll-r,y_roll,x_roll+r,y_roll);
  line(x_roll,y_roll-r,x_roll,y_roll+r);
  
  stroke(100,200,70);
  line(x_roll + (r*cos(theta_rad)),y_roll - (r*sin(theta_rad)),(x_roll - (r*cos(theta_rad))),(y_roll+(r*sin(theta_rad))));
  
  fill(0);
  textSize(20);
  text("ROLL",x_pitch-25,500);
  text("PITCH",x_roll-30,500);
  text("ROLL AND PITCH CALCULATED USING COMPLEMENTARY FILTER",275,100);
  
}

//-----------------------------------------------------------------------

void draw() {
   
  x += 2;
  
  
  float acc_data_0 = acc_data[1];
  if(avr.available() >= 14) {
    for(int i=0;i<14;i++) {
    
      int val = avr.read();
      data[i] = val;
      
    }
    calculate_sensor_values(data);
    
  }  
  
  //low pass filter coefficients a_x, a_y and a_z
  ax = 0.8;
  ay = 0.8;
  az = 0.8;
  
  //implementing low pass filter on x, y and z axis accelerometer values
  float previous_acc_x = acc_x;
  float previous_acc_y = acc_y;
  float previous_acc_z = acc_z;
  
  acc_x = ax*acc_x + (1-ax)*acc_data[0];
  acc_y = ay*acc_y + (1-ay)*acc_data[1];
  acc_z = az*acc_z + (1-az)*acc_data[2];
  
  float previous_theta = theta_deg;
  float previous_phi = phi_deg;
  float previous_roll = roll;
  float previous_pitch = pitch;
  
  theta_rad = asin(limit(acc_y));
  theta_deg = theta_rad*57.2974;
  phi_rad  = atan((acc_x/acc_z)*(-1));
  phi_deg = phi_rad*57.2974;
  
  pitch =  a_pitch*(pitch + (gyro_data[0]*sampling_period)) + (1-a_pitch)*theta_deg;  //pitch in degrees
  roll = a_roll*(roll + (gyro_data[1]*sampling_period)) + (1-a_roll)*phi_deg;         //roll in degrees
  
//  acc_x = acc_x - ((cos(pitch/57.2974))*(sin(roll/57.2974)));
  
//  plot(acc_x,previous_acc_x,51,102,200,10);      //BLUE
//  plot(acc_y,previous_acc_y,200,20,200,100);      //MAGENTA
//  plot(acc_z,previous_acc_z,200,102,51,100);      //ORANGE
  
//  plot(pitch,previous_pitch,51,102,200,1);      //BLUE
//  plot(roll,previous_roll,200,20,200,1);      //MAGENTA

//  plot(theta_deg,previous_theta,51,102,200,1);      //BLUE
//  plot(phi_deg,previous_phi,200,20,200,1);      //MAGENTA

  previous_x = x_;
  x_ = acc_x + ((cos(theta_rad))*(sin(phi_rad)));
  previous_z = z_;
  z_ = acc_z - ((cos(theta_rad))*(cos(phi_rad)));

//-------------------------------------------------------------
  
  float previous_position_x = position_x;
  
  if((x_ < 0.1)&(x_ > -0.1)) {
    x_ = 0;
  }
  
  if((x_negative_flag == 0)&(x_ > 0.2)&(x_positive_flag == 0)) {
    x_positive_flag = 1;
    position_x -= 1;
  }
  
  if((x_positive_flag == 0)&(x_ < -0.2)&(x_negative_flag == 0)) {
    x_negative_flag = 1;
    position_x += 1;
  }
  
  if(x_positive_flag == 1) {
    count_x ++;
    if(x_ < 0) {
      x_ = 0;
    }
  }
  
  if(x_negative_flag == 1) {
    count_x ++;
    if(x_ > 0) {
      x_ = 0;
    }
  }
  
  if(count_x > 20) {
    x_negative_flag = 0;
    x_positive_flag = 0;
    count_x = 0;
  }
  
  float previous_position_z = position_z;
  
  if((z_ < 0.1)&(z_ > -0.1)) {
    z_ = 0;
  }
  
  
  if((z_negative_flag == 0)&(z_ > 0.2)&(z_positive_flag == 0)) {
    z_positive_flag = 1;
    position_z -= 1;
  }
  
  if((z_positive_flag == 0)&(z_ < -0.2)&(z_negative_flag == 0)) {
    z_negative_flag = 1;
    position_z += 1;
  }
  
  if(z_positive_flag == 1) {
    count_z ++;
    if(z_ < 0) {
      z_ = 0;
    }
  }
  
  if(x_negative_flag == 1) {
    count_z ++;
    if(z_ > 0) {
      z_ = 0;
    }
  }
  
  if(count_z > 20) {
    z_negative_flag = 0;
    z_positive_flag = 0;
    count_z = 0;
  }

//------------------------------------------------------------

//  plot(x_,previous_x,51,102,200,100);      //BLUE
//  plot(acc_z,previous_acc_z,200,20,200,100);      //MAGENTA

//  plot(position_x,previous_position_x,51,102,200,10);      //BLUE
//  plot(z_,previous_z,200,20,200,100);      //MAGENTA

  pitch_and_roll();
}








