// Processing sketch that uses pixel assets to scales and transform it into 3D space
// Sam Legros
// Testing code is bcdefg

import netP5.*;
import oscP5.*;
import deadpixel.keystone.*;
import processing.sound.*;

SoundFile eggHatch1;
SoundFile eggHatch2;
SoundFile eggHatch3;
SoundFile errorSound;


OscP5 oscNet;
int listeningPort = 9000;
int netTimerEnd;
int netTimerInterval = 250;
boolean scanTrigger = false;
int scanCounter;
String scanValue;

int stationPicker;
int stationPickerLast;

PImage[] humEgg = new PImage[7];
PImage[] innEgg = new PImage[3];
PImage[] livEgg = new PImage[3];
PImage[] sciEgg = new PImage[3];
PImage[] spaEgg = new PImage[3];
int eggPicker;
boolean eggRenderCheck = false;
Model egg;
Timer hatch;

PImage[] humBaby = new PImage[5];
PImage[] innBaby = new PImage[5];
PImage[] livBaby = new PImage[9];
PImage[] sciBaby = new PImage[9];
PImage[] spaBaby = new PImage[5];
int babyPicker;
boolean  babyRenderCheck = false;
Model baby;

PImage[] humWorm = new PImage[9];
PImage[] innWorm = new PImage[9];
PImage[] livWorm = new PImage[9];
PImage[] sciWorm = new PImage[9];
int wormPicker;
boolean  wormRenderCheck = false;
Model worm;

PImage[] humAdult = new PImage[21];
PImage[] innAdult = new PImage[9];
PImage[] sciAdult = new PImage[13];
int adultPicker;
boolean  adultRenderCheck = false;
Model adult;

PImage[] humAcc1 = new PImage[25];
PImage[] innAcc1 = new PImage[6];
PImage[] livAcc1 = new PImage[13];
PImage[] sciAcc1 = new PImage[5];
PImage[] spaAcc1 = new PImage[11];
int acc1Picker;
boolean  acc1RenderCheck = false;
Model acc1;

PImage[] innAcc2 = new PImage[17];
PImage[] livAcc2 = new PImage[11];
int acc2Picker;
boolean  acc2RenderCheck = false;
Model acc2;

Keystone ks1;
CornerPinSurface surface1;
CornerPinSurface surface2;
CornerPinSurface surface3;

PImage asset;

PGraphics left;
PGraphics middle;
PGraphics right;
int widthLonger = 1000;
int widthShorter = 750;





