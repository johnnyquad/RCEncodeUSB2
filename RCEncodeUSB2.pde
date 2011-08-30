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
LiquidCrystal lcd(22, 23, 24, 25, 26, 27);//lcd(12, 11, 7, 6, 5, 4);

#define OUTPUT_PIN 2
#define TONE_PIN 3
#define TRIM_MIN -60
#define TRIM_MAX 60
#define THROTTLELOOPTIME 100 //in mS .. 50ms, 20Hz

#define printTimes
//#define printTrims


bool StateCH5;
int StateCH6;
bool throttleLock;
bool beepOnce;
unsigned long currentTime; //in uS
unsigned long lastTime;
unsigned long loopTime;
unsigned long throttleTime;
int currentThrottle;
int tiltTrim;
int  camTilt;



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

void checkPulseWidth(int pulseWidth)
      {
        if (pulseWidth > MAX_PULSE_WIDTH)
        {
          pulseWidth = MAX_PULSE_WIDTH;
        }
      if (pulseWidth < MIN_PULSE_WIDTH)
        {
          pulseWidth = MIN_PULSE_WIDTH;
        }
        return (pulseWidth);
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
  
/*  for(int i=22; i < 41; i++) //setup 22 ~ 40 as IP
  {
    pinMode(i,INPUT);
    digitalWrite(i, HIGH); //turn on pullup resistors
  }*/

  StateCH5 = 0;
  StateCH6 = 0;
  throttleLock = 0;
  beepOnce = 0;
  camTilt = 1500;
  tiltTrim = 2;

  
    
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

      currentTime = millis();
      int trim1 = analogRead(0); //read trim pots ROLL
      trim1= map(trim1, 0,1023,TRIM_MIN,TRIM_MAX);
      int trim2 = analogRead(1); //PITCH
      trim2= map(trim2, 0,1023,TRIM_MIN,TRIM_MAX);
      int trim3 = analogRead(2); //THROTTLE
      trim3= map(trim3, 0,1023,1,20);// now used for throttle step TRIM_MIN,TRIM_MAX);
      int trim4 = analogRead(3); //YAW
      trim4= map(trim4, 0,1023,TRIM_MIN,TRIM_MAX);
      
      #if defined (printTrims)
      {
        Serial.print(trim1);
        Serial.print(" ");
        Serial.print(trim2);
        Serial.print(" ");
        Serial.print(trim3);
        Serial.print(" ");
        Serial.print(trim4);
        Serial.print(" ");
      }
      #endif
  
// Channel order for TX = ROLL(0) PITCH(1) THROTHLE(2) YAW(3) CH5(Aux1) CH6(Aux2) CH7(Cam1) CH8(Cam2)

// Channel order from USB Joystick = ROLL(10bits) PITCH(10bits) YAW(8bits) THROTHLE(8bits)  Hat(4bits) Buttons(13bits)
  
//Roll
      int pulseWidth = map(data.Roll, 0,1023, 1000, 2000);
      pulseWidth = pulseWidth + trim1;
      checkPulseWidth(pulseWidth);
      encoderWrite(0, pulseWidth);
      lcd.setCursor(0,1);
      lcd.print("    ");
      lcd.setCursor(0,1);
      lcd.print(pulseWidth);
      lcd.setCursor(0,2);
      lcd.print("    ");
      if (trim1 >= 0)
      {
        lcd.setCursor(1,2);
        lcd.print(int(trim1));
      }else
      {
        lcd.setCursor(0,2);
        lcd.print(int(trim1));
      }
      #if defined (printTimes)
        {
          Serial.print(pulseWidth);
          Serial.print(" ");
        }
      #endif  
      

//Pitch
      pulseWidth = map((1023-data.Pitch), 0,1023, 1000, 2000);
      pulseWidth = pulseWidth + trim2;
      encoderWrite(1, pulseWidth);
      lcd.setCursor(5,1);
      lcd.print("    ");
      lcd.setCursor(5,1);
      lcd.print(pulseWidth);
      lcd.setCursor(5,2);
      lcd.print("    ");
      if (trim2 >= 0)
      {
        lcd.setCursor(6,2);
        lcd.print(int(trim2));
      }else
      {
        lcd.setCursor(5,2);
        lcd.print(int(trim2));
      }
      
      #if defined (printTimes)
        {
          Serial.print(pulseWidth);
          Serial.print(" ");
        }
      #endif

//THROTTLE
      pulseWidth = map((255-data.Throttle), 0,255, 1000, 2000);
      if(throttleLock == 0)// no locking just use stick input
        {
          //pulseWidth = pulseWidth ;//+ trim3;
          currentThrottle = pulseWidth;
          encoderWrite(2, pulseWidth);
          lcd.setCursor(10,1);
          lcd.print("    ");
          lcd.setCursor(10,1);
          lcd.print(pulseWidth);
          lcd.setCursor(10,2);
          lcd.print("    ");
          if (trim3 >= 0)
            {
              lcd.setCursor(11,2);
              lcd.print(int(trim3));
            }else
            {
              lcd.setCursor(10,2);
              lcd.print(int(trim3));
            }
          
          #if defined (printTimes)
          {
            Serial.print(pulseWidth);
            Serial.print(" ");
          }
        #endif
          
        }
      
      if(throttleLock == 1) //lock throttle and use trigger & thumb button to inc/dec throttle
      {

      if (currentTime > throttleTime) // do throt inc/dec
      {
        if (data.Btn_1 == 1)//
        {
          currentThrottle = currentThrottle + trim3;
          if (currentThrottle > MAX_CHANNEL_PULSE)
          {
            currentThrottle = MAX_CHANNEL_PULSE;
          }          
          tone(TONE_PIN,2090,1);//2038 res
        }
        if (data.Btn_2 == 1)//
        {
          currentThrottle = currentThrottle - trim3;
          if (currentThrottle < MIN_CHANNEL_PULSE)
          {
            currentThrottle = MIN_CHANNEL_PULSE;
          }
          tone(TONE_PIN,2000,1);
        }
          
        throttleTime = currentTime + THROTTLELOOPTIME;
      }
      

        lcd.setCursor(10,1);
        lcd.print("    ");
        lcd.setCursor(10,1);
        lcd.print(currentThrottle);
        lcd.setCursor(10,2);
        lcd.print("    ");
        if (trim3 >= 0)
        {
          lcd.setCursor(11,2);
          lcd.print(int(trim3));
        }else
        {
          lcd.setCursor(10,2);
          lcd.print(int(trim3));
        }
      encoderWrite(2,currentThrottle); 
          #if defined (printTimes)
            {
              Serial.print(currentThrottle);
              Serial.print(" ");
            }
          #endif  
      } 

//Yaw
      pulseWidth = map(data.Yaw, 0,255, 1000, 2000);
      pulseWidth = pulseWidth + trim4;
      encoderWrite(3, pulseWidth);
      lcd.setCursor(15,1);
      lcd.print("    ");
      lcd.setCursor(15,1);
      lcd.print(pulseWidth);
      lcd.setCursor(15,2);
      lcd.print("    ");
      if (trim4 >= 0)
      {
        lcd.setCursor(16,2);
        lcd.print(int(trim4));
      }else
      {
        lcd.setCursor(15,2);
        lcd.print(int(trim4));
      }
      #if defined (printTimes)
        {
          Serial.print(pulseWidth);
          Serial.print(" TL=");
          Serial.print(throttleLock);
          Serial.print(" CH5=");
          Serial.print(StateCH5);
          Serial.print(" CH6=");
          Serial.print(StateCH6);          
          Serial.print(" CH7=");
                    

        }
      #endif

  
//Channel 5 stuff .... Arming & Disarming
  if (data.Throttle > 242) //Make sure throttle stick is near minimum and only arm if
    {
      if ((data.Btn_5 == 1) && (data.Btn_6 == 1) && (currentThrottle < 1040)) // All buttons on top of JS are pressed
        if (data.Btn_1 == 1) // and button 1 is pressed
          {
            StateCH5 = true; //Arm Motors
            throttleLock = 0; //turn off throttle lock if it was enabled
            currentThrottle = 1000; // ensure min throttle
          }
    }
 
   if (data.Throttle > 242) //Make sure throttle stick & currentThrottle is near minimum and disarm only if
    {
      if ((data.Btn_5 == 1) && (data.Btn_6 == 1) && (currentThrottle < 1040)) // All buttons on top of JS are pressed
        if (data.Btn_2 == 1) // and button 2 is pressed
          {
            StateCH5 = false; //Disarm Motors
            throttleLock = 0; //turn off throttle lock if it was enabled
          }
    }
    
 //Throttle Lock
  if (data.Btn_11 == 1) //
  {
     throttleLock = 0;
  }  
  
  if ((data.Btn_12 == 1) && (StateCH5 == true)) // Only allow throttle lock if motors are armed
  {
    throttleLock = 1;
  }  
  lcd.setCursor(4,3);
  lcd.print(throttleLock);
 loopTime = millis() - currentTime;    
  
  if (StateCH5 == true)
  {
    encoderWrite(4, 2000);
  }else
  {
    encoderWrite(4, 1000);
  }
  
  lcd.setCursor(0,0); 
  lcd.print("ROLL PITH THROT YAW ");
  
  lcd.setCursor(0,3);
  lcd.print(StateCH5);


   
//Channel 6 stuff  Arcro/Stable/MagHold
  if ((data.Btn_6!=1) && (data.Btn_5!=1)) //
  {
      if (data.Btn_5 ==1)
      {
        StateCH6 = 0;
      }
      if (data.Btn_3==1) //
      {
        StateCH6 = 1;
      }
      if (data.Btn_4==1) //
      {
        StateCH6 = 2;
      }
  }
  if (StateCH6 == 0)
  {
    encoderWrite(5, 1000);
  }
  if (StateCH6 == 1)
  {
    encoderWrite(5, 1500);
  }
  if (StateCH6 == 2)
  {
    encoderWrite(5, 2000);
  }
  lcd.setCursor(2,3);
  lcd.print(StateCH6);  
  

//Channel 7 stuff camera pan  control
       if (data.Hat == HatN)
        {
          camTilt = camTilt + tiltTrim ;
          if (camTilt > MAX_CHANNEL_PULSE)
            {
              camTilt = MAX_CHANNEL_PULSE;
            }
        }
        if (data.Hat == HatS)
        {
          camTilt = camTilt - tiltTrim ;
          if (camTilt < MIN_CHANNEL_PULSE)
            {
              camTilt = MIN_CHANNEL_PULSE;
            }
        }
      
      encoderWrite(6, camTilt);
      Serial.println(camTilt);
      
      
 
//Channel 8 stuff 
   encoderWrite(7, 1500);
//Serial.println(loopTime); 
 
//  lcd.print(ch6a);
//  lcd.print(" ");
//  lcd.print(ch6b);
//  lcd.print(" ");
//  lcd.print(ch6c);
//  lcd.print(" ");  


/*  Serial.print(ch6a);
  Serial.print(" ");
  Serial.print(ch6b);
  Serial.print(" ");
  Serial.print(ch6c);
  Serial.print(" ");
  Serial.println(StateCH6);
*/  
    
  
  
#if 0
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



