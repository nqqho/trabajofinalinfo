import processing.serial.*;
import java.util.Date;
import java.text.SimpleDateFormat;

Serial myPort;
float temperature = 0;
float humidity = 0;
float sumTemperature = 0;
float sumHumidity = 0;
int count = 0;

void setup() {
  size(400, 200);
  String portName = "COM6";  // Cambia esto al puerto correcto
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  println("Processing: Inicializado");
}

void draw() {
  background(255);  
  fill(255, 0, 0);
  rect(50, height - temperature, 50, temperature);
  fill(0, 0, 255);
  rect(150, height - humidity, 50, humidity);
  fill(0);
  textSize(16);
  text("T: " + nf(temperature, 2, 1) + " °C", 50, height - temperature - 10);
  text("H: " + nf(humidity, 2, 1) + " %", 150, height - humidity - 10);

  // Send automatic commands to Arduino based on conditions
  sendAutomaticCommands();
}

void serialEvent(Serial p) {
  String val = p.readStringUntil('\n');
  if (val != null) {
    String[] pairs = split(val, ",");
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

    // Update averages and save to file
    updateAveragesAndSave();
  }
}

void sendAutomaticCommands() {
  // Envia 'A' si la temperatura es mayor a x°C, 'a' de lo contrario
  if (temperature >30.0) {
    myPort.write('A');
  } else {
    myPort.write('a');
  }

  // Envia 'B' si la humedad es mayor a x, 'b' de lo contrario
  if (humidity > 32.0) {
    myPort.write('B');
  } else {
    myPort.write('b');
  }
}

void updateAveragesAndSave() {
  count++;
  sumTemperature += temperature;
  sumHumidity += humidity;

  // Calculate the average and save to file
  float avgTemperature = sumTemperature / count;
  float avgHumidity = sumHumidity / count;

  // Save the averages to the file
  saveAveragesToFile(avgTemperature, avgHumidity);
}

void saveAveragesToFile(float avgTemperature, float avgHumidity) {
  try {
    // Obtener la fecha y hora actual
    Date now = new Date();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String dateTime = dateFormat.format(now);

    // Abrir el archivo para escritura
    PrintWriter output = createWriter("promedios.txt");

    // Escribir los datos junto con la fecha y hora
    output.println("DateTime: " + dateTime + ", Average - Temperature: " + nf(avgTemperature, 2, 1) + " °C, Humidity: " + nf(avgHumidity, 2, 1) + " %");

    // Cerrar el archivo
    output.flush();
    output.close();

    println("Processing: File closed");
  } catch (Exception e) {
    e.printStackTrace();
    println("Processing: Error writing to file");
  }
}
