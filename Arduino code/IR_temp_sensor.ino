#include <Wire.h>
#include <Adafruit_MLX90614.h>

Adafruit_MLX90614 mlx = Adafruit_MLX90614();

void setup() {
  Serial.begin(9600);
  while (!Serial); // Wait for serial monitor to open
  
  Serial.println("Adafruit MLX90614 Test");

  if (!mlx.begin()) {
    Serial.println("Error connecting to MLX90614. Check wiring.");
    while (1);
  }
}

void loop() {
  // Read Object Temperature (what the sensor is pointed at)
  float objC = mlx.readObjectTempC();
  // float objF = mlx.readObjectTempF();
  
  // Read Ambient Temperature (the sensor's own temperature)
  float ambC = mlx.readAmbientTempC();
  // float ambF = mlx.readAmbientTempF();

  // Print to Serial Monitor
  // Serial.print("Ambient = "); Serial.print(ambC); Serial.print("*C\t");
  // Serial.print("Object = "); Serial.print(objC); Serial.println("*C");
  // Serial.print("Ambient = "); Serial.print(ambF); Serial.print("*F\t");
  // Serial.print("Object = "); Serial.print(objF); Serial.println("*F");
  // Serial.println();
  // delay(100); // Read every 0.1 second

  // Save live stream of temperature data to excel
  Serial.print(millis()); 
  Serial.print(","); 
  Serial.print(objC);
  Serial.print(","); 
  Serial.println(ambC); 
  delay(500); // Read every 0.5 second
}