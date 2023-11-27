#include <DHT.h>

#define DHTPIN 10
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

class SensorData {
public:
  float temperature;
  float humidity;

  void readData() {
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();
  }
};

const int LED_TEMPERATURE_PIN = 7;
const int LED_HUMIDITY_PIN = 6;

void setup() {
  Serial.begin(9600);
  dht.begin();
  pinMode(LED_TEMPERATURE_PIN, OUTPUT);
  pinMode(LED_HUMIDITY_PIN, OUTPUT);
}

void loop() {
  delay(1000);

  SensorData sensor;
  sensor.readData();

  // Envía datos a Processing
  Serial.print("T:");
  Serial.print(sensor.temperature);
  Serial.print(",H:");
  Serial.println(sensor.humidity);

  // Espera la instrucción de Processing para controlar los LEDs
  while (Serial.available() > 0) {
    char command = Serial.read();
    if (command == 'A') {
      digitalWrite(LED_TEMPERATURE_PIN, HIGH);
    } else if (command == 'a') {
      digitalWrite(LED_TEMPERATURE_PIN, LOW);
    } else if (command == 'B') {
      digitalWrite(LED_HUMIDITY_PIN, HIGH);
    } else if (command == 'b') {
      digitalWrite(LED_HUMIDITY_PIN, LOW);
    }
  }
}
