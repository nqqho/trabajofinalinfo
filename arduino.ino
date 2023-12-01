#include <DHT.h>

#define DHTPIN 10
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

class SensorData {
private:
  float temperature;
  float humidity;
  const int LED_TEMPERATURE_PIN = 7;
  const int LED_HUMIDITY_PIN = 6;

public:
  void readData() {
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();
  }

  // Métodos get y set para la temperatura
  float getTemperature() const {
    return temperature;
  }

  void setTemperature(float newTemperature) {
    temperature = newTemperature;
  }

  // Métodos get y set para la humedad
  float getHumidity() const {
    return humidity;
  }

  void setHumidity(float newHumidity) {
    humidity = newHumidity;
  }

  // Métodos get para los pines de LED
  int getTemperatureLEDPin() const {
    return LED_TEMPERATURE_PIN;
  }

  int getHumidityLEDPin() const {
    return LED_HUMIDITY_PIN;
  }
};

SensorData sensor;  // Crear una instancia de la clase SensorData

void setup() {
  Serial.begin(9600);
  dht.begin();
}

void loop() {
  delay(1000);

  sensor.readData();

  //  uso de los métodos get
  float currentTemperature = sensor.getTemperature();
  float currentHumidity = sensor.getHumidity();
  int temperatureLEDPin = sensor.getTemperatureLEDPin();
  int humidityLEDPin = sensor.getHumidityLEDPin();

  // Envía datos a Processing
  Serial.print("T:");
  Serial.print(currentTemperature);
  Serial.print(",H:");
  Serial.println(currentHumidity);

  // uso de los pines de LED
  Serial.println("Temperature LED Pin: " + String(temperatureLEDPin));
  Serial.println("Humidity LED Pin: " + String(humidityLEDPin));

  // Espera la instrucción de Processing para controlar los LEDs
  while (Serial.available() > 0) {
    char command = Serial.read();
    if (command == 'A') {
      digitalWrite(temperatureLEDPin, HIGH);
    } else if (command == 'a') {
      digitalWrite(temperatureLEDPin, LOW);
    } else if (command == 'B') {
      digitalWrite(humidityLEDPin, HIGH);
    } else if (command == 'b') {
      digitalWrite(humidityLEDPin, LOW);
    }
  }
}
