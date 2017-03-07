/*

Demo uso Neurosky MindWave
FULLSIX

Autor: K. Ramírez
Fecha: 7/3/2017
*/


// Importación librerías
import processing.serial.*;
import pt.citar.diablu.processing.mindset.*;


// Definición de objetos y variables
MindSet mindset;
float attention, attentionTarget;
float strength;
PImage bombilla, bombillaluz;
color naranjaF6 = color(251, 132, 1);
color grisF6 = color(48, 52, 53);
PFont fontF6;
float fontSize1, fontSize2;
float levelON = 75;          // Porcentaje de concentración necesario para encender la luz
float numSamples = 200;      // Número de muestras a guardar en los arrays

boolean testing = true;      // Modo de testing (sin diadema).

// Arraylist para guardar todos los datos de las graficas
ArrayList attSamples, sigSamples, delta, theta, lowAlpha, highAlpha, lowBeta, highBeta, lowGamma, midGamma;

int status;      // Estados: 0/ Pantalla Inicial, 1/ Gráficas, 2/ Juego

Serial myPort;  // Objeto Puerto Serie
 


void setup() {
  
  // Tamaño de ventana ajustable
  size(1366, 768);
  
  // Definimos el objeto Mindset (chequear puerto COM)
  if (!testing) mindset = new MindSet(this, "COM5");
  
  // Inicializamos los arraylists
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
  
  // Usar esto para listar los puertos series al configurar
  // println(Serial.list());
  
  // Inicializamos nuestro puerto serie
  String portName = Serial.list()[0];   
  myPort = new Serial(this, portName, 9600);
  
  // Cargamos la customización
  bombilla = loadImage("iconoBombilla.png");
  bombillaluz = loadImage("iconoBombillaIluminada.png");
  fontF6 = loadFont("Gotham-Black-48.vlw");
  textFont(fontF6);
  fontSize1 = 0.04 * width;
  fontSize2 = 0.015 * width;
  
  // Definimos el estado inicial (pantalla de bienvenida)
  status = 0;
    
}


