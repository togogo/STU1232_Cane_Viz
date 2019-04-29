import controlP5.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
String connectedPort;//stores the name of the connected port

int dataSize = 4;

int[] serialInArray = new int[dataSize]; // Where we’ll put what we receive
int serialCount = 0;     // A count of how many bytes we receive

ArrayList<String> incomingList;

void setup() {
 
  
  printArray(Serial.list());
  String portName = Serial.list()[0]; //change the value to match your port.
  myPort = new Serial(this, portName, 9600);
  
  
  size(500, 500);
  
  //print(portName);

}


void draw() {
  
  
  if (myPort.available() > 0) 
  {  
    // If data is available,
    val = myPort.readStringUntil('\n');// read it and store it in val
    println(val);
    //incomingList = (ArrayList<String>)Arrays.asList(val.split(","));
    //List<String> elephantList = Arrays.asList(val.split(","));
    //incomingList = Arrays.asList(val.split(","));
  } 
  
}
