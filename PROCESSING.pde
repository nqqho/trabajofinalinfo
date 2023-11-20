import processing.serial.*;

Serial myPort;

float temperature = 0;
float humidity = 0;

void setup() {
  size(400, 200);
  String portName = "COM6";  // Cambia esto al puerto correcto
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  println("Processing: Inicializado");
}

void draw() {
  // Limpiar el fondo en cada iteración
  background(255);  

  // Dibuja el gráfico de temperatura
  fill(255, 0, 0);
  rect(50, height - temperature, 50, temperature);

  // Dibuja el gráfico de humedad
  fill(0, 0, 255);
  rect(150, height - humidity, 50, humidity);

  // Muestra los valores
  fill(0);
  textSize(16);
  text("Temperatura: " + nf(temperature, 2, 1) + " °C", 50, height - temperature - 10);
  text("Humedad: " + nf(humidity, 2, 1) + " %", 150, height - humidity - 10);
}

void serialEvent(Serial p) {
  String val = p.readStringUntil('\n');
  if (val != null) {
    String[] pairs = splitTokens(val, ",");
    for (String pair : pairs) {
      String[] keyValue = split(pair, ':');
      if (keyValue.length == 2) {
        if (keyValue[0].equals("T")) {
          temperature = float(keyValue[1]);
        } else if (keyValue[0].equals("H")) {
          humidity = float(keyValue[1]);
        }
      }
    }
    println("Processing: Datos recibidos - Temperatura=" + temperature + ", Humedad=" + humidity);
  }
}
