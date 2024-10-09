import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Usuario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegistroUsuario(),
    );
  }
}

class RegistroUsuario extends StatefulWidget {
  @override
  _RegistroUsuarioState createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  final _formKey = GlobalKey<FormState>();
  late Database database;
  List<Map<String, dynamic>> usuarios = [];

  String nombre = '';
  String correo = '';
  String fechaNacimiento = '';
  String contrasena = '';

  final MaskedTextController _fechaNacimientoController = MaskedTextController(mask: '00/00/0000');

  int rowsPerPage = 6; // Cambia este valor para mostrar 5 a 10 registros
  int currentPage = 1;
  final List<int> availableRowsPerPage = [5, 6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'usuarios.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            correo TEXT,
            fechaNacimiento TEXT,
            contrasena TEXT
          )
        ''');

      },
    );
    _cargarUsuarios();
  }

  Future<void> _guardarUsuario() async {
    if (_formKey.currentState!.validate()) {
      // Verificar si el correo ya existe
      final List<Map<String, dynamic>> existingUser = await database.query(
        'usuarios',
        where: 'correo = ?',
        whereArgs: [correo],
      );

      if (existingUser.isNotEmpty) {
        _mostrarSnackBar('El correo ya está registrado.');
        return; // Salir del método si el correo ya existe
      }

      fechaNacimiento = _fechaNacimientoController.text;
      await database.insert('usuarios', {
        'nombre': nombre,
        'correo': correo,
        'fechaNacimiento': fechaNacimiento,
        'contrasena': contrasena,
      });
      _mostrarSnackBar('Usuario registrado con éxito.');
      _cargarUsuarios();

      // Limpiar los campos del formulario
      _formKey.currentState!.reset(); // Resetea el formulario
      setState(() {
        nombre = '';
        correo = '';
        fechaNacimiento = '';
        contrasena = '';
        _fechaNacimientoController.text = ''; // Limpiar el controlador de fecha
      });
    }
  }



  Future<void> _cargarUsuarios() async {
    final List<Map<String, dynamic>> usuariosRecuperados = await database.query('usuarios');
    setState(() {
      usuarios = usuariosRecuperados;
      if (usuarios.length < (currentPage - 1) * rowsPerPage) {
        currentPage = 1;
      }
    });
  }

  Future<void> _eliminarUsuario(int id) async {
    await database.delete('usuarios', where: 'id = ?', whereArgs: [id]);
    _mostrarSnackBar('Usuario eliminado con éxito.');
    _cargarUsuarios();
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _obtenerDesdeApi() async {
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['results'][0];
        setState(() {
          nombre = '${data['name']['first']} ${data['name']['last']}';
          correo = data['email'];
          DateTime fecha = DateTime.parse(data['dob']['date']);
          fechaNacimiento = DateFormat('dd/MM/yyyy').format(fecha);
        });

        await database.insert('usuarios', {
          'nombre': nombre,
          'correo': correo,
          'fechaNacimiento': fechaNacimiento,
          'contrasena': ''
        });
        _cargarUsuarios();
        _mostrarSnackBar('Datos cargados y guardados desde la API.');
      } else {
        _mostrarSnackBar('Error al obtener datos de la API.');
      }
    } catch (e) {
      _mostrarSnackBar('Error al obtener datos de la API.');
    }
  }

  Future<void> _confirmarEliminacion(int id) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmar == true) {
      _eliminarUsuario(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (usuarios.length / rowsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Colors.white,
            height: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El campo Nombre es obligatorio';
                        } else if (value.length < 6) {
                          return 'El nombre debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                      onSaved: (value) => nombre = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El campo Correo es obligatorio';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                      onSaved: (value) => correo = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _fechaNacimientoController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        hintText: 'DD/MM/YYYY',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El campo Fecha de Nacimiento es obligatorio';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                          return 'Ingrese una fecha en el formato DD/MM/YYYY';
                        }
                        return null;
                      },
                      onSaved: (value) => fechaNacimiento = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El campo Contraseña es obligatorio';
                        } else if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                      onSaved: (value) => contrasena = value!,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: () {
                        _formKey.currentState!.save();
                        _guardarUsuario();
                      },
                      child: Text('Registrar Usuario'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: _obtenerDesdeApi,
                      child: Text('Obtener Desde API'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(borderRadius: BorderRadius.circular(10.0), color: Colors.blueAccent),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Nombre',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Correo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Fecha de Nacimiento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  for (int i = (currentPage - 1) * rowsPerPage; i < usuarios.length && i < currentPage * rowsPerPage; i++)
                    TableRow(
                      children: [
                        GestureDetector(
                          onLongPress: () => _confirmarEliminacion(usuarios[i]['id']),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(usuarios[i]['nombre']),
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () => _confirmarEliminacion(usuarios[i]['id']),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(usuarios[i]['correo']),
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () => _confirmarEliminacion(usuarios[i]['id']),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(usuarios[i]['fechaNacimiento']),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<int>(
                    value: rowsPerPage,
                    items: availableRowsPerPage.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        rowsPerPage = newValue!;
                        currentPage = 1; // Reiniciar a la primera página al cambiar el número de filas
                      });
                    },
                  ),
                  Text('Página $currentPage de $totalPages'),
                  DropdownButton<int>(
                    value: currentPage,
                    items: List.generate(totalPages, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      );
                    }),
                    onChanged: (int? newValue) {
                      setState(() {
                        currentPage = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
