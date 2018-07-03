// ToDo
  // GUI for starting, stopping, mode changing, each controller individual 
 
 import oscP5.*;
 import netP5.*; 
 
 import hypermedia.net.*;
 
 OscP5 oscP5;
 NetAddress myRemoteLocation;
 
 final int OSC_SEND_PORT = 7010; // set the port to send OSC out on here 

 String info = "";
 String ErrorString = "";
 boolean sensorRunning = false;
 
 PIR_Controller [] controllers = new PIR_Controller[7]; // ###--- Set to correct number of sensors
 
 UDP [] udpConnections;


 void setup() {
  size(700,450);  
  
  // ###--- WRITE IN FOR EACH CONTROLLER
     // IP ADRESS
     // PORTS (first: remote/send, second: local/listen) 
     // NR OF SENSORS CONNECTED 
  controllers[0] = new PIR_Controller("192.168.1.10", 9010, 8010, 4);
  controllers[1] = new PIR_Controller("192.168.1.11", 9011, 8011, 4);
  controllers[2] = new PIR_Controller("192.168.1.12", 9012, 8012, 4);
  controllers[3] = new PIR_Controller("192.168.1.13", 9013, 8013, 4);
  controllers[4] = new PIR_Controller("192.168.1.14", 9014, 8014, 4);
  controllers[5] = new PIR_Controller("192.168.1.15", 9015, 8015, 4);
  controllers[6] = new PIR_Controller("192.168.1.16", 9016, 8016, 4);
  
  // --- generate udpConnections array based on controllers array size and data
  udpConnections = new UDP [controllers.length];
  for (int i = 0; i < udpConnections.length; i++){
    udpConnections[i] = new UDP( this, controllers[i].receivePort);
    udpConnections[i].listen(true);
  }
  
  /* start oscP5, listening for incoming messages at port 7011 */
  oscP5 = new OscP5(this,7011);
  // create remote location for OSC
  myRemoteLocation = new NetAddress("127.0.0.1", OSC_SEND_PORT); // set ip and port to send to here
  if (!oscP5.ip().equals("192.168.1.200")){
    ErrorString = "wrong ip " + oscP5.ip();
  }
  
  
 }

 void draw()
 {
   background(0);
   for (int i = 0; i < controllers.length; i++){
     controllers[i].updateState();
     controllers[i].draw(50, 50+50*i);
   }
   if (!ErrorString.equals("")){
     fill(255, 0, 0);
     textSize(30);
     text("ERROR: " + ErrorString, 50, 410);
   }
 }

void keyPressed() {
 
 if (key == 'd'){
  for (int i = 0; i < udpConnections.length; i++){
    udpConnections[i].send("9", controllers[i].ip, controllers[i].sendPort);
  }
 }
 else if (key == 'a'){
   for (int i = 0; i < udpConnections.length; i++){
    udpConnections[i].send("8", controllers[i].ip, controllers[i].sendPort);
  }
 }
 
 else if (key == '1'){
   for (int i = 0; i < udpConnections.length; i++){
    udpConnections[i].send("1", controllers[i].ip, controllers[i].sendPort);
  }
 }
 
 else if (key == '0'){
   for (int i = 0; i < udpConnections.length; i++){
    udpConnections[i].send("0", controllers[i].ip, controllers[i].sendPort);
   }
 }
}

// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  for (int i = 0; i < controllers.length; i++){
    if (controllers[i].ip.equals(ip)){
      // LIMIT DATA ARRAY TO THE 4 SENSOR VALUES BEFORE PASSING IT ON
      controllers[i].updateValue(data);
      
      // OSC forwarding      
      for (int j = 0; j < controllers[i].sensorValues.length; j++){
        OscMessage myMessage = new OscMessage("/"+controllers[i].ip+"/"+j);
        myMessage.add(controllers[i].sensorValues[j]); // add an int to the osc message
        oscP5.send(myMessage, myRemoteLocation);
      }
    }
  }
}
 
 
 
