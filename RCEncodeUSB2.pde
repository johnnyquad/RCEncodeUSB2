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

// Sends a pulse stream on pin 2 proportional to the values of pots connected to the analog pins
//MODDED JDH

// Channel order ROLL PITCH THROTHLE YAW CH5(Aux1) CH6(Aux2) CH7(Cam1) CH8(Cam2)

#include <Usb.h>

#include "USBJoystick.h"
#include <LiquidCrystal.h>
#include "RCEncoder.h"

// Our singleton joystick
USBJoystick joy;

// LiquidCrystal(rs, enable, d4, d5, d6, d7)
LiquidCrystal lcd(9, 8, 7, 6, 5, 4);//lcd(12, 11, 7, 6, 5, 4);

#define OUTPUT_PIN 2
#define TONE_PIN 3
#define TRIM_MIN -60
#define TRIM_MAX 60
#define THROTTLELOOPTIME 100 //in mS .. 50ms, 20Hz

bool StateCH5;
bool StateCH6;
bool throttleLock;
bool beepOnce;
unsigned long currentTime; //in uS
unsigned long lastTime;
unsigned long loopTime;
unsigned long throttleTime;
int currentThrottle;


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

void showbits(char a,uint8_t l)
{
  int i  , k , mask;

  for( i =l-1 ; i >= 0 ; i--)
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
  lcd.begin(20, 4);
  encoderBegin(OUTPUT_PIN);
  Serial.begin(115200);
  pinMode(ledTest1,OUTPUT);
  
  lcd.setCursor(0,1);
  lcd.print("  Futaba PPM Buddy  ");
  lcd.setCursor(0,2);
  lcd.print("JDH 30/08/2011 V 0.1");
  lcd.setCursor(0,3);
  lcd.print("  RCEncoderUSB  ");  
  delay(300);
  lcd.clear();
  
  for(int i=22; i < 41; i++) //setup 22 ~ 40 as IP
  {
    pinMode(i,INPUT);
    digitalWrite(i, HIGH); //turn on pullup resistors
  }

  StateCH5 = 0;
  StateCH6 = 0;
  throttleLock = 0;
  beepOnce = 0;

}
  
    
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
  showbits(data.Hat,4);
  Serial.print(" ");
  Serial.print( (int)data.Hat == HatCentre);
  Serial.print( (int)data.Hat == HatN);
  Serial.print( (int)data.Hat == HatNE);
  Serial.print( (int)data.Hat == HatE);
  Serial.print( (int)data.Hat == HatSE);
  Serial.print( (int)data.Hat == HatS);
  Serial.print( (int)data.Hat == HatSW);
  Serial.print( (int)data.Hat == HatW);
  Serial.print( (int)data.Hat == HatNW);
  Serial.print(" "); 
  Serial.print( (int)data.Btn_1);
  Serial.print( (int)data.Btn_2);
  Serial.print( (int)data.Btn_3);
  Serial.print( (int)data.Btn_4);
  Serial.print( (int)data.Btn_5);
  Serial.print( (int)data.Btn_6);
  Serial.print( (int)data.Btn_7);
  Serial.print( (int)data.Btn_8);
  Serial.print( (int)data.Btn_9);
  Serial.print( (int)data.Btn_10);
  Serial.print( (int)data.Btn_11);
  Serial.println( (int)data.Btn_12);

  /*Serial.print(" IsHatWest ");
  Serial.print( (int)data.Hat == HatW);
  Serial.print(" IsBtn_5 ");
  Serial.println( (int)data.Btn_5);*/
#endif
  delay(20);
  
}