void setup() {
  size(1366, 1100, P3D);

  oscNet = new OscP5(this, listeningPort);
  oscNet.plug(this, "moveAlong", "/resend");

  eggHatch1 = new SoundFile(this, "HATCHING MIX 1.wav");
  eggHatch2 = new SoundFile(this, "HATCHING MIX 2.wav");
  eggHatch3 = new SoundFile(this, "HATCHING MIX 3.wav");
  errorSound = new SoundFile(this, "ERROR.wav");


  // EGG ==========================================================================================
  for (int i = 1; i < humEgg.length; i++) { 
    humEgg[i] = loadImage("01egg/hum_" + i + ".png");
  }
  for (int i = 1; i < innEgg.length; i++) { 
    innEgg[i] = loadImage("01egg/inn_" + i + ".png");
  }
  for (int i = 1; i < livEgg.length; i++) { 
    livEgg[i] = loadImage("01egg/liv_" + i + ".png");
  }
  for (int i = 1; i < sciEgg.length; i++) { 
    sciEgg[i] = loadImage("01egg/sci_" + i + ".png");
  }
  for (int i = 1; i < spaEgg.length; i++) { 
    spaEgg[i] = loadImage("01egg/spa_" + i + ".png");
  }
  // EGG ==========================================================================================

  hatch = new Timer(2000);

  // BABY ==========================================================================================
  for (int i = 1; i < humBaby.length; i++) { 
    humBaby[i] = loadImage("02baby/hum_" + i + ".png");
  }
  for (int i = 1; i < innBaby.length; i++) { 
    innBaby[i] = loadImage("02baby/inn_" + i + ".png");
  }
  for (int i = 1; i < livBaby.length; i++) { 
    livBaby[i] = loadImage("02baby/liv_" + i + ".png");
  }
  for (int i = 1; i < sciBaby.length; i++) { 
    sciBaby[i] = loadImage("02baby/sci_" + i + ".png");
  }
  for (int i = 1; i < spaBaby.length; i++) { 
    spaBaby[i] = loadImage("02baby/spa_" + i + ".png");
  }
  // BABY ==========================================================================================

  // WORM ==========================================================================================
  for (int i = 1; i < humWorm.length; i++) { 
    humWorm[i] = loadImage("03worm/hum_" + i + ".png");
  }
  for (int i = 1; i < innWorm.length; i++) { 
    innWorm[i] = loadImage("03worm/inn_" + i + ".png");
  }
  for (int i = 1; i < livWorm.length; i++) { 
    livWorm[i] = loadImage("03worm/liv_" + i + ".png");
  }
  for (int i = 1; i < sciWorm.length; i++) { 
    sciWorm[i] = loadImage("03worm/sci_" + i + ".png");
  }
  // WORM ==========================================================================================

  // ADULT ==========================================================================================
  for (int i = 1; i < humAdult.length; i++) { 
    humAdult[i] = loadImage("04adult/hum_" + i + ".png");
  }
  for (int i = 1; i < innAdult.length; i++) { 
    innAdult[i] = loadImage("04adult/inn_" + i + ".png");
  }
  for (int i = 1; i < sciAdult.length; i++) { 
    sciAdult[i] = loadImage("04adult/sci_" + i + ".png");
  }
  // ADULT ==========================================================================================

  // ACC1 ==========================================================================================
  for (int i = 1; i < humAcc1.length; i++) { 
    humAcc1[i] = loadImage("05accessory1/hum_" + i + ".png");
  }
  for (int i = 1; i < innAcc1.length; i++) { 
    livAcc1[i] = loadImage("05accessory1/inn_" + i + ".png");
  }
  for (int i = 1; i < livAcc1.length; i++) { 
    livAcc1[i] = loadImage("05accessory1/liv_" + i + ".png");
  }
  for (int i = 1; i < sciAcc1.length; i++) { 
    sciAcc1[i] = loadImage("05accessory1/sci_" + i + ".png");
  }
  for (int i = 1; i < spaAcc1.length; i++) { 
    spaAcc1[i] = loadImage("05accessory1/spa_" + i + ".png");
  }
  // ACC1 ==========================================================================================

  // ACC2 ==========================================================================================
  for (int i = 1; i < innAcc2.length; i++) { 
    innAcc2[i] = loadImage("06accessory2/inn_" + i + ".png");
  }
  for (int i = 1; i < livAcc2.length; i++) { 
    livAcc2[i] = loadImage("06accessory2/liv_" + i + ".png");
  }

  ks1 = new Keystone(this);
  surface1 = ks1.createCornerPinSurface(widthLonger, widthShorter, 20);
  left = createGraphics(widthLonger, widthShorter, P3D);

  surface2 = ks1.createCornerPinSurface(widthShorter, widthLonger, 20);
  middle = createGraphics(widthShorter, widthLonger, P3D);

  surface3 = ks1.createCornerPinSurface(widthLonger, widthShorter, 20);
  right = createGraphics(widthLonger, widthShorter, P3D);

  //egg = new Model(innEgg[1], innEgg[2]);
  //adult = new Model(innAdult[5], innAdult[6], innAdult[7], innAdult[8]);

  // ACC2 ==========================================================================================
}    // End of setup()





