import processing.serial.*;

Serial myPort;  // Create object from Serial class

boolean serial_connect = false;

//••••••••••••••••••••••••••••••••••••

void serialInit() {

  if (ARDUINO_CONNECTED) {

    printArray(Serial.list());
    if (Serial.list().length > 0) {
      try {
        String portName = Serial.list()[2];
        myPort = new Serial(this, portName, 9600);
        serial_connect = true;
      }
      catch(Exception e) {
        myPort = null;
      }

      if (myPort == null) {
        serial_connect = false;
      } else {
        closeServo();
      }
    }
  }
}

//••••••••••••••••••••••••••••••••••••

void openServo() {
  myPort.write("a\n");
}

//••••••••••••••••••••••••••••••••••••

void closeServo() {
  myPort.write("c\n");
}
