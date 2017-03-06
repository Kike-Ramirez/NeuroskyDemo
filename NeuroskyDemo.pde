import processing.serial.*;
import pt.citar.diablu.processing.mindset.*;
import processing.serial.*;

MindSet mindset;
float attention, attentionTarget;
float strength;
PImage bombilla, bombillaluz;

int status;

Serial myPort;  // Create object from Serial class

color naranjaF6 = color(251, 132, 1);
color grisF6 = color(48, 52, 53);
PFont fontF6;
float levelON = 75;
float numSamples = 200;

ArrayList attSamples, sigSamples;

ArrayList   delta, theta, lowAlpha, highAlpha, lowBeta, highBeta, lowGamma, midGamma;



void setup() {
  size(1920, 1080);
  // attSamples = new ArrayList();
  mindset = new MindSet(this, "COM5");
  attSamples = new ArrayList();
  sigSamples = new ArrayList();
  delta = new ArrayList();
  theta = new ArrayList();
  lowAlpha = new ArrayList();
  highAlpha = new ArrayList();
  lowBeta = new ArrayList();
  highBeta = new ArrayList();
  lowGamma = new ArrayList();
  midGamma = new ArrayList();
  
  // println(Serial.list());
  
  String portName = Serial.list()[1];   
  myPort = new Serial(this, portName, 9600);
  
  bombilla = loadImage("iconoBombilla.png");
  bombillaluz = loadImage("iconoBombillaIluminada.png");
  
  fontF6 = loadFont("Gotham-Black-48.vlw");
  textFont(fontF6);
  
  status = 0;
  
}


void draw() {
  
  if (status == 0) {
  
    background(naranjaF6);
    textAlign(CENTER, CENTER);
    fill(grisF6);
    noStroke();
    
    text("FULLSIX EEG Sensor DEMO", width/2, height/2);
  }
  
  
  if (status == 1) {
  
    background(grisF6);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    
    drawDiagram2(delta, 50, height/2 - 380, 400, 200);
    text("delta",  50 + 200, height/2 - 130);
    drawDiagram2(theta, 50, height/2 - 80, 400, 200);
    text("theta",  50 + 200, height/2 + 170);
    drawDiagram2(lowAlpha, 50, height/2 + 220, 400, 200);
    text("low alpha",  50 + 200, height/2 + 470);

    drawDiagram2(highAlpha, 50 + width/3, height/2 - 380, 400, 200);
    text("high alpha",  50 + width/3 + 200, height/2 - 130);
    drawDiagram2(lowBeta, 50 + width/3, height/2 - 80, 400, 200);
    text("low beta",  50 + width/3 + 200, height/2 + 170);
    drawDiagram2(highBeta, 50 + width/3, height/2 + 220, 400, 200);
    text("high beta",  50 + width/3 + 200, height/2 + 470);

    drawDiagram2(lowGamma, 50 + width*2/3, height/2 - 380, 400, 200);
    text("low gamma",  50 + width*2/3 + 200, height/2 - 130);
    drawDiagram2(midGamma, 50 + width*2/3, height/2 - 80, 400, 200);
    text("mid gamma",  50 + width*2/3 + 200, height/2 + 170);
    drawDiagram(sigSamples, 50 + width*2/3, height/2 + 220, 400, 200);
    text("signal level",  50 + width*2/3 + 200, height/2 + 470);

}
  
  if (status == 2) {
    background(naranjaF6);
    textSize(60);
    
   
    image(bombilla, 0, 0, width, height);
    
    attention += (attentionTarget - attention) * 0.01;
    
    float radius = map(attention, 0, 100, height, 285);
    float colorLevel = map(attention, 0, 100, 10, 255);
    
    //fill(colorLevel, 0, 0, colorLevel);
    //stroke(colorLevel, 0, 0, colorLevel);
    //ellipse(width/2, height/2, radius, radius);
    drawCircle(radius);
    
    textAlign(CENTER,CENTER);
    
    if (attention >= levelON) {
      
      fill(255);
      text("¡CONSEGUIDO!", width/2, height - 200);
      myPort.write('1');
      image(bombillaluz, 0, 0, width, height);
      
    }
    else myPort.write('0');
    
    fill(255);
    if (strength <= 60) {
      text("¡AJUSTA TU DIADEMA!", width/2, height - 200);
      attention = 0;
    }
  
  
    fill(255);  
    textAlign(CENTER, CENTER);
    text("CONCÉNTRATE EN LA BOMBILLA PARA ENCENDERLA", width/2, 100);
    
    fill(255);
    textSize(30);
    textAlign(LEFT, CENTER);
    if (attention < 10) text("Concentración:  " + int(attention) + " %", 50, height/2 + 50);
    else text("Concentración: " + int(attention) + " %", 50, height/2 + 50);
    drawDiagram(attSamples, 50, height/2 - 80, 300, 100);
    
    textAlign(RIGHT, CENTER);
    text("Señal: " + strength + "%", width - 50, height/2 + 50);
    drawDiagram(sigSamples, width - 50 - 300, height/2 - 80, 300, 100);
  
    noFill();
    stroke(grisF6);
    strokeWeight(1);
    radius = map(levelON, 0, 100, height, 285);
    ellipse(width/2, height/2, radius, radius);
    
    attSamples.add(attention);
    if (attSamples.size() > numSamples) attSamples.remove(0);
  

  
  }
  
  
}


