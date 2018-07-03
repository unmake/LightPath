/* 
 NB: remember to set remote IP before starting.
 
 ToDo
 move cap thres to top
 implement dataArray in CapSense or remove CapSense from the code

 UDP PROTOCOL:
 0 = stop sending
 1 = start sending
 2 = send info
 3 = increment delayTime
 8 = analog sensor on pin A0, A1, A2, A3
 9 = digital sensors on pins 3, 5, 6, 7 with internal pull up activated
 */


#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <EthernetUdp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

#include <CapacitiveSensor.h>

// ENTER IP, PORT, MAC INFO HERE:
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xFA};
IPAddress ip(192, 168, 1, 16);           // Arduino IP: first 3 numbers must be the same as ipRemote
IPAddress ipRemote(192, 168, 1, 200);     // remote IP: remote address to comminicate with
unsigned int LOCAL_PORT = 9016;              // local port to listen on
unsigned int REMOTE_PORT = 8016;              // local port to listen on

char packetBuffer[UDP_TX_PACKET_MAX_SIZE];  // buffer to hold incoming packet,
EthernetUDP Udp;                            // An EthernetUDP instance to let us send and receive packets over UDP


boolean sendSensorData = false;

CapacitiveSensor   cs_4_2 = CapacitiveSensor(4,2); // Resistor between pin 2 - 4, pin 2 is sensor pin
int pullUpSensorPins [] = {3, 5, 6, 7}; // DIGITAL SENSOR PINS WITH PULL-UP
int analogSensorPins []  = {A0, A1, A2, A3}; // ANALOG SENSOR PINS

unsigned char dataArray [sizeof(pullUpSensorPins)];

int delayTime = 100;
int activeSensor = 1;
int delayMin = 10;
int delayIncrement = 10;
int delayMax = 255; // max 255 because only bytes is being sent

long timer = 0; // timer variable



void setup() {
  Serial.begin(9600);
  // start the Ethernet and UDP:
  Ethernet.begin(mac, ip);
  Udp.begin(LOCAL_PORT);
  
  // DIGITAL PINS SETUP
  for (int i = 0; i < sizeof(pullUpSensorPins); i++){
    pinMode(pullUpSensorPins[i], INPUT); // DIGITAL SENSOR WITH INTERNAL PULL-UP
    digitalWrite(pullUpSensorPins[i], HIGH); // pull-up  
  }

  // ANALOG PINS SETUP
  for (int i = 0; i < sizeof(analogSensorPins); i++){
    pinMode(analogSensorPins[i], INPUT); // // DIGITAL SENSOR WITH INTERNAL PULL-UP
  }
  
  Serial.println("I'm alive");
}

void loop() {
  
  int packetSize = Udp.parsePacket();
  if (packetSize) {
    udpReceiveHandler();
  }
  udpSendHandler();
}


unsigned char getSensorData(){
  
  if (activeSensor == 0){ // BUTTON
    for (int i = 0; i < sizeof(pullUpSensorPins); i++){
      dataArray[i] = digitalRead(pullUpSensorPins[i]);
    }
    return; // return without value because the values are saved in the dataArray array.
  }
  else if (activeSensor == 1){
    for (int i = 0; i < sizeof(analogSensorPins); i++){
      dataArray[i] = (int)map(analogRead(analogSensorPins[i]), 0, 1023, 0, 255);
    }
    return; // return without value because the values are saved in the dataArray array.
  }
  else if (activeSensor == 2){
    long total =  cs_4_2.capacitiveSensor(30);
    
    unsigned char data = (int)map(total, 0, 50000, 0, 255);
    Serial.println(data);
    return data;
  }
  else Serial.println("no sensor activated");
}


void udpReceiveHandler(){
  // read the packet into packetBufffer
    Udp.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);
    int d = (packetBuffer[0]-48); // "d" stores UDP data converted to int 
    
    // --- activate sensor data ---
    if (d == 0) { // --- stop sending data ---
      sendSensorData = false;
    }
    else if (d == 1) { // --- start sending data ---
      sendSensorData = true;
    }
    else if (d == 2) { // --- update ip ---
      udpSendInfo();
    }
    else if (d == 3){
      delayTime += delayIncrement;
      if (delayTime > delayMax) delayTime = delayMin;
      udpSendInfo();
    }
    else if (d == 7){ // --- activate sensor 2 (CapSense) --- ROOM FOR MORE SENSORS i 4-6
      activeSensor = 2;
    }
    else if (d == 8){ // --- activate sensor 1 (analog) --- 
      activeSensor = 1;
    }
    else if (d == 9){ // --- activate sensor 0 (pullUp digital) ---
      activeSensor = 0;
    }
}

void udpSendHandler(){
  
  // --- SEND SENSOR DATA ---
  if (sendSensorData){
    if(millis()-timer > delayTime) {
          // do something two seconds later
          timer=millis();
          getSensorData();
          //Udp.beginPacket("192.168.1.200", 8012);
          Udp.beginPacket(Udp.remoteIP(), REMOTE_PORT);
          Udp.write(dataArray[0]);
          Udp.write(dataArray[1]);
          Udp.write(dataArray[2]);
          Udp.write(dataArray[3]);
          Udp.endPacket();
    }
  }
}

void udpSendInfo(){
  //Udp.beginPacket("192.168.1.200", 8012);
  Udp.beginPacket(Udp.remoteIP(), REMOTE_PORT);
  Udp.write(Udp.remoteIP()[0]);
  Udp.write(Udp.remoteIP()[1]);
  Udp.write(Udp.remoteIP()[2]);
  Udp.write(Udp.remoteIP()[3]);
  Udp.write(ip[0]);
  Udp.write(ip[1]);
  Udp.write(ip[2]);
  Udp.write(ip[3]);
  Udp.write(activeSensor);
  Udp.write(delayTime);
  Udp.endPacket(); 
}
