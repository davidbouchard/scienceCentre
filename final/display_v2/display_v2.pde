import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*;
import java.io.*;
import netP5.*;
import oscP5.*;
import deadpixel.keystone.*;
import java.net.*;
import java.util.*;

import com.jogamp.opengl.*;


// TODO list:
// - add an overlay timer so the text disappears before the characters has shown up
// - generally redesign overlay to be less contrived, if we want to add more messages
// - figureout what to do with the outline (do we fix assets OR do we automatically re-color)
// - add a heartbeat script (maybe through a new controller in the database?)

// GLOBAL PARAMETERS

int INFO_TIMEOUT; // timeout for the info screen
int TIMEOUT;  // in seconds, this controls the amount of time the creature will stay on the screen 
float SPIN_SPEED_MAX = 0.005;

int MAX_PIXEL_SIZE;
int MIN_PIXEL_SIZE;

OscP5 osc;
int listeningPort = 9000;

Model prevModel;
Model model;
MaskAnimator mAnim = new MaskAnimator();

Timer timer = new Timer(1000); 
Timer overlayTimer = new Timer(1000);

Overlay overlay;

Model arrow;
Model bounds_big;
Model bounds_small;

String lastCode = "";
String[] areaNames = {"sci", "hum", "liv", "inn", "spa"};
HashMap<String, String> areaFullNames = new HashMap();

enum State {
  FADE_IN_PREVIOUS, FADE_IN_WAIT, FADE_IN_CURRENT, FADE_OUT, 
    SPIN, IDLE, INFO, BOUNDS_BIG, BOUNDS_SMALL
} 

// The current area
String AREA;

// This will cause the text to be mirrored (Only in fullscreen) 
boolean mirrorOverlay;

State state = State.IDLE;

float spinAngle = 0;
float spinSpeed = SPIN_SPEED_MAX;

float fadeOut;

// Keystone
int widthLonger = 800;
int widthShorter = 800;

PGraphics left;
PGraphics middle;
PGraphics right;

Keystone ks1;
CornerPinSurface surface1;
CornerPinSurface surface2;
CornerPinSurface surface3;

Sounds sounds;
PFont bitFont; 

PJOGL pgl;
GL2ES2 gl;

Properties configFile;

