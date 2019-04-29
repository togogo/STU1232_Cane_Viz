import controlP5.*;
import processing.serial.*;


ControlP5 cp5;
String textValue = "";

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
String connectedPort;//stores the name of the connected port

int dataSize = 4;//It is three because there are 3 values: x, y, and z.
int[] serialInArray = new int[dataSize];//Where we’ll put what we receive from the hardware
int serialCount = 0;// A count of how many bytes we receive

ArrayList<String> incomingList;


//color palettes
color scrBG = color(50);
color plotBG = color(80);
color white = color(255);
color lineCol = color(127, 23, 255);


//possible max/min values coming from the accelerometer
int maxVal = 360;
int minVal = -360;

//not sure if I'm going to need them, but I'm gonna write them anyway
int x;
int y;
int z;

int vib;//incoming vibration values

//plots of x,y,z
ArrayList<Integer> xPlot = new ArrayList<Integer>();
ArrayList<Integer> yPlot = new ArrayList<Integer>();
ArrayList<Integer> zPlot = new ArrayList<Integer>();

int PlotH = 280;
int PlotW = 800;
int PlotN = 60;

int xPlotStartXPos = 840;
int xPlotStartYPos = PlotN;
int xPlotW = PlotW;
int xPlotH = PlotH;

int yPlotStartXPos = 840;
int yPlotStartYPos = xPlotH + PlotN*2;
int yPlotW = PlotW;
int yPlotH = PlotH;

int zPlotStartXPos = 840;
int zPlotStartYPos = yPlotH + xPlotH + PlotN*3;
int zPlotW = PlotW;
int zPlotH = PlotH;

PImage logo;

int textMid = 20;
int textSmall = 15;



void setup() {

  size(1680, 1050, P3D);
  
  cp5 = new ControlP5(this);
  
  PFont font = createFont("arial", textSmall);

  printArray(Serial.list());//get available list of serials
  String portName = Serial.list()[8]; //change the value to match your port.
  myPort = new Serial(this, portName, 9600);
  connectedPort = portName;
  
  
  cp5.addTextfield("command")
     .setPosition(15,110)
     .setSize(300,40)
     .setFont(font)
     .setAutoClear(false)
     ;
       
  cp5.addBang("send")
     .setPosition(340,110)
     .setSize(80,40)
     .setFont(font)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;   


  logo = loadImage("cady_logo.png");
}


void draw() {

  background(scrBG);

  image(logo, 10, 10, (int)195*0.8, (int)78*0.8);
  textSize(textMid);
  fill(white);
  text("Device Control User Interface", 170, 52);
  textSize(textSmall);
  text("Connected Serial:" + connectedPort, 15, 90);

  textSize(textMid);
  text("X Rotation:", xPlotStartXPos, xPlotStartYPos - textMid/2);
  text("Y Rotation:", yPlotStartXPos, yPlotStartYPos - textMid/2);
  text("Z Rotation:", zPlotStartXPos, zPlotStartYPos - textMid/2);
  
  
  fill(plotBG);
  noStroke();
  //rect(10,  400, 500, 500);


  if (myPort.available() > 0) 
  {  
    /* If data is available, read all the strings line by line.
     Then, split the read string based on comma.
     */
    val = myPort.readStringUntil('\n');// read it and store it in val
    //println(val);//this guys is working

    //these guys are not used...
    //incomingList = (ArrayList<String>)Arrays.asList(val.split(","));
    //List<String> elephantList = Arrays.asList(val.split(","));
    //incomingList = Arrays.asList(val.split(","));
  }

  if (val == null) {
    //tempSize = ellipseSize;
    //if there is null data, replace with something...
    //x = 0;
    //y = 0;
    //z = 0;
  } else {

    //println(val);
    String[] tempList = split(val, ',');
    //String[] arrOfStr = val.split(",", dataSize);
    //String[] arrOfStr = val.split(",", splitSize);
    //println(tempList.length);

    //val = val.replaceAll("\\D+", "");
    //ellipseSize = Integer.valueOf(val);
    //tempSize = Integer.valueOf(val);
    //println(val);

    if (tempList.length == dataSize) {
      for (int i = 0; i < dataSize; i++) {
        tempList[i] = tempList[i].replaceAll("\\D+", "");
        //println(tempList[0]);
        serialInArray[i] = Integer.valueOf(tempList[i]);
        x = serialInArray[0];
        y = serialInArray[1];
        z = serialInArray[2];
        vib = serialInArray[3];
      }
    }
  }



  //plot x, y, z graphs
  //plotGraph(xPlotStartXPos, xPlotStartYPos, xPlotW, xPlotH, mouseY, xPlot);
  //plotGraph(yPlotStartXPos, yPlotStartYPos, yPlotW, yPlotH, mouseY, yPlot);
  //plotGraph(zPlotStartXPos, zPlotStartYPos, zPlotW, zPlotH, mouseY, zPlot);

  plotGraph(xPlotStartXPos, xPlotStartYPos, xPlotW, xPlotH, x, xPlot);
  plotGraph(yPlotStartXPos, yPlotStartYPos, yPlotW, yPlotH, y, yPlot);
  plotGraph(zPlotStartXPos, zPlotStartYPos, zPlotW, zPlotH, z, zPlot);
  
  plotVib();
  
  println(vib);
}

public void send() {
  
  //also whatever to send the value to arduino
  textValue = cp5.get(Textfield.class,"command").getText(); 
  //println(textValue);
  myPort.write(textValue);
  cp5.get(Textfield.class,"command").clear();
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
}

public void command(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}



void plotGraph(int _x, int _y, int _w, int _h, int _val, ArrayList<Integer> _l) {
  /*
NOTE:
   A small function to plot the graph of a given intake value.
   _x:starting x-pos of the plot 
   _y:starting y-pos of the plot
   _w:width of the plot
   _h:height of the plot
   _val:intake value that needs to be plotted.
   _l:empty ArrayList to depict the graph (consecutive numerous lines) 
   */

  //draw a rect to where the plot is going to be drawn
  fill(plotBG);
  noStroke();
  rect(_x, _y, _w, _h);

  //map the incoming value of 0 to 360 to fit within the size of the plot
  int mappedVal = (int)map(_val, maxVal, minVal, _y, _y + _h);//how it will be in the real thing
  //int mappedVal = (int)map((float)_val, 0, (float)height, (float)_y, (float)(_y + _h));

  //always make the last index with the latest values recorded
  _l.add(mappedVal);

  stroke(lineCol);
  strokeWeight(1);

  for (int i = 0; i < _l.size(); i++) {
    line(_x + _w - (_l.size() - i), _y + _h/2, _x + _w - (_l.size() - i), _l.get(i));

    //an attempt to make the visualization nicer.
    //beginShape(LINES);
    //fill(lineCol);
    //vertex(nudgeY + graphW - (plots.size() - i), nudgeY + graphH/2);
    //fill(255, 0, 0);
    //vertex(nudgeY + graphW - (plots.size() - i), plots.get(i));
    //endShape();
  } 

  if (_l.size() > _w) {
    _l.remove(0);
  }
  
  stroke(white);
  line(_x, _y + _h/2, _x + _w, _y + _h/2);
  
  fill(white);
  textSize(textSmall);
  text("current incoming: " + _val, _x, _y + textSmall);
  
  fill(white);
  textSize(textSmall);
  text(maxVal, _x + _w - 30, _y + textSmall);
  text(minVal, _x + _w - 38, _y + _h);
}

void plotVib(){
  
  //ellipse();
}
