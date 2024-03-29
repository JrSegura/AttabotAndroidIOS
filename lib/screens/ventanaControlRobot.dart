// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, unused_field, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaGirarDerecha.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';
import 'package:proyecto_tec/screens/ventanaGirarIzquierda.dart';

import 'ventanaAvanzarRetroceder.dart';


// Pantalla principal de control del robot.
class pantallaControlRobot extends StatefulWidget {
  const pantallaControlRobot({Key? key}) : super(key: key);

  @override
  _pantallaControlRobotState createState() => _pantallaControlRobotState();
}


// Incluye la lógica para manejar los gestos de deslizamiento y construir la interfaz de usuario.
class _pantallaControlRobotState extends State<pantallaControlRobot> {
  final TextEditingController controller = TextEditingController();
  final List<String> historial = [];

  // maneja los gestos de deslizamiento en la aplicación.
  void _onSwipe(DragEndDetails detalles) {
    if (detalles.primaryVelocity! < 0) {
      Scaffold.of(context).openEndDrawer();
    }
  }

  // construye la interfaz de usuario de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false, // cuando salia el teclado para ingresar datos me generaba un overflow en la pantalla, esta linea lo soluciona
          appBar: AppBar(
            title: const Text('Atta-bot Educativo'),
            centerTitle: true,
            actions: <Widget>[
              menuDesplegable(
                context: context,
                controller: controller,
                historial: historial,
              ),
            ],
          ),
          body: GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            child: Container(
              margin: const EdgeInsets.all(
                  10.0), 
              padding: const EdgeInsets.all(10.0),
              child: const Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          botonArriba(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              botonIzquierda(),
                              imagenRobotCentral(),
                              botonDerecha(),
                            ],
                          ),
                          botonAbajo(),
                          Column(
                            children: <Widget>[
                              textfieldUltimaAccion(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  BotonEjecutar(),
                                  BotonDeteccionObstaculos(),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  BotonCambioColorCiclo(),
                                  botonBorrarHistorial(),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          endDrawer: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: const ventanaHistorial(),
          ),
        ));
  }
}


//muestra la última acción realizada en un campo de texto.
class textfieldUltimaAccion extends StatelessWidget {
  const textfieldUltimaAccion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      height: 50,
      color: Colors.grey[200],
      child: Consumer<Historial>(
        builder: (context, historial, child) {
          return Center(
            child: Text(// lo fillea con la ultima accion del historial
              historial.historial.isNotEmpty
                  ? historial.historial.last
                  : 'No hay acciones recientes',
            ),
          );
        },
      ),
    );
  }
}

//botón para mover el robot hacia abajo.
class botonAbajo extends StatelessWidget {
  const botonAbajo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_downward), //aca se encuentra el icono que se utiliza para ponerlo en pantalla
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaRetroceder(); 
              },
            );
          },
        ));
  }
}



//botón para mover el robot hacia la derecha, es la parte grafica del boton
class botonDerecha extends StatelessWidget {
  const botonDerecha({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, 
                  height: MediaQuery.of(context).size.height *
                      0.5, 
                  child: const RotacionDerecha(),//llama al widget que realiza la parte grafica y logica de la rotacion 
                ),
              );
            },
          );
        },
      ),
    );
  }
}



//muestra una imagen del robot en el centro de la pantalla.
class imagenRobotCentral extends StatelessWidget {
  const imagenRobotCentral({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      width: 200,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Center(
          child: Image.asset('assets/AttaBotRobot.png'), //aca es donde carga la imagen central del robot
        ),
      ),
    );
  }
}


//botón para mover el robot hacia la izquierda, es la parte grafica del boton
class botonIzquierda extends StatelessWidget {
  const botonIzquierda({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, 
                  height: MediaQuery.of(context).size.height *
                      0.5, 
                  child: const RotacionIzquierda(),//llama al widget que realiza la parte grafica y logica de la rotacion
                ),
              );
            },
          );
        },
      ),
    );
  }
}


//botón para mover el robot hacia la arriba, es la parte grafica del boton
class botonArriba extends StatelessWidget {
  const botonArriba({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaAvanzar(); //llama al widget que realiza la parte grafica y logica de la rotacion
              },
            );
          },
        ));
  }
}

//botón para eliminar el historial
class botonBorrarHistorial extends StatelessWidget {
  const botonBorrarHistorial({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<Historial>(context, listen: false).clear(); //aca es donde elimina el historial
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Historial eliminado'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Icon(Icons.delete_forever),
    );
  }
}

//botón para enviar el historial atraves de bluethoot al esp32
class BotonEjecutar extends StatelessWidget {
  const BotonEjecutar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.play_circle_outline),
        onPressed: () async {
       
          final flutterReactiveBle = FlutterReactiveBle();
          await FlutterBluePlus.adapterState.first;
          String idDispositivo = "";

          if (Platform.isIOS) {
            idDispositivo = "FF8C3368-6EB6-D271-2BE5-AC5CCEBB578A"; //ID de dispositivo esp32 solo se usa si es Ios el dispositivo
          } 
          BluetoothDevice dispositivo =
              BluetoothDevice(remoteId: DeviceIdentifier(idDispositivo));

          if (Platform.isIOS) {
            conexionIos(dispositivo, context); // si es Ios llama a esta funcion para hacer la conexion
          } else if (Platform.isAndroid) {
            conexionAndroid(context, flutterReactiveBle); // si es android llama a esta funcion para hacer la conexion
          }
        });
  }