//===================================================
void settings() {
  // Load properties 
  try {
    configFile = new Properties();
    String dp = dataPath("config.properties");
    FileInputStream f = new FileInputStream(dp);
    configFile.load(f);
    println(configFile);
    AREA = configFile.getProperty("AREA");

    overlayY = Integer.parseInt(configFile.getProperty("OVERLAY_Y"));
    overlayX = Integer.parseInt(configFile.getProperty("OVERLAY_X"));

    INFO_TIMEOUT = Integer.parseInt(configFile.getProperty("INFO_TIMEOUT")); 
    TIMEOUT = Integer.parseInt(configFile.getProperty("TIMEOUT"));

    MAX_PIXEL_SIZE = Integer.parseInt(configFile.getProperty("MAX_PIXEL_SIZE"));
    MIN_PIXEL_SIZE = Integer.parseInt(configFile.getProperty("MIN_PIXEL_SIZE"));

    int fs = Integer.parseInt(configFile.getProperty("FULLSCREEN"));
    if (fs == 1) {
      fullScreen(P3D);
      mirrorOverlay = true;
    } else {
      int w =  Integer.parseInt(configFile.getProperty("WIN_W"));
      int h =  Integer.parseInt(configFile.getProperty("WIN_H"));      
      size(w, h, P3D);
      mirrorOverlay = false;
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}


void setup() {  
  // required on the PI or textures won't work
  hint(DISABLE_TEXTURE_MIPMAPS);
  noCursor();

  overlay = new Overlay();

  // this will run again everytime the INFO card is scanned, but just set initial values  
  checkIPs();
  thread("heartbeat"); // start the heartbeat thread

  // this is used to show the full name on screen in the INFO state
  areaFullNames.put("liv", "Living Earth");
  areaFullNames.put("inn", "Innovation Centre");
  areaFullNames.put("spa", "Space");
  areaFullNames.put("hum", "Human Edge");
  areaFullNames.put("sci", "Science Arcade");

  // I think this does fuck all.
  pgl = (PJOGL)beginPGL();
  gl = pgl.gl.getGL2ES2();
  gl.glEnable(gl.GL_CULL_FACE);
  endPGL();

  // PI simulator!
  //frameRate(10);

  osc = new OscP5(this, listeningPort);
  osc.plug(this, "scan", "/scan"); 

  // Used to display the character + transition from previous character
  prevModel = new Model();
  model = new Model();

  // The IDLE state graphic 
  arrow = new Model();
  PImage arrowImage = loadImage("arrow.png");
  arrow.setImage(arrowImage, null, arrowImage, null); 

  // Some test graphics to calibrate
  bounds_big = new Model();
  PImage boundsBigImg = loadImage("bounds_big.png");
  bounds_big.setImage(boundsBigImg, null, boundsBigImg, null); 
  bounds_big.fillMask();

  bounds_small = new Model();
  PImage boundsSmallImg = loadImage("bounds_small.png");
  bounds_small.setImage(boundsSmallImg, null, boundsSmallImg, null); 
  bounds_small.fillMask();

  ks1 = new Keystone(this);
  surface1 = ks1.createCornerPinSurface(widthLonger, widthShorter, 20);
  left = createGraphics(widthLonger, widthShorter, P3D);
  surface2 = ks1.createCornerPinSurface(widthShorter, widthLonger, 20);
  middle = createGraphics(widthShorter, widthLonger, P3D);
  surface3 = ks1.createCornerPinSurface(widthLonger, widthShorter, 20);
  right = createGraphics(widthLonger, widthShorter, P3D);

  ks1.load();
  ap = surface2; // for calibration, select middle surface to begin with 

  bitFont = createFont("PressStart2P.ttf", 24);
  textFont(bitFont);
  left.textFont(bitFont);
  middle.textFont(bitFont);
  right.textFont(bitFont);

  state = State.IDLE;

  sounds = new Sounds(this);
}

//===================================================
void draw() {
  // Left
  left.beginDraw();  
  left.background(0, 0);
  left.translate(left.width/2, left.height/2);
  left.rotateZ(radians(270));
  left.rotateY(spinAngle);
  renderScene(left);
  left.endDraw();

  // right
  right.beginDraw();  
  right.background(0, 0);
  right.translate(right.width/2, right.height/2);
  right.rotateZ(radians(90));
  right.rotateY(spinAngle);
  renderScene(right);
  right.endDraw();

  // middle 
  middle.beginDraw();  
  middle.background(0, 0);
  middle.pushMatrix();
  middle.translate(middle.width/2, middle.height/2);
  middle.rotateY(radians(90));
  middle.rotateY(spinAngle);
  renderScene(middle);
  middle.popMatrix();
  middle.endDraw();

  // draw using the surface objects
  background(0);
  surface1.render(left);
  surface2.render(middle);
  surface3.render(right);

  // render the overlay on the main graphics surface 
  overlay.render(g);

  if (ks1.isCalibrating()) {
    textAlign(LEFT);
    textSize(12);    
    text("Lock sides: " + lockSides, 30, 25);
    text("Move by: " + moveBy, 30, 50);
    text("Overlay Y: " + overlayY, 30, 75);
    text("Min Pixel Size: " + MIN_PIXEL_SIZE, 30, 100);
    text("Max Pixel Size: " + MAX_PIXEL_SIZE, 30, 125);
  }
}

//===================================================
// Use for text / this will not rotate and only appear in the middle panel 

//===================================================
void renderScene(PGraphics g) {
  // or is it without the g.? 
  // lights() don't work at all. need to try shader or bust.
  // g.lights();

  switch(state) {
    //---------------------------------------------
  case FADE_IN_PREVIOUS:
    mAnim.pixelateIn(prevModel.mask);
    prevModel.renderFrontOnlyRect(g); 
    if (mAnim.done) {
      mAnim.reset();
      state = State.FADE_IN_WAIT;
      timer = new Timer(1000);
    }
    break;

    //---------------------------------------------
  case FADE_IN_WAIT:
    prevModel.renderFrontOnlyRect(g); 
    if (timer.isFinished()) {
      state = State.FADE_IN_CURRENT;
      sounds.playTransition();
    }
    break;

    //---------------------------------------------
  case FADE_IN_CURRENT:
    mAnim.pixelateIn(model.mask);
    mAnim.reverse(prevModel.mask, model.mask);
    prevModel.renderFrontOnlyRect(g);
    model.renderFrontOnlyRect(g); 
    if (mAnim.done) {
      state = State.SPIN;
      timer = new Timer(1000 * TIMEOUT); 
      spinSpeed = 0;
      fadeOut = 1;
      sounds.playTransition();
    }
    break;

    //---------------------------------------------
  case SPIN:
    spinAngle += spinSpeed;
    if (spinSpeed < SPIN_SPEED_MAX) spinSpeed += 0.0001; 
    if (timer.isFinished()) {
      if (fadeOut > 0) fadeOut -= 0.01;
      else {
        sounds.fadeOut();
        // load new sounds 
        state = State.IDLE;
      }
    }

    model.renderFast(g); // use the cache
    break;

    //---------------------------------------------
  case IDLE:
    spinSpeed = SPIN_SPEED_MAX;
    spinAngle += spinSpeed;
    arrow.renderFast(g);
    break;

    //---------------------------------------------
  case INFO:
    // The info will get displayed in the overlay 
    if (overlay.timeout.isFinished()) {
      state = State.IDLE;
    }
    break;

    //---------------------------------------------
  case BOUNDS_BIG: 
    spinSpeed = SPIN_SPEED_MAX;
    spinAngle += spinSpeed;
    bounds_big.renderFrontOnly(g);
    break; 
    //---------------------------------------------
  case BOUNDS_SMALL:
    spinSpeed = SPIN_SPEED_MAX;
    spinAngle += spinSpeed;
    bounds_small.renderFrontOnly(g);
    break;
  }
}

//===================================================
// DEBUG 
void drawMask(float[][] mask, float xx, float yy) {
  pushMatrix();
  translate(xx, yy);

  for (int i=0; i < mask.length; i++) {
    for (int j=0; j < mask[0].length; j++) {
      float x = map(i, 0, 50, 0, 50*5); 
      float y= map(j, 0, 50, 0, 50*5);      
      fill(mask[j][i]*255);
      stroke(128);
      rect(x, y, 5, 5);
    }
  }

  popMatrix();
}


//===================================================
void setArea(String a) {
  AREA = a;  
  changeToInfoState();
  updateConfigFile();
}


//===================================================
void heartbeat() {
  while (true) {
    try {
      String url = "http://osc.rtanewmedia.ca/terminal-status/heartbeat/" + AREA + "/" + wIP;
      loadStrings(url);
      Thread.sleep(60*1000*15);
    }
    catch(Exception e) {
      println(e);
    }
  }
}

//===================================================
void changeToInfoState() {
  checkIPs(); 
  state = State.INFO;
  String m = areaFullNames.get(AREA) + "\n" +
            "WLAN: " + wIP + "\n" + 
            "ETH: " + eIP + "\n" + 
            "PUBLIC: " + pIP; 
  overlay.setMessage(m);
}

//===================================================
void updateConfigFile() {
  configFile.setProperty("AREA", AREA);
  configFile.setProperty("OVERLAY_X", ""+overlayX);
  configFile.setProperty("OVERLAY_Y", ""+overlayY);
  try {
    String dp = dataPath("config.properties");
    FileOutputStream f = new FileOutputStream(dp);
    configFile.store(f, null);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}