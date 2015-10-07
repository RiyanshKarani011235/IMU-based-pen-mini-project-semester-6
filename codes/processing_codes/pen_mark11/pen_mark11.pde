
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

float sampling_period = 0.037;    // IN SECONDS
float time_constant = 0.1;        // IN SECONDS

float a = time_constant/(time_constant + sampling_period);

float angle;

float x1 = 0;
float previous_x1 = 0;
float previous_y1 = 0;
float x2 = 0;
float previous_x2 = 0;
float previous_y2 = 0;
float lpf_x = 0;
float lpf_previous_x = 0;
float lpf_previous_y = 0;
float lpf_y = 0;
float integrator_y = 0;
float integrator_x = 0;
float integrator_previous_x = 0;
float integrator_previous_y = 0;

int accelerometer_sensitivity = 4;
int gyroscope_sensitivity = 250;

float pitch = 0;
float roll = 0;
float yaw = 0;

float acc_angle = 0;



float acc_x = 0;
float acc_y = 0;
float acc_z = 0;

float vel_x = 0;
float vel_y = 0;
float vel_z = 0;

float pos_x = 0;
float pos_y = 0;
float pos_z = 0;

float ac = 0.0;

float phi = 0;
float theta = 0;

float variable = 0;
float coe = 0.95;
//-----------------------------------------------------------------------

void setup() {
  //a = 0.02;
  acc_data[0] = 1;
  data[0] = 0;
  data[1] = 0;
  acc_data[2] = 0;
  data[4] = 0;
  data[5] = 0;
  acc_data[1] = 1;
  print("a --> ");
  print(a);
  println();
  background(255);
  size(window_width,window_height);
  draw_x_axis();
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

void lpf_plot(float data) {
  
  int multiplier = 100;
  float a = 0.5;
  lpf_y = a*lpf_y + (1-a)*data;
  
  lpf_x += 2;
  stroke(200, 102, 51);                      // ORANGE
  line(lpf_previous_x,350-(lpf_previous_y*multiplier),lpf_x,350-(lpf_y*multiplier));
  if(lpf_x > window_width) {
    lpf_x = 0;
    background(255);
    draw_x_axis();
  }
  lpf_previous_x = lpf_x;
  lpf_previous_y = lpf_y;

}

void integrator_plot(float data) {
  
  int multiplier = 100;
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

void complementary_filter(float accelerometer,float gyroscope) {
  
  float a = 0.98;
  
}

void draw_x_axis() {
  
  stroke(0,0,0);
  line(0,350,window_width,350);
  
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

void draw() {
   
  if(avr.available() >= 14) {
    for(int i=0;i<14;i++) {
    
      val = avr.read();
      data[i] = val;
      
    }
    calculate_sensor_values(data);
    //print_();
    //println(angle1);
    //println(angle2);
  }  
  
  float angle_acc_x = asin(limit(acc_data[0]-0.04))*57.2974; 
  float angle_acc_y = asin(limit(acc_data[1]))*57.2974;
  float angle_acc_z = asin(limit(acc_data[2]))*57.2974;
  
  float gyro_x = gyro_data[0];
  float gyro_y = gyro_data[1];
  float gyro_z = gyro_data[2];
  
  //pitch = (gyro_x*sampling_time);
  
  //println(angle_acc_x);
  //println(gyro_data[1]);
  
  //plot1(gyro_data[1]);
  //integrator_plot(gyro_data[1]);
  //plot2(angle_acc_x);
  
//  float b = 0.8;
//  acc_angle = b*(acc_angle) + (1-b)*angle_acc_x; 
//  
//  a = 0.95;
//  roll =  a*(roll - (gyro_data[1]*sampling_period)) + (1-a)*acc_angle;
//  plot1(roll);
//  plot2(angle_acc_x);
//  integrator_plot(-gyro_y);

  
//  print("angle_accc_x --> ");
//  print(angle_acc_x);
//  print("  ");
//  print("angle_accc_y --> ");
//  print(angle_acc_y);
//  print("  ");
//  print("angle_accc_z --> ");
//  print(angle_acc_z);
//  print("  ");
//  println();
  
  theta = asin(limit(acc_data[1]));

  phi = (atan(acc_data[2]/acc_data[0]))*57.2974;
  if(acc_data[0] < 0) {
    phi = 90 + phi;
  }
  if(acc_data[0] >= 0) {
    phi = -90 + phi;
  }
 
// print(phi); 
// print( "  "); 
// println(cos(phi/57.2974));
 
   float acc_x = acc_data[0] + sin(phi/57.2974);
// print(theta);
// print("  ");
// println(acc_x);
 

 float a = 0.93;
 acc_x = (acc_data[0] + sin(phi/57.2974));
 
 variable = variable*coe + (1-coe)*acc_x*10;
// plot1(vel_x*1000);
 //println(acc_data[0] + sin(phi/57.2974));
 if(acc_x > 0) {
   vel_x = 1;
 }
 if(acc_x < (-0.1)) {
   vel_x = -1;
 }
 else {
   vel_x = 0;
 }
 
 if(vel_x > 0) {
//   pos_x += 0.98*pos_x
 }
 if(vel_x <0) {
   pos_x -= 1;
 }
 //plot2(vel_x*1000);
// plot2(pos_x*10000);
 print_();
 acc_z = (acc_data[2] + cos(phi/57.2974));
// plot1(vel_x*1000);
 //println(acc_data[0] + sin(phi/57.2974));
 if(acc_z > 0) {
   vel_z = 1;
 }
 if(acc_z < (-0.1)) {
   vel_z = -1;
 }
 else {
   vel_z = 0;
 }
 
 if(vel_z > 0) {
//   pos_x += 0.98*pos_x
 }
 if(vel_z <0) {
   pos_z -= 1;
 }
// println(sin(theta/57.2974));
// print(acc_data[1]);
// print("  ");
// print(sin(theta));
// print("  ");
// float diff = acc_data[1] - sin(theta);
//println(diff);
// print(acc_x);
// print("  ");
// print(vel_x);
// print("  ");
// println(pos_x); 
 
 
 plot1(variable*100);
 plot2(pos_z*10);
}





