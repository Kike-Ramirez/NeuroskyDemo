import processing.serial.*;
import pt.citar.diablu.processing.mindset.*;
import processing.serial.*;

MindSet mindset;
float attention, attentionTarget;
float strength;

Serial myPort;  // Create object from Serial class



void setup() {
  size(1280, 1024);
  // attSamples = new ArrayList();
  mindset = new MindSet(this, "COM5");
  
  println(Serial.list());
  
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  
}


void draw() {
  
  background(0);
  
  stroke(255);
  fill(255);
  
  
  textSize(40);
  textAlign(CENTER, CENTER);
  text("Concéntrate en el punto rojo para encender el ventilador...", width/2, 100);
  
  attention += (attentionTarget - attention) * 0.01;
  
  float radius = map(attention, 0, 100, width * 1.1, 10);
  float colorLevel = map(attention, 0, 100, 10, 255);
  
  fill(colorLevel, 0, 0, colorLevel);
  stroke(colorLevel, 0, 0, colorLevel);
  ellipse(width/2, height/2, radius, radius);

  
  textSize(34);
  textAlign(CENTER,CENTER);
  
  if (attention >= 90) {
    
    fill(255);
    text("Conseguido!", width/2, height/2);
    myPort.write('1');
    
  }
  else myPort.write('0');
  
  fill(255);
  if (strength <= 60) {
    text("¡Ajusta tu diadema!",  width/2, height/2 + 20);
    attention = 0;
  }
 
  fill(255, 0, 0);
  noStroke();
  ellipse(width/2, height/2, 5, 5);

  
  fill(255);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Attention Level: " + attention, 10, height - 40);
  text("Signal level: " + strength + "%", 10, height - 60);
  
  noFill();
  stroke(255);
  radius = map(90, 0, 100, width * 1.1, 10);
  ellipse(width/2, height/2, radius, radius);
  
}


void keyPressed() {
  if (key == 'q') {
    mindset.quit();
    exit();
  }
}


public void poorSignalEvent(int sig) {
  
  strength = map(sig, 200, 0, 0, 100);
  
}

public void attentionEvent(int attentionLevel) {
  //println("Attention Level: " + attentionLevel);
  attentionTarget = attentionLevel;
//  attSamples.add(attention);
//  if (attSamples.size() > numSamples) {
//    attSamples.remove(0);
//  }
}

   
