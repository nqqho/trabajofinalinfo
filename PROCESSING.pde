import processing.serial.*;
import java.util.Date;
import java.text.SimpleDateFormat;

Serial myPort;
float temperatura = 0;
float humedad = 0;
float sumaTemperatura = 0;
float sumaHumedad = 0;
int contador = 0;

void setup() {
  // Configura el tamaño de la ventana de dibujo
  size(260, 200);
  
  // Especifica el nombre del puerto al que está conectado tu dispositivo Arduino
  String nombrePuerto = "COM6";  // Cambia esto al puerto correcto
  myPort = new Serial(this, nombrePuerto, 9600);
  
  // Configura el programa para esperar hasta que llegue un salto de línea antes de procesar los datos
  myPort.bufferUntil('\n');
  
  // Imprime un mensaje indicando que el programa de Processing ha sido inicializado
  println("Processing: Inicializado");
}

void draw() {
  // Establece el fondo blanco
  background(255);  
  
  // Dibuja rectángulos que representan la temperatura y la humedad en la pantalla
  fill(255, 0, 0);
  rect(50, height - temperatura, 50, temperatura);
  fill(0, 0, 255);
  rect(150, height - humedad, 50, humedad);
  
  // Muestra información de temperatura y humedad en la pantalla
  fill(0);
  textSize(16);
  text("T: " + nf(temperatura, 2, 1) + " °C", 50, height - temperatura - 10);
  text("H: " + nf(humedad, 2, 1) + " %", 150, height - humedad - 10);

  // Envía comandos automáticos a Arduino basados en condiciones
  enviarComandosAutomaticos();
}

void serialEvent(Serial p) {
  // Lee la cadena de datos hasta el salto de línea
  String val = p.readStringUntil('\n');
  
  // Verifica si se recibieron datos
  if (val != null) {
    // Divide la cadena en pares clave-valor separados por comas
    String[] pares = split(val, ",");
    
    // Itera sobre los pares clave-valor
    for (String par : pares) {
      // Divide cada par en clave y valor
      String[] claveValor = split(par, ':');
      
      // Verifica si el par tiene dos elementos
      if (claveValor.length == 2) {
        // Actualiza las variables de temperatura y humedad según los datos recibidos
        if (claveValor[0].equals("T")) {
          temperatura = float(claveValor[1]);
        } else if (claveValor[0].equals("H")) {
          humedad = float(claveValor[1]);
        }
      }
    }
    
    // Imprime un mensaje indicando que se han recibido datos
    println("Processing: Datos recibidos - Temperatura=" + temperatura + ", Humedad=" + humedad);

    // Actualiza promedios y guarda en archivo
    actualizarPromediosYGuardar();
  }
}

void enviarComandosAutomaticos() {
  // Envia 'A' si la temperatura es mayor a 30.0°C, 'a' de lo contrario
  if (temperatura > 30.0) {
    myPort.write('A');
  } else {
    myPort.write('a');
  }

  // Envia 'B' si la humedad es mayor a 32.0, 'b' de lo contrario
  if (humedad > 32.0) {
    myPort.write('B');
  } else {
    myPort.write('b');
  }
}

void actualizarPromediosYGuardar() {
  // Incrementa el contador de muestras
  contador++;
  
  // Suma las temperaturas y humedades recibidas
  sumaTemperatura += temperatura;
  sumaHumedad += humedad;

  // Calcula el promedio y guarda en archivo
  float promedioTemperatura = sumaTemperatura / contador;
  float promedioHumedad = sumaHumedad / contador;

  // Guarda los promedios en el archivo
  guardarPromediosEnArchivo(promedioTemperatura, promedioHumedad);
}

void guardarPromediosEnArchivo(float promedioTemperatura, float promedioHumedad) {
  try {
    // Obtener la fecha y hora actual
    Date ahora = new Date();
    SimpleDateFormat formatoFecha = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String fechaHora = formatoFecha.format(ahora);

    // Abrir el archivo para escritura
    PrintWriter salida = createWriter("promedios.txt");

    // Escribir los datos junto con la fecha y hora
    salida.println("FechaHora: " + fechaHora + ", Promedio - Temperatura: " + nf(promedioTemperatura, 2, 1) + " °C, Humedad: " + nf(promedioHumedad, 2, 1) + " %");

    // Cerrar el archivo
    salida.flush();
    salida.close();

    // Imprimir un mensaje indicando que se ha cerrado el archivo
    println("Processing: Archivo cerrado");
  } catch (Exception e) {
    // Imprimir un mensaje de error en caso de problemas al escribir en el archivo
    println("Processing: Error al escribir en el archivo");
  }
}
