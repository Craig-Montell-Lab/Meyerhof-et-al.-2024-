int LightPin;
int readVal;
int CurVal;
int On;
void setup() {
  // put your setup code here, to run once:
LightPin = 3;
On =0;
Serial.begin(115200);
pinMode(LightPin,OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:

    while(Serial.available()==0){
  }
  readVal=Serial.readStringUntil('\r').toInt();
  if(readVal==1&&On==0){
      digitalWrite(LightPin,HIGH);
      On = 1;
  }
  if(readVal==0&&On==1){
      digitalWrite(LightPin,LOW);
      On = 0;
  }

}
