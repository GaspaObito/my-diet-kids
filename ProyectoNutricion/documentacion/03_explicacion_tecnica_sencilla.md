# Explicacion tecnica sencilla

## 1. Estructura del codigo

El proyecto esta dividido en carpetas:

- `lib/main.dart`: inicia la app y configura el tema.
- `lib/screens`: contiene las pantallas.
- `lib/models`: contiene las clases de datos.
- `lib/data`: contiene catalogos como alimentos y retos.
- `lib/services`: contiene la logica para guardar datos y contar pasos.
- `android`: contiene configuracion nativa para generar APK y usar sensores.

## 2. Pantallas principales

### Dashboard
Archivo: `lib/screens/dashboard_screen.dart`

Es la pantalla principal. Muestra:

- Perfil activo.
- Resumen del dia.
- Calorias.
- Agua.
- Retos completados.
- Racha.
- Botones para registrar comida, agua, retos e historial.

### Perfiles
Archivo: `lib/screens/profiles_screen.dart`

Permite:

- Crear un perfil.
- Cambiar de perfil.
- Editar perfil.
- Borrar perfil.

Cada perfil guarda sus propios datos.

### Registro de alimentos
Archivo: `lib/screens/calories_screen.dart`

Permite elegir categoria, alimento y cantidad. Luego calcula nutrientes aproximados.

### Retos diarios
Archivo: `lib/screens/challenges_screen.dart`

Muestra los retos del dia, medallas y rachas. Si todos los retos estan completos, muestra una felicitacion.

## 3. Guardado de informacion

Archivo: `lib/services/nutrition_store.dart`

Se usa `SharedPreferences`, que guarda datos dentro de la app.

Se guarda:

- Lista de perfiles.
- Perfil activo.
- Alimentos por dia.
- Agua por dia.
- Retos completados por dia.
- Dias con medalla.
- Racha actual y mejor racha.

## 4. Catalogo de alimentos

Archivo: `lib/data/food_catalog.dart`

Contiene muchos alimentos organizados por categorias:

- Frutas.
- Verduras.
- Cereales.
- Proteinas.
- Legumbres.
- Lacteos.
- Bebidas.
- Snacks.
- Dulces.
- Comida rapida.

Cada alimento tiene calorias, proteina, carbohidratos, grasa, azucar, fibra y recomendaciones.

## 5. Retos y rachas

Archivo: `lib/data/challenges.dart`

Retos incluidos:

- Tomar 4 vasos de agua.
- Comer una fruta.
- Probar una verdura.
- Cambiar gaseosa por agua.
- Caminar 1500 pasos.

Si el usuario completa todos los retos del dia, gana una medalla. Si gana medallas en dias seguidos, aumenta su racha.

## 6. Sensor de pasos

Archivos:

- `lib/services/step_counter_service.dart`
- `android/app/src/main/kotlin/com/example/flutter_application_1/MainActivity.kt`
- `android/app/src/main/AndroidManifest.xml`

En Android se usa el sensor `TYPE_STEP_COUNTER`. Flutter se comunica con Android por medio de canales:

- `MethodChannel`: inicia el conteo.
- `EventChannel`: recibe pasos mientras la app esta abierta.

Cuando el telefono detecta que se llego a 1500 pasos, el reto de caminar se marca solo.

Nota: esto funciona en celular Android real. En Chrome o emulador puede no funcionar porque no hay sensor real.