void draw() {

  if (scanTrigger == true) {
    scanCounter++;    // Increase scanCounter by 1
    println(scanValue);
    println(scanCounter);
    //println(incoming);

    // EGG ==========================================================================================
    if (scanCounter == 1) {    // If scanCounter is 1
      // Render Egg
      stationPicker = int(random(1, 6));
      if (stationPicker == 1) {
        eggPicker = int(random(1, 4));
        if (eggPicker == 1) {
          egg = new Model(humEgg[1], humEgg[2]);
          eggHatch1.play();
          eggRenderCheck = true;
        } else if (eggPicker == 2) {
          egg = new Model(humEgg[3], humEgg[4]);
          eggRenderCheck = true;
          eggHatch1.play();
        } else if (eggPicker == 3) {
          egg = new Model(humEgg[5], humEgg[6]);
          eggRenderCheck = true;
          eggHatch1.play();
        }
      } else if (stationPicker == 2) {
        egg = new Model(innEgg[1], innEgg[2]);
        eggRenderCheck = true;
        eggHatch2.play();
      } else if (stationPicker == 3) {
        egg = new Model(livEgg[1], livEgg[2]);
        eggRenderCheck = true;
        eggHatch2.play();
      } else if (stationPicker == 4) {
        egg = new Model(sciEgg[1], sciEgg[2]);
        eggRenderCheck = true;
        eggHatch3.play();
      } else if (stationPicker == 5) {
        egg = new Model(spaEgg[1], spaEgg[2]);
        eggRenderCheck = true;
        eggHatch3.play();
      }
      // EGG ==========================================================================================

      // BABY ==========================================================================================
      stationPicker = int(random(1, 6));
      if (stationPicker == 1) {
        baby = new Model(humBaby[1], humBaby[2], humBaby[3], humBaby[4]);
        babyRenderCheck = true;
      } else if (stationPicker == 2) {
        baby = new Model(innBaby[1], innBaby[2], innBaby[3], innBaby[4]);
        babyRenderCheck = true;
      } else if (stationPicker == 3) {
        babyPicker = int(random(1, 3));
        if (babyPicker == 1) {
          baby = new Model(livBaby[1], livBaby[2], livBaby[3], livBaby[4]);
          babyRenderCheck = true;
        } else if (babyPicker == 2) {
          baby = new Model(livBaby[5], livBaby[6], livBaby[7], livBaby[8]);
          babyRenderCheck = true;
        }
      } else if (stationPicker == 4) {
        babyPicker = int(random(1, 3));
        if (babyPicker == 1) {
          baby = new Model(sciBaby[1], sciBaby[2], sciBaby[3], sciBaby[4]);
          babyRenderCheck = true;
        } else if (babyPicker == 2) {
          baby = new Model(sciBaby[5], sciBaby[6], sciBaby[7], sciBaby[8]);
          babyRenderCheck = true;
        }
      } else if (stationPicker == 5) {
        baby = new Model(spaBaby[1], spaBaby[2], spaBaby[3], spaBaby[4]);
        babyRenderCheck = true;
      }
      // BABY ==========================================================================================

      // WORM ==========================================================================================
    } else if (scanCounter == 2) {    // If scanCounter is 2
      stationPicker = int(random(1, 5));
      if (stationPicker == 1) {
        wormPicker = int(random(1, 3));
        if (wormPicker == 1) {
          worm = new Model(humWorm[1], humWorm[2], humWorm[3], humWorm[4]);
          wormRenderCheck = true;
          errorSound.play();
        } else if (wormPicker == 2) {
          worm = new Model(humWorm[5], humWorm[6], humWorm[7], humWorm[8]);
          wormRenderCheck = true;
          errorSound.play();
        }
      } else if (stationPicker == 2) {
        wormPicker = int(random(1, 3));
        if (wormPicker == 1) {
          worm = new Model(innWorm[1], innWorm[2], innWorm[3], innWorm[4]);
          wormRenderCheck = true;
          errorSound.play();
        } else if (wormPicker == 2) {
          worm = new Model(innWorm[5], innWorm[6], innWorm[7], innWorm[8]);
          wormRenderCheck = true;
          errorSound.play();
        }
      } else if (stationPicker == 3) {
        wormPicker = int(random(1, 3));
        if (wormPicker == 1) {
          worm = new Model(livWorm[1], livWorm[2], livWorm[3], livWorm[4]);
          wormRenderCheck = true;
          errorSound.play();
        } else if (wormPicker == 2) {
          worm = new Model(livWorm[5], livWorm[6], livWorm[7], livWorm[8]);
          wormRenderCheck = true;
          errorSound.play();
        }
      } else if (stationPicker == 4) {
        wormPicker = int(random(1, 3));
        if (wormPicker == 1) {
          worm = new Model(sciWorm[1], sciWorm[2], sciWorm[3], sciWorm[4]);
          wormRenderCheck = true;
          errorSound.play();
        } else if (wormPicker == 2) {
          worm = new Model(sciWorm[5], sciWorm[6], sciWorm[7], sciWorm[8]);
          wormRenderCheck = true;
          errorSound.play();
        }
      }
      // WORM ==========================================================================================

      // ADULT ==========================================================================================
    } else if (scanCounter == 3) {    // If scanCounter is 3
      stationPicker = 3;
      //stationPicker = int(random(1, 4));
      if (stationPicker == 1) {
        adultPicker = int(random(1, 6));
        if (adultPicker == 1) {
          adult = new Model(humAdult[1], humAdult[2], humAdult[3], humAdult[4]);
          adultRenderCheck = true;
        } else if (adultPicker == 2) {
          adult = new Model(humAdult[5], humAdult[6], humAdult[7], humAdult[8]);
          adultRenderCheck = true;
        } else if (adultPicker == 3) {
          adult = new Model(humAdult[9], humAdult[10], humAdult[11], humAdult[12]);
          adultRenderCheck = true;
        } else if (adultPicker == 4) {
          adult = new Model(humAdult[13], humAdult[14], humAdult[15], humAdult[16]);
          adultRenderCheck = true;
        } else if (adultPicker == 5) {
          adult = new Model(humAdult[17], humAdult[18], humAdult[19], humAdult[20]);
          adultRenderCheck = true;
        }
      } else if (stationPicker == 2) {
        adultPicker = int(random(1, 3));
        if (adultPicker == 1) {
          adult = new Model(innAdult[1], innAdult[2], innAdult[3], innAdult[4]);
          adultRenderCheck = true;
        } else if (adultPicker == 2) {
          adult = new Model(innAdult[5], innAdult[6], innAdult[7], innAdult[8]);
          adultRenderCheck = true;
        }
      } else if (stationPicker == 3) {
        adultPicker = int(random(1, 4));
        if (adultPicker == 1) {
          adult = new Model(sciAdult[1], sciAdult[2], sciAdult[3], sciAdult[4]);
          adultRenderCheck = true;
        } else if (adultPicker == 2) {
          adult = new Model(sciAdult[5], sciAdult[6], sciAdult[7], sciAdult[8]);
          adultRenderCheck = true;
        } else if (adultPicker == 3) {
          adult = new Model(sciAdult[9], sciAdult[10], sciAdult[11], sciAdult[12]);
          adultRenderCheck = true;
        }
      }
      // ADULT ==========================================================================================

      // ACC1 ==========================================================================================
    } else if (scanCounter == 4) {
      stationPicker = int(random(1, 6));
      if (stationPicker == 1) {
        acc1Picker = int(random(1, 5));
        if (acc1Picker == 1) {
          acc1 = new Model(humAcc1[1], humAcc1[2]);
          acc1RenderCheck = true;
        } else if (acc1Picker == 2) {
          acc1 = new Model(humAcc1[5], humAcc1[6]);
          acc1RenderCheck = true;
        } else if (acc1Picker == 3) {
          acc1 = new Model(humAcc1[19], humAcc1[20]);
          acc1RenderCheck = true;
        } else if (acc1Picker == 4) {
          acc1 = new Model(humAcc1[23], humAcc1[24]);
          acc1RenderCheck = true;
        }
      } else if (stationPicker == 2) {
        acc1 = new Model(livAcc1[7], livAcc1[8]);
        acc1RenderCheck = true;
      } else if (stationPicker == 3) {
        acc1 = new Model(sciAcc1[3], sciAcc1[4]);
        acc1RenderCheck = true;
      } else if (stationPicker == 4) {
        acc1 = new Model(spaAcc1[7], spaAcc1[8]);
        acc1RenderCheck = true;
      }
      // Render Adult with Body Accessory
      println("Render Adult with Body Accessory");
      // ACC1 ==========================================================================================

      // ACC2 ==========================================================================================
    } else if (scanCounter == 5) {
      stationPicker = int(random(1, 3));
      if (stationPicker == 1) {
        acc2 = new Model(innAcc2[7], innAcc2[8]);
        acc2RenderCheck = true;
      } else if (stationPicker == 2) {
        acc2Picker = int(random(1, 3));
        if (acc2Picker == 1) {
          acc2 = new Model(livAcc2[5], livAcc2[6]);
          acc2RenderCheck = true;
        } else if (acc2Picker == 2) {
          acc2 = new Model(livAcc2[7], livAcc2[8]);
          acc2RenderCheck = true;
        }
      }
    }
    // ACC2 ==========================================================================================
    scanTrigger = false;
  }    // End of if statement

  // Left
  left.beginDraw();  
  //left.translate(width/2, height/2);    // translate (0, 0) to center of window
  //left.rotateY(frameCount/100.0);    // rotate object on Y axis
  left.translate(left.width/2, left.height/2);
  left.rotateZ(radians(270));
  left.rotateY(frameCount/100.0);
  renderScene(left);
  left.endDraw();

  // right
  right.beginDraw();  
  right.translate(right.width/2, right.height/2);
  right.rotateZ(radians(90));
  right.rotateY(frameCount/100.0);
  renderScene(right);
  right.endDraw();

  // middle 
  middle.beginDraw();  
  middle.translate(middle.width/2, middle.height/2);
  middle.rotateY(radians(90));
  middle.rotateY(frameCount/100.0);
  renderScene(middle);
  middle.endDraw();

  // draw using the surface objects

  background(0);
  surface1.render(left);
  surface2.render(middle);
  surface3.render(right);
}    // End of draw()





