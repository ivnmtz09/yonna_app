# Yonna App

## Descripción General

**Yonna App** es la aplicación móvil del proyecto **Yonna Akademia**, una plataforma educativa gamificada para aprender **Wayuunaiki** (desde el español). Inspirada en la experiencia de aprendizaje de Duolingo, combina lecciones, retos y progresión gamificada.

El cliente móvil está desarrollado en **Flutter**, y se conecta a un **backend Django** compartido con un frontend **React**.

---

## Objetivo del Proyecto

En esta fase inicial, el objetivo es:

* Implementar un flujo de autenticación unificado (registro y login manual).
* Crear las pantallas principales: *Splash*, *Welcome*, *Login*, *Register*, *Home*, *Profile*.
* Persistir la sesión del usuario.
* Establecer una base visual y funcional para la futura gamificación.

---

## Arquitectura General

* **Frontend Web:** React (repo: `yonna_akademia`), comparte el backend Django.
* **Mobile Client:** Flutter (este repo), usa tokens JWT para autenticación.
* **Backend:** Django 5 + Django REST Framework + SimpleJWT.

Todos los clientes consumen los mismos endpoints REST del backend.

---

## Autenticación y Flujo de Datos

Se migró de `dio` y `flutter_secure_storage` a un stack más simple:

* **Red:** paquete `http` (oficial de Dart).
* **Almacenamiento local:** `shared_preferences` para guardar tokens y datos de usuario (JSON).
* **Servicio centralizado:** `lib/services/api_service.dart` gestiona toda la red y el estado de autenticación.
* **Patrón Singleton:** `ApiService` se inicializa una vez y se usa globalmente.

### Flujo de Login y Perfil

1. El usuario ingresa sus credenciales en `LoginScreen`.
2. `ApiService().login()` envía `email` y `password` al endpoint `POST /api/auth/login/`.
3. Si es exitoso, el backend devuelve los *tokens* y datos del usuario.
4. `ApiService` guarda la información en `SharedPreferences` y en memoria.
5. La app navega a `HomeScreen`.
6. `ProfileScreen` lee los datos directamente de `ApiService().userData` sin llamar a la API.

---

## Estructura de Pantallas

### SplashScreen

* Muestra el logo animado y el saludo "Antüshi pia" (Bienvenido).
* Verifica si hay token en `SharedPreferences`.
* Redirige a `HomeScreen` o `WelcomeScreen`.

### WelcomeScreen

* Presentación con "Antüshi pia (Bienvenido)".
* Botones: **Iniciar Sesión** → `LoginScreen`, **Registrarse** → `RegisterScreen`.

### LoginScreen

* Logo y subtítulo "Yonna App by Yonna Akademia".
* Formulario: email y password.
* Envía `POST /api/auth/login/`.
* Incluye opción "Entrar con Google" (próximamente).

### RegisterScreen

* Logo y subtítulo "Yonna App by Yonna Akademia".
* Campos: `first_name`, `last_name`, `email`, `password1`, `password2`.
* Envía `POST /api/auth/register/`.

### HomeScreen (Dashboard)

* AppBar con título "Yonna App".
* Drawer con "Mi Perfil" y "Cerrar Sesión".
* Cuerpo: mensaje "Próximamente" con la mascota.

### ProfileScreen

* Muestra datos del usuario desde `ApiService().userData`.
* Incluye botón "Cerrar Sesión".

---

## Esquema de Navegación

```
SplashScreen
  ├─ (token válido) → HomeScreen
  └─ (sin token)    → WelcomeScreen

WelcomeScreen
  ├─ Iniciar Sesión → LoginScreen
  └─ Registrarse    → RegisterScreen

LoginScreen / RegisterScreen
  └─ Exitoso → HomeScreen

HomeScreen
  ├─ Mi Perfil → ProfileScreen
  └─ Cerrar Sesión → limpia tokens → SplashScreen
```

---

## Conexión con el Backend (Paso a Paso)

### 1. Configurar Backend

* Ejecutar Django: `python manage.py runserver 0.0.0.0:8000`
* Verificar endpoints disponibles: `/api/auth/login/`, `/api/auth/register/`, `/api/auth/profile/`
* Ajustar configuración CORS si es necesario.

### 2. Configurar Flutter

* En `lib/services/api_service.dart`, actualizar `baseUrl` con la IP local:

  * Ejemplo: `http://192.168.1.4:8000/api/` (teléfono físico)
  * `http://10.0.2.2:8000/api/` (emulador Android)
* `ApiService.login()` y `ApiService.register()` usan `http`.
* `ApiService.getProfile()` agrega header `Authorization: Bearer <token>`.

### 3. Persistencia y Logout

* Tokens y datos se guardan en `SharedPreferences`.
* `ApiService.logout()` limpia datos y redirige a `SplashScreen`.

---

## Instrucciones Rápidas de Ejecución

### Backend

```bash
python manage.py runserver 0.0.0.0:8000
```

### Flutter

```bash
flutter pub get
flutter run
```

**Nota:** si pruebas en un teléfono físico, asegúrate de que esté en la misma red WiFi que el backend.

---

## Archivos y Rutas Importantes

```
lib/
├── main.dart               # Inicialización de la app y rutas
├── screens/                # Pantallas principales
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   └── profile_screen.dart
├── services/
│   └── api_service.dart    # Servicio unificado de red y autenticación
└── widgets/
    ├── app_styles.dart
    └── yonna_drawer.dart
```

**Assets:** `assets/images/` contiene `yonna.png`, `mascota.png`, `loading.gif`, `welcome.png`, `saludo.png`.

---

## Futuras Mejoras

* Autenticación con Google (Android/iOS).
* Edición de perfil y avatar.
* Pantallas de gamificación: lecciones, retos, misiones y progreso.
* Notificaciones push.