void keyPressed() {
  if (key == 'q') {
    mindset.quit();
    exit();
  }
  
  if (key == ' ') {
  
    status++;
    if (status == 3) status = 1;
  }
  
  else saveFrame();

}


public void poorSignalEvent(int sig) {
  println("PoorSignalEvent: " + sig);
  strength = map(sig, 200, 0, 0, 100);
  sigSamples.add(strength);
  if (sigSamples.size() > numSamples) sigSamples.remove(0);  
}

public void attentionEvent(int attentionLevel) {
  println("Attention Level: " + attentionLevel);
  attentionTarget = attentionLevel;
//  attSamples.add(attention);
//  if (attSamples.size() > numSamples) {
//    attSamples.remove(0);
//  }
}

public void drawCircle(float radius) 
{
  int nSegmentos = 40;
  
  if (radius > height) radius = height;
  strokeWeight(3);
  stroke(grisF6);
  noFill();
  pushMatrix();
  translate(width/2, height/2);
  rotate(millis()/5000.0);
  for(int i = 0; i < nSegmentos; i++) {
  
    arc(0, 0, radius, radius, i * 2 * PI/nSegmentos, (i + 0.5) * 2 * PI/nSegmentos);
    
  }
  
  popMatrix();
}

public void drawDiagram(ArrayList list, int x_, int y_, int w_, int h_) {

  strokeWeight(2);
  if (status == 2) stroke(grisF6);
  else stroke(naranjaF6);
  noFill();
  line(x_, y_ + h_, x_+w_, y_ + h_);
  line(x_, y_, x_, y_ + h_);
  
  strokeWeight(4);
  stroke(255);
  for (int i = 0; i < list.size()-1; i++) {
  
    int x1 = int( map(i, 0, list.size()-1, x_, x_ + w_) );
    float v1 = ((Float)list.get(i)).floatValue();
    int y1 = int( map(v1, 0, 100, y_ + h_, y_) );

    int x2 = int( map(i+1, 0, list.size()-1, x_, x_ + w_) );
    float v2 = ((Float)list.get(i+1)).floatValue();
    int y2 = int( map(v2, 0, 100, y_ + h_, y_) );
    
    line(x1, y1, x2, y2);
    
  }
}

public void drawDiagram2(ArrayList list, int x_, int y_, int w_, int h_) {

  strokeWeight(2);
  if (status == 2) stroke(grisF6);
  else stroke(naranjaF6);
  noFill();
  line(x_, y_ + h_, x_+w_, y_ + h_);
  line(x_, y_, x_, y_ + h_);
  
  float maxList = 0;
  
  for (int i = 0; i < list.size(); i++) {
  
    if (((Integer)list.get(i)).intValue() > maxList) maxList = ((Integer)list.get(i)).intValue();
  
  }
  
  strokeWeight(4);
  stroke(255);
  for (int i = 0; i < list.size()-1; i++) {
  
    int x1 = int( map(i, 0, list.size()-1, x_, x_ + w_) );
    float v1 = ((Integer)list.get(i)).intValue();
    int y1 = int( map(v1, 0, maxList, y_ + h_, y_) );

    int x2 = int( map(i+1, 0, list.size()-1, x_, x_ + w_) );
    float v2 = ((Integer)list.get(i+1)).intValue();
    println(v2);
    int y2 = int( map(v2, 0, maxList, y_ + h_, y_) );
    
    line(x1, y1, x2, y2);
    
  }
}

public void eegEvent(int delta_, int theta_, int low_alpha_, 
int high_alpha_, int low_beta_, int high_beta_, int low_gamma_, int mid_gamma_) {
  println("hola");
  delta.add(delta_);
  if (delta.size() > numSamples) delta.remove(0);
  theta.add(theta_);
  if (theta.size() > numSamples) theta.remove(0);
  lowAlpha.add(low_alpha_);
  if (lowAlpha.size() > numSamples) lowAlpha.remove(0);
  highAlpha.add(high_alpha_);
  if (highAlpha.size() > numSamples) highAlpha.remove(0);
  lowBeta.add(low_beta_);
  if (lowBeta.size() > numSamples) lowBeta.remove(0);
  highBeta.add(high_beta_);
  if (highBeta.size() > numSamples) highBeta.remove(0);
  lowGamma.add(low_gamma_);
  if (lowGamma.size() > numSamples) lowGamma.remove(0);
  midGamma.add(mid_gamma_);
  if (midGamma.size() > numSamples) midGamma.remove(0);
} 