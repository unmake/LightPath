import controlP5.*;

ControlP5 cp5;

void setupGUI(){
  
  cp5 = new ControlP5(this);
  
  for (int i = 10; i < 17; i++){
    cp5.addBang("start "+i)
       .setPosition(420, 35+(i-10)*50)
       .setSize(20, 20)
       ;
    cp5.addBang("stop "+i)
       .setPosition(470, 35+(i-10)*50)
       .setSize(20, 20)
       ;
    cp5.addBang("analog "+i)
       .setPosition(550, 35+(i-10)*50)
       .setSize(20, 20)
       ;
    cp5.addBang("digital "+i)
       .setPosition(600, 35+(i-10)*50)
       .setSize(20, 20)
       ;
  }
}

public void controlEvent(ControlEvent theEvent) {
  for (int i=0; i<udpConnections.length; i++) {
    if (theEvent.getController().getName().equals("start "+(i+10))) {
      println("start " +(i+10));
      udpConnections[i].send("1", controllers[i].ip, controllers[i].sendPort);
    }
    else if (theEvent.getController().getName().equals("stop "+(i+10))){
      println("stop " +(i+10));
      udpConnections[i].send("0", controllers[i].ip, controllers[i].sendPort);
    }
    else if (theEvent.getController().getName().equals("analog "+(i+10))){
      println("analog " +(i+10));
      udpConnections[i].send("8", controllers[i].ip, controllers[i].sendPort);
    }
    else if (theEvent.getController().getName().equals("digital "+(i+10))){
      println("digital " +(i+10));
      udpConnections[i].send("9", controllers[i].ip, controllers[i].sendPort);
    }
  }

}
