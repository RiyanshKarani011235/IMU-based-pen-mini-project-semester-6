import processing.serial.*;

Serial avr;
int val;
int previous_val = 0;
int data = 0;
int count = 0;

void setup() {
  
  println(avr.list());
  String portname = Serial.list()[3];
  println(portname);
  avr = new Serial(this,portname,9600);
  avr.clear();
  
}

void draw() {
  
  if(avr.available() > 0) {
    val = avr.available();
    if(val != previous_val) {
      
//      println(val);
//      previous_val = val;
      data = avr.read();
      println(data);
      count ++;
      println(count);
      
    }
      //data = avr.readStringUntil('\n');
      
  }
  
}
