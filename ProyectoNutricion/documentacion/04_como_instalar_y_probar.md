# Como instalar y probar

## Instalar APK en Android

1. Copiar el archivo `apk/app-release.apk` al celular.
2. Abrir el archivo desde el celular.
3. Si Android pregunta por permisos para instalar apps externas, permitirlo.
4. Instalar la app.
5. Abrir MyDiet Kids.

## Probar funciones principales

1. Crear un perfil.
2. Entrar a registrar alimento.
3. Elegir una categoria y un alimento.
4. Escribir una cantidad en gramos.
5. Guardar el alimento.
6. Registrar agua.
7. Entrar a Retos diarios.
8. Completar los retos.
9. Al completar todos, verificar que aparece la felicitacion y la medalla.

## Probar reto de caminar

El reto de caminar necesita un celular Android real.

1. Instalar la APK en un Android.
2. Abrir la pantalla Retos diarios.
3. Aceptar el permiso de actividad fisica.
4. Caminar con el celular.
5. Cuando llegue a 1500 pasos, el reto se completa solo.

## Generar APK nuevamente

En el computador ya quedaron instalados:

- Flutter: `D:\proyecto\flutter`
- JDK 17: `D:\proyecto\jdk-17`
- Android SDK: `D:\proyecto\android-sdk`

Para generar otra APK:

```bat
cd /d D:\flutter_application_1
build_apk.bat
```

La APK quedara en:

```text
D:\flutter_application_1\build\app\outputs\flutter-apk\app-release.apk
```