void renderScene(PGraphics g) { 
  background(0);    // Set background of each window
  lights();    // Lights creates shadowing effect
  //egg.render(g);
  //adult.render(g);
  if (eggRenderCheck == true) {
    egg.render(g);
  }

  if (babyRenderCheck == true) {
    hatch.start();
    if (hatch.isFinished() == true) {
      eggRenderCheck = false;
      baby.render(g);
    }
  }

  if (wormRenderCheck == true) {
    eggRenderCheck = false;
    babyRenderCheck = false;
    worm.render(g);
  }

  if (adultRenderCheck == true) {
    eggRenderCheck = false;
    babyRenderCheck = false;
    wormRenderCheck = false;
    adult.render(g);
  }

  if (acc1RenderCheck == true) {
    eggRenderCheck = false;
    babyRenderCheck = false;
    wormRenderCheck = false;
    acc1.render(g);
  }

  if (acc2RenderCheck == true) {
    eggRenderCheck = false;
    babyRenderCheck = false;
    wormRenderCheck = false;
    acc2.render(g);
  }
}





void oscEvent(OscMessage incoming) {
  scanValue = incoming.addrPattern();
  //println(scanValue);
  scanTrigger = true;
}    // End of oscEvent





void keyPressed() {
  switch(key) {
  case '0':
    scanCounter = 0;
    println(scanCounter);
    eggRenderCheck = false;
    babyRenderCheck = false;
    wormRenderCheck = false;
    adultRenderCheck = false;
    acc1RenderCheck = false;
    acc2RenderCheck = false;
    break;

  case 'c':    // Enter/leave calibration mode, where surfaces can be warped and moved
    ks1.toggleCalibration();
    break;

  case 'l':    // Loads the saved layout
    ks1.load();
    break;

  case 's':    // Saves the layout
    ks1.save();
    break;
  }    // End of switch
}    // End of keyPressed()