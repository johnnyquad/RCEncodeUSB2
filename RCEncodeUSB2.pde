// usbjoystick_test
// This sketch demonstrates simple use of the USBJoystick library
// It intialises the library, establishes callbacks for when inputs change
// and prints out details whenever an input changes and a callback is called.
//
// USB Host Shield uses an interrupt line, but does not establish an interrupt callback
// Note special requirements in documentation if you are using an older version of the USB Host Shield and a newer 
// version of the USB_Host_Shield library.
// Note special requirements to configure the WiShield librray to support the UDP application. 
// mikem@open.com.au

//USBHoshShield library v1 from and USBJoystick from http://www.open.com.au/mikem/arduino/USBJoystick/
//must be installed

#include <Usb.h>

#include "USBJoystick.h"

// Our singleton joystick
USBJoystick joy;



// Here we define some callbacks thgat will be called when a stick, button
// or hat switch changes. You can also have a callback called for every polled value, if you prefer.
// Alternatively, you can use the *Value() data accessory to asynchronously get the last read value
// for the sticks, buttons and hats.

// stick will be one of USBJOYSTICK_STICK_*
void stickValueDidChangeCallback(uint8_t stick, uint8_t value)
{
 /*   Serial.print("stickValueDidChangeCallback: ");
    Serial.print(stick, DEC);
    Serial.print(": ");
    Serial.print(value, DEC);
    Serial.println("");*/
}
// button will be one of USBJOYSTICK_BUTTON_*
void buttonValueDidChangeCallback(uint8_t button, uint8_t value)
{
/*    Serial.print("buttonValueDidChangeCallback: ");
    Serial.print(button, DEC);
    Serial.print(": ");
    Serial.print(value, DEC);
    Serial.println("");*/
}
// hat will be one of USBJOYSTICK_HAT_*
// value will be one of USBJOYSTICK_HAT_POS_*
void hatValueDidChangeCallback(uint8_t hat, uint8_t value)
{
/*    Serial.print("hatValueDidChangeCallback: ");
    Serial.print(hat, DEC);
    Serial.print(": ");
    Serial.print(value, DEC);
    Serial.println("");*/
}

void showbits(char a)
{
  int i  , k , mask;

  for( i =7 ; i >= 0 ; i--)
  {
     mask = 1 << i;
     k = a & mask;
     if( k == 0)
        Serial.print("0");
     else
        Serial.print("1");
  }
}

void setup()
{
  Serial.begin(115200);

  // Specify callbacks to call when inputs change
  joy.setStickValueDidChangeCallback(stickValueDidChangeCallback);
  joy.setButtonValueDidChangeCallback(buttonValueDidChangeCallback);
  joy.setHatValueDidChangeCallback(hatValueDidChangeCallback);
  joy.init();
}

void loop()
{

  joy.run();
  joystick_data data = joy.getJoyStickData();
#if 1  
  Serial.print((int) data.Roll);
  Serial.print(" ");
  Serial.print((int) data.Pitch);
  Serial.print(" ");
  Serial.print((int) data.Yaw);
  Serial.print(" ");  
  Serial.print((int) data.Throttle);
  Serial.print(" ");  
  showbits(data.Hat);
  Serial.println(" ");  
  
#endif
  delay(20);
  
}


