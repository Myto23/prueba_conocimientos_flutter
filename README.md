Registro de Usuario - Flutter App
Descripción
"Registro de Usuario" es una aplicación móvil construida con Flutter, que permite gestionar un registro de usuarios con una base de datos local SQLite. Los usuarios pueden ser añadidos, eliminados, y también pueden ser cargados de una API externa para fines de demostración.

Funcionalidades
Agregar usuarios: Los usuarios pueden registrar su nombre, correo, fecha de nacimiento y contraseña.
Validación de formulario: El formulario cuenta con validaciones para asegurar la integridad de los datos (formato de correo, longitud de la contraseña, formato de fecha).
Guardar en base de datos local: Los datos de los usuarios se almacenan localmente utilizando SQLite.
Eliminar usuarios: Los usuarios pueden eliminarse manteniendo pulsado sobre un registro en la tabla.
Carga desde API externa: Los usuarios pueden ser cargados automáticamente desde la API de randomuser.me.
Paginación: Los usuarios se muestran en una tabla con opciones de paginación y selección del número de registros por página.
Instalación
Clona el repositorio:

bash
Copiar código
git clone https://github.com/tu-usuario/registro-usuario-flutter.git
Navega al directorio del proyecto:

bash
Copiar código
cd registro-usuario-flutter
Instala las dependencias del proyecto:

bash
Copiar código
flutter pub get
Ejecuta la aplicación en tu emulador o dispositivo físico:

bash
Copiar código
flutter run
Dependencias
Las siguientes dependencias se utilizan en el proyecto:

Flutter: Para la creación de la interfaz de usuario.
sqflite: Para el almacenamiento de datos local utilizando SQLite.
path_provider: Para acceder a directorios específicos del sistema donde se almacenan los datos.
flutter_masked_text2: Para manejar el formato de campos de entrada, como la fecha de nacimiento.
http: Para realizar peticiones HTTP a la API externa.
intl: Para formatear fechas.
Puedes encontrar todas las dependencias en el archivo pubspec.yaml.

Uso
Registrar un nuevo usuario:

Completa los campos del formulario de nombre, correo, fecha de nacimiento (en formato DD/MM/YYYY) y contraseña.
Presiona el botón "Registrar Usuario". Si los datos son válidos, el usuario será agregado a la base de datos.
Cargar un usuario desde la API:

Presiona el botón "Obtener Desde API" para cargar automáticamente un usuario de ejemplo desde la API externa y agregarlo a la base de datos.
Eliminar un usuario:

Mantén presionado sobre cualquier fila en la tabla de usuarios para eliminarlo tras confirmar la acción.
Paginación:

Cambia el número de registros por página usando el menú desplegable.
Navega entre páginas usando el selector de páginas.
Estructura del Proyecto
bash
Copiar código
/lib
  ├── main.dart           # Código principal de la aplicación
  └── ...                 # Otros archivos y widgets si es necesario
Capturas de pantalla
Agrega aquí capturas de pantalla o GIFs que muestren cómo luce la aplicación y cómo se utiliza.

API utilizada
Random User API: Se utiliza para obtener datos de usuarios aleatorios. Documentación oficial en randomuser.me.
Contribuciones
¡Las contribuciones son bienvenidas! Si deseas mejorar la aplicación, puedes hacer un fork del repositorio, realizar cambios y luego enviar un pull request.

Haz un fork del proyecto.

Crea una rama para tus cambios:

bash
Copiar código
git checkout -b feature/nueva-funcionalidad
Realiza tus modificaciones y haz commits de forma adecuada.

Envía un pull request.

Licencia
Este proyecto está bajo la licencia MIT. Puedes ver más detalles en el archivo LICENSE.

Este README proporciona una visión general clara y completa del proyecto, su instalación, uso y desarrollo.