void draw() {
  
  
  // Acciones a realizar en la pantalla de bienvenida
  if (status == 0) {
  
    // Fondo naranja FULLSIX
    background(naranjaF6);
    textAlign(CENTER, CENTER);
    // Texto gris FULLSIX
    fill(grisF6);
    noStroke();
    
    // Dibujar texto carátula
    text("FULLSIX EEG Sensor DEMO", width/2, height/2);
  
  }
  
  // Acciones a realizar en la pantalla de gráficas
  if (status == 1) {
  
    // Fondo gris FULLSIX
    background(grisF6);
    // Texto blanco
    fill(255);
    textSize(fontSize2);
    textAlign(CENTER, TOP);
    
    // Definimos parametros de maquetación
    // m: margen
    // p: anchura de gráfica
    float m = 0.1;
    float p = 0.2;
    
    // Dibujamos todas las gráficas en rejilla de 9x9 con sus textos debajo
    drawDiagram2(delta, m * width, m * height, p * width, p * height);
    text("delta",  (m + p * 0.5) * width, (m + p + 0.01) * height);
    drawDiagram2(theta, (m) * width, (2 * m + p) * height, p * width, p * height);
    text("theta",  (m + p * 0.5) * width, (2 * m + 2 * p + 0.01) * height);
    drawDiagram2(lowAlpha, (m) * width, (3 * m + 2 * p) * height, p * width, p * height);
    text("low alpha",  (m + p * 0.5) * width, (3 * m + 3 * p + 0.01) * height);

    drawDiagram2(highAlpha, (2 * m + p) * width, m * height, p * width, p * height);
    text("high alpha",  (2 * m + p * 1.5) * width, (m + p + 0.01) * height);
    drawDiagram2(lowBeta, (2 * m + p) * width, (2 * m + p) * height, p * width, p * height);
    text("low beta",  (2 * m + p * 1.5) * width, (2 * m + 2 * p + 0.01) * height);
    drawDiagram2(highBeta, (2 * m + p) * width, (3 * m + 2 * p) * height, p * width, p * height);
    text("high beta", (2 * m + p * 1.5) * width, (3 * m + 3 * p + 0.01) * height);

    drawDiagram2(lowGamma, (3 * m + 2 * p) * width, m * height, p * width, p * height);
    text("low gamma",  (3 * m + p * 2.5) * width, (m + p + 0.01) * height);
    drawDiagram2(midGamma, (3 * m + 2 * p) * width, (2 * m + p) * height, p * width, p * height);
    text("mid gamma",  (3 * m + p * 2.5) * width, (2 * m + 2 * p + 0.01) * height);
    drawDiagram(sigSamples, (3 * m + 2 * p) * width, (3 * m + 2 * p) * height, p * width, p * height);
    text("signal level",  (3 * m + p * 2.5) * width, (3 * m + 3 * p + 0.01) * height);

  }
  
  
  // Acciones a realizar en la pantalla de "Juego Bombilla"
  else if (status == 2) {
    
    // Fondo naranja FULLSIX
    background(naranjaF6);
    textSize(fontSize1);
    
    // Dibujamos el logo de la bombilla
    image(bombilla, 0, 0, width, height);

    // Recalculamos el nivel de concentración de esta manera para que tenga cambio continuo
    attention += (attentionTarget - attention) * 0.01;
    
    // Dibujamos el círculo punteado
    float radius = map(attention, 0, 100, height, 285);
    drawCircle(radius);
    
    // Dibujar círculo con el nivel necesario para ganar
    noFill();
    stroke(grisF6);
    strokeWeight(1);
    radius = map(levelON, 0, 100, height, 285);
    ellipse(width/2, height/2, radius, radius);
    
    textAlign(CENTER,CENTER);
    
    // Si superamos el umbral de concentración
    if (attention >= levelON) {
      
      // Escribir texto, añadir logo y enviar dato a puerto serie
      text("¡CONSEGUIDO!", 0.5 * width, 0.8 * height);
      myPort.write('1');
      image(bombillaluz, 0, 0, width, height);
      
    }
    
    // En otro caso solo enviar dato a puerto serie
    else myPort.write('0');
    
    
    // Si el nivel de señal es bajo, mostrar texto indicativo
    if (strength <= 60) {
      text("¡AJUSTA TU DIADEMA!", 0.5 * width, 0.8 * height);
      attention = 0;
    }
  
    // Escribir texto fijo con instrucciones en la parte superior  
    text("CONCÉNTRATE EN LA BOMBILLA \n PARA ENCENDERLA", 0.5 * width, 0.15 * height);
    
    // Dibujar gráfica de nivel de concentración con su texto
    textSize(fontSize2);
    textAlign(LEFT, CENTER);
    if (attention < 10) text("Concentración:  " + int(attention) + " %", 0.02 * width, 0.56 * height);
    else text("Concentración: " + int(attention) + " %", 0.02 * width, 0.56 * height);
    drawDiagram(attSamples, 0.02 * width, 0.38 * height, 0.15 * width, 0.15 * height);
    
    // Dibujar gráfica de nivel de señal con su texto
    textAlign(RIGHT, CENTER);
    text("Señal: " + strength + "%", 0.98 * width, 0.56 * height);
    drawDiagram(sigSamples, 0.83 * width, 0.38 * height, 0.15 * width, 0.15 * height);
 
  }
  
  // Siempre añadir aquí la muestra de concentración a su array (el resto lo hacemos en los eventos respectivos, esta se trata distinta)
  attSamples.add(attention);
  if (attSamples.size() > numSamples) attSamples.remove(0);
  
  // Si estamos en modo Testing generamos valores aleatorios para todas las gráficas
  if (testing) updateTesting();
  
  
}

