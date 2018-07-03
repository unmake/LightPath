class PIR_Controller{
  
  String ip;
  int sendPort, receivePort;
  int sensorValues [];
  long timeOfLastData;
  boolean state;
  
  int x, y;
  
  PIR_Controller(String ip, int sendPort, int receivePort, int nrOfSensors){
    this.ip = ip;
    this.sendPort = sendPort;
    this.receivePort = receivePort;
    sensorValues = new int[nrOfSensors];
  }
  
  void updateValue(byte sensorReadings []){
    if (sensorReadings.length != 4) {
      println("RECEIVED SENSOR DATA ARRAY LENGHT NOT EQUAL 4 BUT " + sensorReadings.length);
      return; // stop process if array is not the correct length
    }
    for (int i = 0; i < sensorValues.length; i++){
      sensorValues[i] = sensorReadings[i];  
    }
    
    //sensorValues[0] = val;
    timeOfLastData = millis();
    state = true;
  }
  
  void updateState(){
    if (millis() > timeOfLastData + 5000){
      state = false;
      for (int i = 0; i < sensorValues.length; i++){
        sensorValues[i] = 0;  
      }
    }
  }
  
  void draw(int x, int y){
    textSize(16);
    fill(255);
    text(ip, x, y);
    for (int i = 0; i < sensorValues.length; i++){
      text(sensorValues[i], x+150+i*30, y);
      
    }
    fill(255, 0, 0);
    if (state) fill(0, 255, 0);
    rect(x+300, y-9, 10, 10);
  }
}
