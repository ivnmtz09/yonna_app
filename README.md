# yonna_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

* [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Yonna App — README actualizado

Este repositorio contiene la aplicación móvil **Yonna App** (Flutter), cliente móvil del proyecto **Yonna Akademia**. Mantengo la introducción original arriba y, a continuación, agrego la descripción técnica, el flujo de pantallas, cómo se conecta con el backend y con el frontend web, y las instrucciones para ejecutar y preparar el proyecto para entrega.

### Objetivo del proyecto

Yonna App es la aplicación móvil de una plataforma educativa gamificada para aprender Wayuunaiki (desde español). El objetivo es construir una experiencia tipo "Duolingo" que combine lecciones, retos y progresión gamificada, conectada a un backend Django compartido con un frontend React.

En esta fase el objetivo es tener un flujo de autenticación unificado (registro manual, login manual y login con Google en el backend), pantallas principales (Splash, Welcome, Login, Register, Home, Profile), persistencia de sesión segura, y una base visual lista para añadir gamificación.

### Arquitectura general

* **Frontend Web**: React (repo: `yonna_akademia`), consume el mismo backend Django.
* **Mobile Client**: Flutter (este repo), comparte la API con React y usa tokens JWT.
* **Backend**: Django 5 + Django REST Framework + SimpleJWT. Implementa endpoints de autenticación y recursos (users, profile, courses, quizzes, etc.).

Todos los clientes (React y Flutter) consumen los mismos endpoints REST del backend.

### Autenticación y flujo de tokens

* Endpoints relevantes en el backend (ejemplos):

  * `POST /api/auth/login/` → obtención de `access` y `refresh` (JWT)
  * `POST /api/auth/register/` → registro de usuario (recibe `email`, `first_name`, `last_name`, `password1`, `password2`)
  * `GET  /api/auth/profile/` → devuelve perfil extendido (incluye `usuario` con `first_name`, `email`, `role`, `level`)
  * `POST /api/auth/google/` → login/registro mediante token de Google (OAuth2)

* En Flutter:

  * Se usa **Dio** con un interceptor (en `lib/services/api_service.dart`) que añade automáticamente `Authorization: Bearer <token>` si existe token en `flutter_secure_storage`.
  * Tokens se guardan de forma segura con `flutter_secure_storage` (`lib/utils/secure_storage.dart`).
  * `AuthService` centraliza llamadas de login, register, loginWithGoogle y logout.

### Estructura de pantallas (screens)

* `SplashScreen`:

  * Verifica si existe token válido (llamando a storage o validando con backend).
  * Redirige a `HomeScreen` si está autenticado o a `WelcomeScreen` si no.

* `WelcomeScreen`:

  * Presentación (logo, descripción corta).
  * Botones: "Acceder" (→ `LoginScreen`) y "Registrarse" (→ `RegisterScreen`).
  * Aviso: "Inicio con Google disponible próximamente" (se muestra hasta habilitar).
  * Mascota (imagen en esquina inferior derecha).

* `LoginScreen`:

  * Form: `email`, `password` con opción ver/ocultar.
  * Botón login → llama `POST /api/auth/login/` y guarda tokens si OK.
  * Link a registro.

* `RegisterScreen`:

  * Campos: `first_name`, `last_name`, `email`, `password1`, `password2`.
  * Envía JSON exactamente en la forma que espera el backend.
  * Muestra mensajes de error tal como los devuelve el backend.

* `HomeScreen` (Dashboard básico):

  * AppBar: saludo en español "Hola, <Nombre>" (nombre obtenido desde `GET /api/auth/profile/`), botón Perfil y Logout.
  * Cuerpo: mensaje informativo "Próximamente..." con tarjetas (Lecciones, Retos, Progreso, Cultura) marcadas como "Próximamente".
  * Mascota centrada en la parte inferior. Debajo de la mascota, saludo en wayuunaiki (ej. "Jamaya pia, <usuario>?" o "Ajaa, <usuario>!").

* `ProfileScreen`:

  * Llama `GET /api/auth/profile/` y muestra:

    * Nombre completo, correo.
    * Rol traducido (admin → Administrador, teacher → Sabedor/Docente, student → Estudiante).
    * Nivel traducido (beginner → Principiante, intermediate → Intermedio, advanced → Avanzado).
  * Mensaje: "La edición de perfil estará disponible próximamente." (botón Editar perfil reservado para futuro).

### Esquema de navegación (resumen)

```
SplashScreen
  ├─ (token válido) → HomeScreen
  └─ (sin token)   → WelcomeScreen

WelcomeScreen
  ├─ Acceder → LoginScreen
  └─ Registrarse → RegisterScreen

LoginScreen/ RegisterScreen
  └─ Login/Registro exitoso → HomeScreen

HomeScreen
  ├─ Perfil → ProfileScreen
  └─ Logout → limpia token y → SplashScreen
```

### Cómo conectamos los servicios de autenticación (paso a paso)

1. **Configurar el backend**:

   * Ejecutar Django: `python manage.py runserver 0.0.0.0:8000` (para exponer la API en la red local).
   * Asegurar CORS (ej. `CORS_ALLOW_ALL_ORIGINS = True` o `CORS_ALLOWED_ORIGINS` con tus ORIGENES locales).
   * Verificar que los endpoints `/api/auth/login/`, `/api/auth/register/` y `/api/auth/profile/` están disponibles.

2. **Configurar Flutter (cliente móvil)**:

   * `lib/services/api_service.dart` contiene `baseUrl` (por defecto configurado a la IP de la máquina de desarrollo, p. ej. `http://192.168.1.4:8000/api/`). Si pruebas desde un emulador AVD usa `10.0.2.2`.
   * `AuthService.login()` y `AuthService.register()` envían las peticiones correctas al backend.
   * Si el login retorna `access` y `refresh`, el cliente guarda `access` en `flutter_secure_storage` y el interceptor de Dio añade `Authorization` a todas las peticiones subsecuentes.
   * `GET /api/auth/profile/` devuelve la información del usuario autenticado; el cliente la consume para mostrar el nombre y otros datos.

3. **Persistencia y logout**:

   * Los tokens JWT se guardan en `flutter_secure_storage`.
   * Al hacer logout se limpian los tokens y se redirige al `SplashScreen`.

### Instrucciones para ejecutar (rápido)

1. Asegúrate de que el backend Django esté corriendo y accesible desde la red local (ver `ipconfig` / `ifconfig` para obtener la IP de tu máquina).
2. Ajusta `baseUrl` en `lib/services/api_service.dart` con la IP (ej. `http://192.168.1.4:8000/api/`) o usa `10.0.2.2` para emulador AVD.
3. Ejecuta el backend:

   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
4. Ejecuta la app Flutter:

   ```bash
   flutter pub get
   flutter run
   ```
5. Para pruebas desde el teléfono físico, conecta el dispositivo a la misma red WiFi que la máquina que ejecuta Django.

### Archivos y rutas importantes

* `lib/screens/` → pantallas: `splash_screen.dart`, `welcome_screen.dart`, `login_screen.dart`, `register_screen.dart`, `home_screen.dart`, `profile_screen.dart`.
* `lib/services/` → `api_service.dart`, `auth_service.dart`.
* `lib/utils/secure_storage.dart` → helpers para almacenamiento seguro.
* `assets/images/` → `yonna.png`, `mascota.png`, `icon.png`.

### Entregables y recomendaciones para el repositorio

* Incluye este README actualizado en la raíz del repo Flutter.
* Asegúrate de tener `.gitignore` correcto y no subir claves (`google-services.json`, `.env`, etc.).
* Sube la imagen `mascota.png` y el `icon.png` (o genera íconos con `flutter_launcher_icons`).

### Qué queremos lograr a futuro

* Habilitar autentificación vía Google (nativa en Android/iOS).
* Implementar edición de perfil y carga/edición de avatar.
* Construir y exponer las pantallas de gamificación: lecciones, retos, misiones, progreso con métricas y recompensas.
* Añadir notificaciones push para retos y progreso.
* Preparar pipelines de CI/CD y builds por ambiente (dev/staging/prod).
