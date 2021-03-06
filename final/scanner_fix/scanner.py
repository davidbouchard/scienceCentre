#!/user/bin/python

import SimpleCV
import OSC
import datetime
import time 
from SimpleCV import Color,Camera,Display
import argparse
import RPi.GPIO as GPIO
import os

# connected as a sink, so High -> OFF
ledPin = 7

timer = time.time() 
delay = 1

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", type=str, default="127.0.0.1")
    parser.add_argument("--port", type=int, default=9000)
    parser.add_argument("--display", action="store_true")

    args = parser.parse_args()
    print args
    send_address = args.ip
    send_port = args.port

    if args.display:
        display = Display((640, 480))        

    # setup the GPIO pins
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(7, GPIO.OUT)
    GPIO.output(ledPin, True)

    # start OSC
    osc = OSC.OSCClient()
    osc.connect((send_address, send_port))
    print "Sending OSC to", send_address, "port:", send_port

    cam = Camera()  #starts the camera
    
    prevScan = None
    while(1):
        img = cam.getImage() #gets image from the camera
        if args.display:
            img.save(display)
            display.isNotDone()
        barcode = img.findBarcode() #finds barcode data from image
        if barcode:
            barcode = barcode[0] 
            result = str(barcode.data)
            accountID = result[-4:]
            
            # reset the 2 second delay timer 
            timer = time.time() 
            
            # special command to shutdown the pi 
            if accountID == "0000":
            	os.system("sudo shutdown now -h")

            if accountID == "0001":
                os.system("sudo reboot now")
            
            if prevScan != accountID:
               prevScan = accountID
               print datetime.datetime.now(), "scanned:", accountID
               # turn ON led
               GPIO.output(ledPin, False)


               # send OSC message
               msg = OSC.OSCMessage()
               msg.setAddress("/scan")      #add the account number to the msg
               msg.append(accountID)
               try:
                   osc.send(msg)
               except Exception as e:
                   print e
        else:
            # wait before shutting down 
            if time.time() > timer+delay:
                prevScan = None
                # turn OFF led
                GPIO.output(ledPin, True)

