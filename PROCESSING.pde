import processing.serial.*;

Serial myPort;

float temperature = 0;
float humidity = 0;

float sumTemperature = 0;
float sumHumidity = 0;
int numSamples = 0;

float averageTemperature = 0;
float averageHumidity = 0;

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
  rect(50, height - averageTemperature, 50, averageTemperature);

  // Dibuja el gráfico de humedad
  fill(0, 0, 255);
  rect(150, height - averageHumidity, 50, averageHumidity);

  // Muestra los valores
  fill(0);
  textSize(16);
  text("T: " + nf(averageTemperature, 2, 1) + " °C", 50, height - averageTemperature - 10);
  text("H: " + nf(averageHumidity, 2, 1) + " %", 150, height - averageHumidity - 10);
}

void serialEvent(Serial p) {
  String val = p.readStringUntil('\n');
  if (val != null) {
    String[] pairs = splitTokens(val, ",");
    for (String pair : pairs) {
      String[] keyValue = split(pair, ':');
      if (keyValue.length == 2) {
        if (keyValue[0].equals("T")) {
          sumTemperature += float(keyValue[1]);
          numSamples++;
        } else if (keyValue[0].equals("H")) {
          sumHumidity += float(keyValue[1]);
        }
      }
    }

    // Calcular promedios
    if (numSamples > 0) {
      averageTemperature = sumTemperature / numSamples;
      averageHumidity = sumHumidity / numSamples;
    }

    println("Processing: Datos recibidos - Temperatura=" + averageTemperature + ", Humedad=" + averageHumidity);

    // Guardar en archivo
    saveAveragesToFile();
  }
}

void saveAveragesToFile() {
  // Guardar promedios en un archivo
  String[] lines = {nf(averageTemperature, 2, 1) + "," + nf(averageHumidity, 2, 1)};
  saveStrings("promedios.txt", lines);
}