// Función auxiliar que genera valores aleatorios para todas las gráficas y los
// añade al array
void updateTesting() {
  
  attentionTarget = 50.0 + 50 * sin(frameCount/100.0f);
  
  sigSamples.add(random(100));
  if (sigSamples.size() > numSamples) sigSamples.remove(0);  
  delta.add(int(random(100)));
  if (delta.size() > numSamples) delta.remove(0);
  theta.add(int(random(100)));
  if (theta.size() > numSamples) theta.remove(0);
  lowAlpha.add(int(random(100)));
  if (lowAlpha.size() > numSamples) lowAlpha.remove(0);
  highAlpha.add(int(random(100)));
  if (highAlpha.size() > numSamples) highAlpha.remove(0);
  lowBeta.add(int(random(100)));
  if (lowBeta.size() > numSamples) lowBeta.remove(0);
  highBeta.add(int(random(100)));
  if (highBeta.size() > numSamples) highBeta.remove(0);
  lowGamma.add(int(random(100)));
  if (lowGamma.size() > numSamples) lowGamma.remove(0);
  midGamma.add(int(random(100)));
  if (midGamma.size() > numSamples) midGamma.remove(0);

}


// Gestión de teclado
void keyPressed() {
  
  // Si pulsamos 'q', salir y cerrar todo
  if (key == 'q') {
    if (!testing) mindset.quit();
    myPort.write('0');
    exit();
  }
}

// Si pulsamos el ratón cambiamos de pantalla
void mousePressed() {

  status++;
  if (status == 3) status = 1;

}

// Evento que actualiza la señal de mindset
public void poorSignalEvent(int sig) {
  strength = map(sig, 200, 0, 0, 100);
  sigSamples.add(strength);
  if (sigSamples.size() > numSamples) sigSamples.remove(0);  
}

// Evento que actualiza el nivel de concentración medido
public void attentionEvent(int attentionLevel) {
  attentionTarget = attentionLevel;
}

// Función que dibuja un círculo punteado y giratorio
public void drawCircle(float radius) 
{
  // Número de segmentos para dibujar el círculo
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


// Función que dibuja un diagrama con los datos de un array de flotantes, posiciones, anchura y altura
public void drawDiagram(ArrayList list, float x_, float y_, float w_, float h_) {

  strokeWeight(2);
  if (status == 2) stroke(grisF6);
  else stroke(255);
  noFill();
  line(x_, y_ + h_, x_+w_, y_ + h_);
  line(x_, y_, x_, y_ + h_);
  
  strokeWeight(3);
  if (status == 2) stroke(255);
  else stroke(naranjaF6);
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

// Función que dibuja un diagrama con los datos de un array de enteros, posiciones, anchura y altura
public void drawDiagram2(ArrayList list, float x_, float y_, float w_, float h_) {

  strokeWeight(2);
  if (status == 2) stroke(grisF6);
  else stroke(255);
  noFill();
  line(x_, y_ + h_, x_+w_, y_ + h_);
  line(x_, y_, x_, y_ + h_);
  
  float maxList = 0;
  
  for (int i = 0; i < list.size(); i++) {
  
    if (((Integer)list.get(i)).intValue() > maxList) maxList = ((Integer)list.get(i)).intValue();
  
  }
  
  strokeWeight(3);
  if (status == 2) stroke(255);
  else stroke(naranjaF6);
  for (int i = 0; i < list.size()-1; i++) {
  
    int x1 = int( map(i, 0, list.size()-1, x_, x_ + w_) );
    float v1 = ((Integer)list.get(i)).intValue();
    int y1 = int( map(v1, 0, maxList, y_ + h_, y_) );

    int x2 = int( map(i+1, 0, list.size()-1, x_, x_ + w_) );
    float v2 = ((Integer)list.get(i+1)).intValue();
    int y2 = int( map(v2, 0, maxList, y_ + h_, y_) );
    
    line(x1, y1, x2, y2);
    
  }
}

// Evento que actualiza todos los valores de las señales EEG
public void eegEvent(int delta_, int theta_, int low_alpha_, 
int high_alpha_, int low_beta_, int high_beta_, int low_gamma_, int mid_gamma_) {
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