//funcion que me permite enviar los datos si el dispositivo es ios
//rastrea primero los dispositivos para emparejar, usa un caracteristico y un servicio ya que se usa BLE bluethoot de baja frecuencia
  Future<void> conexionIos(
      BluetoothDevice device, BuildContext context) async {
    await device.connect();

    List<BluetoothService> servicios = await device.discoverServices();
    BluetoothService servicio = servicios.firstWhere((service) =>
        service.uuid == Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b"));
    BluetoothCharacteristic caracteristico = servicio.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8"));

    List<String> historial =
        Provider.of<Historial>(context, listen: false).convertirComandos();//codifica los comandos primeros tipo nemonicos antes de enviarlos
    String historialString = jsonEncode(historial);

    await caracteristico.write(utf8.encode(historialString)); //envia los datos tipo utf8 al esp32
  }
}


//funcion que me permite enviar los datos si el dispositivo es android
//rastrea primero los dispositivos para emparejar, usa un caracteristico y un servicio ya que se usa BLE bluethoot de baja frecuencia
Future<void> conexionAndroid(
    BuildContext context, FlutterReactiveBle flutterReactiveBle,) async {
  // Obtener 'historial' cada vez que se presiona el botón
  var historial =
      Provider.of<Historial>(context, listen: false).convertirComandos();



  const dispositivoID = '80:64:6F:11:32:CA'; //direccion mac del esp32
  final dispositivoConectado =
      await flutterReactiveBle.connectToDevice(id: dispositivoID);
  final caracteristico = QualifiedCharacteristic(
      serviceId: Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'),
      characteristicId: Uuid.parse('beb5483e-36e1-4688-b7f5-ea07361b26a8'),
      deviceId: dispositivoID);

  // Unir todos los elementos de la lista en una sola cadena
  var historialString = historial.join(",");

  flutterReactiveBle.writeCharacteristicWithResponse(caracteristico,
      value: utf8.encode(historialString)); //envia los datos al esp32 de igual forma que en ios
}



//menu desplegable arriba derecha de la pantalla, contiene las funcionalidades de guardar y cargar datos
class menuDesplegable extends StatelessWidget {
  const menuDesplegable({super.key, 
    required this.context,
    required TextEditingController controller,
    required List<String> historial,
  })  : _controller = controller,
        _historial = historial;

  final BuildContext context;
  final TextEditingController _controller;
  final List<String> _historial;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        showMenu(
          context: this.context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(this.context).size.width,
            kToolbarHeight,
            0.0,
            0.0,
          ),
          items: <PopupMenuEntry>[//
            const PopupMenuItem(
              value: 'Opción 1',
              child: Text('Guardar Historial'),
            ),
            const PopupMenuItem(
              value: 'Opción 2',
              child: Text('Cargar Historial'),
            ),
          ],
          elevation: 8.0,
        ).then((value) {
          if (value == 'Opción 1') {
            Provider.of<Historial>(this.context, listen: false) //si se marca la opcion 1 llama a la funcion guardar archivo del historial
                .guardarArchivo(this.context);
          } else if (value == 'Opción 2') {
            Provider.of<Historial>(this.context, listen: false)//si se marca la opcion 1 llama a la funcion cargar archivo del historial
                .cargarArchivo(this.context);
          }
        });
      },
    );
  }
}



//clase del boton del ciclo, tiene la funcionalidad grafica de cambiar el color del boton de acuerdo si se preciono o no
class BotonCambioColorCiclo extends StatefulWidget {
  const BotonCambioColorCiclo({Key? key}) : super(key: key);

  @override
  _BotonCambioColorCicloState createState() => _BotonCambioColorCicloState();
}

class _BotonCambioColorCicloState extends State<BotonCambioColorCiclo> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isPressed = !_isPressed;
        });
        if (_isPressed) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogoCiclo();
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text('Fin del ciclo'),
              );
            },
          );
          Provider.of<Historial>(context, listen: false)//agrega Fin del ciclo al historial si se toco 2 veces
              .addEvento('Fin del ciclo');
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          _isPressed ? Colors.red : Colors.grey,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Icon(Icons.refresh),
    );
  }
}


//pantalla emergente que pregunta cuantas veces quiere realizar el ciclo
class DialogoCiclo extends StatefulWidget {
  const DialogoCiclo({Key? key}) : super(key: key);

  @override
  _DialogoCicloState createState() => _DialogoCicloState();
}

class _DialogoCicloState extends State<DialogoCiclo> {
  int cantidadDeVeces = 2;// minimo de veces para realizar el ciclo 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Realizar ciclo $cantidadDeVeces veces'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (cantidadDeVeces > 0) { //permite bajar la cantidad de veces, si llega a 0 no hace nada
                  cantidadDeVeces--;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() { //permite aumentar la cantidad de veces, no tiene limite 
                cantidadDeVeces++;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Realizar ciclo'),
          onPressed: () {
            Provider.of<Historial>(context, listen: false)
                .addEvento('Inicio de ciclo, $cantidadDeVeces ciclos');// envia la info al historial
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

//boton de deteccion de obstaculos
class BotonDeteccionObstaculos extends StatefulWidget {
  const BotonDeteccionObstaculos({Key? key}) : super(key: key);

  @override
  _BotonDeteccionObstaculosState createState() =>
      _BotonDeteccionObstaculosState();
}

class _BotonDeteccionObstaculosState extends State<BotonDeteccionObstaculos> {
  bool _isActivated = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.remove_red_eye_outlined),
      color: _isActivated ? Colors.red : Colors.grey,
      onPressed: () {
        setState(() {
          _isActivated = !_isActivated;
        });
        Provider.of<Historial>(context, listen: false).addEvento(_isActivated //envia la informacion aca si se activa o se desactiva
            ? 'Detección de obstáculos activada'
            : 'Fin detección de obstáculos');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(_isActivated   // lo muestra en pantalla
                  ? 'Se ha activado la detección de obstáculos'
                  : 'Se ha desactivado la detección de obstáculos'),
            );
          },
        );
      },
    );
  }
}
