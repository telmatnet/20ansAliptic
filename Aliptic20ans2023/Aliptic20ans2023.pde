/**
 * Why Whomen Code 2022.
 * 
 * 
 */

import processing.video.*;
import processing.sound.*;

PImage img;
Capture cam;
SoundFile soundfile;
Timer timer; 
PImage photo;

void setup() {
  size(948, 948);
  frameRate(10);
  
  img = loadImage("data/elle.png");
  soundfile = new SoundFile(this, "data/camera.mp3");
  

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 1024, 720);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    cam = new Capture(this, cameras[1]);
    cam.start();
  }
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, -38, 20, 1024-38, 720+20);

  image(img, 0, 0);
  
  if ( timer != null ) {
    if (timer.isFinished()){ 
      shootPhoto();
    }
  }
}

void keyPressed() {
  if ( key == ENTER || key == ' ') {
    startPhoto();
  }
  if (key == 'a') {
    //shootPhoto();
  }
}

void startPhoto() {
  delay(100);
  soundfile.play();
  timer = new Timer(3000);
  timer.start();
}

void shootPhoto() {
  timer = null;
  saveFrame("photo.png");
  saveFrame("photos/photomaton-######.png");
  
  // V1
  
  PImage photo_crop = loadImage("photo.png");
  photo_crop.resize(630, 630);
  //photo_crop.filter(THRESHOLD, 0.5);
  
  int s = 1;
  for (int x = 0; x < photo_crop.width; x+=s) {
    for (int y = 0; y < photo_crop.height; y+=s) {
      color oldpixel = photo_crop.get(x, y);
      
      color newpixel = findClosestColor(oldpixel);
      //newpixel = color(brightness(newpixel));
      
      float quant_error = brightness(oldpixel) - brightness(newpixel);
      photo_crop.set(x, y, newpixel);
  
        photo_crop.set(x+s, y, color(brightness(photo_crop.get(x+s, y)) + 7.0/16 * quant_error) );
        photo_crop.set(x-s, y+s, color(brightness(photo_crop.get(x-s, y+s)) + 3.0/16 * quant_error) );
        photo_crop.set(x, y+s, color(brightness(photo_crop.get(x, y+s)) + 5.0/16 * quant_error) );
        photo_crop.set(x+s, y+s, color(brightness(photo_crop.get(x+s, y+s)) + 1.0/16 * quant_error));
        
        stroke(newpixel); 
        point(x,y);
        
      
    }
  }
  photo_crop.filter(THRESHOLD, 0.5);
  photo_crop.save("photo_crop.png");
  //printImage("photo_crop.png");
  
  // V2
  //printImage("photo.png");
}

void printImage(String file) {  
  //String command = "/Users/telmat/Desktop/GettingStartedCapture/test.png -d Brother_HL_L5200DW_series-2241 -o media=a6 -o fit-to-page";
  String command = "/Users/telmatnet/Desktop/20ans-relax/Aliptic20ans2023/"+file;
  Process p = exec("lp", command, 
  "-o", "orientation-requested=6", 
  "-o", "media=Custom.70x70mm");
  
  try {
    int result = p.waitFor();
    println("the process returned " + result);
  } 
  catch (InterruptedException e) {
    println("error : " + e);
  }
}

color findClosestColor(color c) {
  color r;

  if (brightness(c) < 128) {
    r = color(0);
  }
  else {
    r = color(255);
  }
  return r;
}

class Timer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  void setTime(int t) {
    totalTime = t;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
