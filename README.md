# 📱 Yonna App - Aplicación Móvil Flutter

Aplicación móvil educativa gamificada para aprender Wayuunaiki, desarrollada con Flutter. Parte del ecosistema **Yonna Akademia** que incluye un backend Django REST Framework y un frontend web React.

## 🎯 Objetivo del Proyecto

Yonna App es una experiencia tipo "Duolingo" que combina:
- **Aprendizaje Gamificado**: Sistema de lecciones progresivas, quizzes interactivos, recompensas instantáneas (XP, niveles, logros)
- **Progresión Visible**: Dashboard con estadísticas personales, barras de progreso por curso, racha de días consecutivos, ranking/leaderboard
- **Contenido Multimedia**: Audio para pronunciación, imágenes y videos culturales
- **Interacción Social**: Ver progreso de otros estudiantes, sistema de notificaciones en tiempo real

## 🏗️ Arquitectura General

```
┌─────────────────┐
│  Frontend Web   │  React (repo: yonna_akademia)
│   (React)        │  └─ Contenido cultural y difusión
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
┌────────▼────────┐  ┌────▼──────────────┐
│  Backend API    │  │  Mobile Client     │
│  (Django REST)  │  │  (Flutter)         │
│                 │  │  └─ Este repo      │
│  - JWT Auth     │  │     Experiencia    │
│  - Courses      │  │     tipo Duolingo  │
│  - Quizzes      │  │                    │
│  - Progress     │  │                    │
│  - Stats        │  │                    │
│  - Notifications│  │                    │
└─────────────────┘  └────────────────────┘
```

**Componentes:**
- **Backend**: Django 5 + Django REST Framework + SimpleJWT
- **Frontend Web**: React (repo separado)
- **Mobile Client**: Flutter (este repo)
- **Comunicación**: REST API compartida, tokens JWT

Todos los clientes consumen los mismos endpoints REST del backend.

## ✨ Características Implementadas

### 🔐 Autenticación
- ✅ Login con email/password
- ✅ Registro de nuevos usuarios
- ✅ Login con Google OAuth (preparado)
- ✅ Persistencia de sesión con tokens JWT
- ✅ Refresh automático de tokens
- ✅ Logout seguro

### 👤 Gestión de Usuarios
- ✅ Perfil de usuario completo
- ✅ Edición de perfil (teléfono, localidad, intereses)
- ✅ Sistema de roles: Admin, Moderador, Usuario
- ✅ Sistema de niveles (1-10) basado en XP
- ✅ Visualización de estadísticas personales

### 📚 Cursos
- ✅ Listado de cursos disponibles (filtrados por nivel)
- ✅ Detalle de cursos
- ✅ Inscripción en cursos
- ✅ Progreso por curso
- ✅ Creación de cursos (Moderadores/Admins)
- ✅ Cursos desbloqueables por nivel

### 📝 Quizzes
- ✅ Listado de quizzes disponibles
- ✅ Detalle de quiz con información completa
- ✅ Sistema de intentos de quiz
- ✅ Creación de quizzes con preguntas (Moderadores/Admins)
- ✅ Tipos de preguntas:
  - Opción múltiple
  - Verdadero/Falso
  - Respuesta corta
- ✅ Evaluación automática
- ✅ Revisión detallada de respuestas con explicaciones
- ✅ Sistema de recompensas XP

### 📊 Progreso y Estadísticas
- ✅ Dashboard personalizado por rol
- ✅ Progreso global del usuario
- ✅ Progreso por curso
- ✅ Sistema de rachas (streaks)
- ✅ Leaderboard global
- ✅ Estadísticas detalladas
- ✅ Historial de XP

### 🔔 Notificaciones
- ✅ Listado de notificaciones
- ✅ Contador de no leídas
- ✅ Marcar como leídas
- ✅ Navegación contextual según tipo de notificación
- ✅ Notificaciones automáticas del backend:
  - Nuevo quiz disponible
  - Quiz aprobado
  - Subida de nivel
  - Curso completado
  - Racha de estudio

### 👑 Funcionalidades de Administración
- ✅ Dashboard de administrador con estadísticas del sistema
- ✅ Gestión de usuarios (listar, cambiar roles)
- ✅ Estadísticas de la plataforma
- ✅ Creación de contenido (cursos y quizzes)

## 📱 Pantallas Implementadas

### Autenticación
- **SplashScreen**: Pantalla inicial con logo y verificación de sesión
- **WelcomeScreen**: Pantalla de bienvenida con opciones de acceso
- **LoginScreen**: Inicio de sesión con email/password
- **RegisterScreen**: Registro de nuevos usuarios

### Navegación Principal
- **EnhancedHomeScreen**: Dashboard principal adaptado por rol
  - Vista de Usuario: Estadísticas, cursos destacados, quizzes disponibles
  - Vista de Moderador: Estadísticas de contenido, acciones rápidas
  - Vista de Admin: Estadísticas del sistema, gestión completa

### Perfil
- **ProfileScreen**: Perfil completo del usuario con estadísticas
- **EditProfileScreen**: Edición de datos personales

### Cursos
- **CoursesScreen**: Listado de cursos disponibles
- **CreateCourseScreen**: Creación de nuevos cursos (Moderadores/Admins)

### Quizzes
- **QuizzesScreen**: Listado de quizzes disponibles
- **CreateQuizScreen**: Creación de quizzes con preguntas (Moderadores/Admins)
- **QuizAttemptScreen**: Pantalla interactiva para responder quizzes

### Progreso y Estadísticas
- **ProgressScreen**: Progreso global y por curso
- **LeaderboardScreen**: Tabla de clasificación global
- **AdminStatsScreen**: Estadísticas de la plataforma (Admins)

### Otros
- **NotificationsScreen**: Centro de notificaciones
- **ManageUsersScreen**: Gestión de usuarios (Admins)

## 🏛️ Arquitectura de la Aplicación

### Gestión de Estado
La aplicación usa **Provider** para gestión de estado centralizada:

```dart
AppProvider (lib/providers/app_provider.dart)
├── Estado Global
│   ├── UserModel (usuario actual)
│   ├── List<CourseModel> (cursos)
│   ├── List<QuizModel> (quizzes)
│   ├── List<ProgressModel> (progreso)
│   └── List<NotificationModel> (notificaciones)
│
└── Métodos
    ├── Autenticación (login, register, logout)
    ├── Carga de datos (loadCourses, loadQuizzes, etc.)
    └── Acciones (enrollInCourse, submitQuiz, etc.)
```

### Capa de Servicios
- **ApiService** (`lib/services/api_service.dart`): 
  - Comunicación HTTP con el backend
  - Gestión de tokens JWT
  - Refresh automático de tokens
  - Manejo de errores

### Modelos de Datos
- **UserModel**: Usuario con perfil, rol, nivel, XP
- **CourseModel**: Curso con información, nivel requerido, progreso
- **QuizModel**: Quiz con preguntas, configuración, intentos
- **ProgressModel**: Progreso por curso y global
- **NotificationModel**: Notificaciones del sistema
- **QuizAttemptModel**: Intentos de quiz con resultados

### Widgets Reutilizables
- **CourseCard**: Tarjeta de curso
- **QuizCard**: Tarjeta de quiz
- **ProgressCard**: Tarjeta de progreso
- **XpProgressBar**: Barra de progreso de XP
- **YonnaDrawer**: Menú lateral de navegación

## 🔄 Flujo de Datos

Para una guía completa del flujo de datos desde el inicio hasta todas las pantallas, consulta:
**[GUIA_FLUJO_DATOS.md](./GUIA_FLUJO_DATOS.md)**

### Flujo Principal
```
App Inicia → SplashScreen
    ↓
Verifica autenticación
    ├─→ Autenticado → EnhancedHomeScreen
    └─→ No autenticado → WelcomeScreen
        ↓
    Login/Register → EnhancedHomeScreen
        ↓
    Navegación por la app
        ↓
    Cada pantalla carga datos desde AppProvider
        ↓
    AppProvider obtiene datos de ApiService
        ↓
    ApiService hace requests HTTP al backend
        ↓
    Backend responde con datos
        ↓
    Datos fluyen de vuelta a la UI
        ↓
    UI se actualiza automáticamente
```

## 🚀 Instalación y Configuración

### Requisitos Previos
- Flutter SDK (última versión estable)
- Dart SDK
- Backend Django corriendo y accesible
- Dispositivo/Emulador Android/iOS

### Configuración del Backend
1. Asegúrate de que el backend Django esté corriendo:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
2. Configura CORS para permitir requests desde Flutter
3. Verifica que los endpoints estén disponibles

### Configuración de Flutter
1. Clona el repositorio:
   ```bash
   git clone <repo-url>
   cd yonna_app
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Configura la URL del backend:
   - Abre `lib/services/api_service.dart`
   - Actualiza `baseUrl` con la IP de tu máquina:
     ```dart
     static const String _host = '192.168.1.4'; // Tu IP local
     static const String baseUrl = 'http://$_host:8000/api/';
     ```
   - Para emulador Android AVD: usa `10.0.2.2` en lugar de la IP local

4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

### Configuración para Dispositivo Físico
1. Conecta tu dispositivo a la misma red WiFi que tu máquina
2. Obtén la IP de tu máquina:
   - Windows: `ipconfig`
   - Linux/Mac: `ifconfig`
3. Actualiza `baseUrl` en `api_service.dart` con esa IP
4. Ejecuta `flutter run` y selecciona tu dispositivo

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/                   # Modelos de datos
│   ├── user_model.dart
│   ├── course_model.dart
│   ├── quiz_model.dart
│   ├── progress_model.dart
│   ├── notification_model.dart
│   └── stats_model.dart
├── providers/                # Gestión de estado
│   └── app_provider.dart
├── screens/                  # Pantallas
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── enhanced_home_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   ├── courses_screen.dart
│   ├── create_course_screen.dart
│   ├── quizzes_screen.dart
│   ├── create_quiz_screen.dart
│   ├── quiz_attempt_screen.dart
│   ├── progress_screen.dart
│   ├── notifications_screen.dart
│   ├── leaderboard_screen.dart
│   ├── admin_stats_screen.dart
│   └── manage_users_screen.dart
├── services/                 # Servicios
│   └── api_service.dart
├── widgets/                  # Widgets reutilizables
│   ├── app_styles.dart
│   ├── course_card.dart
│   ├── quiz_card.dart
│   ├── progress_card.dart
│   ├── xp_progress_bar.dart
│   └── yonna_drawer.dart
└── utils/                    # Utilidades
```

## 🔌 Endpoints del Backend Utilizados

### Autenticación
- `POST /api/auth/login/` - Login
- `POST /api/auth/register/` - Registro
- `POST /api/auth/google/` - Login con Google
- `GET /api/auth/profile/` - Obtener perfil
- `PATCH /api/auth/profile/` - Actualizar perfil
- `POST /api/token/refresh/` - Refrescar token

### Cursos
- `GET /api/courses/available/` - Cursos disponibles
- `GET /api/courses/<id>/` - Detalle de curso
- `POST /api/courses/create/` - Crear curso
- `POST /api/courses/enroll/` - Inscribirse en curso
- `GET /api/courses/my-enrollments/` - Mis cursos

### Quizzes
- `GET /api/quizzes/available/` - Quizzes disponibles
- `GET /api/quizzes/<id>/` - Detalle de quiz
- `GET /api/quizzes/course/<id>/` - Quizzes de un curso
- `POST /api/quizzes/create/` - Crear quiz
- `POST /api/quizzes/submit/` - Enviar respuestas

### Progreso
- `GET /api/progress/` - Progreso del usuario
- `GET /api/progress/global/` - Progreso global
- `GET /api/progress/course/<id>/` - Progreso por curso
- `GET /api/progress/leaderboard/` - Leaderboard

### Estadísticas
- `GET /api/stats/overview/` - Resumen estadístico
- `GET /api/stats/xp-history/` - Historial de XP
- `GET /api/stats/leaderboard/` - Tabla de clasificación
- `GET /api/stats/admin/` - Estadísticas de admin

### Notificaciones
- `GET /api/notifications/` - Listar notificaciones
- `GET /api/notifications/recent/` - Notificaciones recientes
- `POST /api/notifications/mark-read/` - Marcar como leída
- `POST /api/notifications/mark-all-read/` - Marcar todas como leídas

## 🎮 Sistema de Gamificación

### Sistema de XP y Niveles
- **XP se gana por**:
  - Completar quizzes (si se aprueba)
  - Completar cursos
  - Mantener rachas de estudio
  - Logros especiales

- **Niveles**:
  - Nivel 1: 0 XP
  - Nivel 2: 100 XP
  - Nivel 3: 250 XP
  - Nivel 4: 500 XP
  - Nivel 5: 1,000 XP
  - Nivel 6: 2,000 XP
  - Nivel 7: 4,000 XP
  - Nivel 8: 8,000 XP
  - Nivel 9: 16,000 XP
  - Nivel 10: 32,000 XP

### Sistema de Rachas (Streaks)
- Racha actual: Días consecutivos estudiando
- Racha más larga: Récord personal
- Se resetea si pasa más de 1 día sin actividad

### Leaderboard
- Ranking global por XP
- Ranking por cursos completados
- Ranking por racha

## 🔧 Mejoras y Correcciones Realizadas

### Correcciones de Modelos
- ✅ Alineación de campos entre modelos y backend
- ✅ Corrección de `enrolledUsersCount` → `enrolledStudentsCount`
- ✅ Corrección de `completionPercentage` → `percentage`
- ✅ Corrección de `courseName` → `courseTitle`
- ✅ Corrección de `isCompleted` → `courseCompleted`
- ✅ Corrección de `totalQuestions` → `questionCount`

### Mejoras de UI/UX
- ✅ Splash screen mejorado con logo y gradiente
- ✅ Perfil de usuario rediseñado con mejor contraste
- ✅ Badge de rol mejorado con fondo sólido
- ✅ Visualización de datos del perfil (teléfono, localidad) siempre visible
- ✅ Dashboard de admin con total de usuarios

### Funcionalidades Completadas
- ✅ Sistema completo de creación de quizzes con preguntas
- ✅ Sistema de respuesta de quizzes con revisión detallada
- ✅ Integración completa con backend para todos los endpoints
- ✅ Manejo de errores mejorado
- ✅ Validaciones de formularios

### Optimizaciones
- ✅ Carga de datos en paralelo
- ✅ Pull-to-refresh en todas las pantallas principales
- ✅ Caché de datos en memoria
- ✅ Refresh automático de tokens

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # Gestión de estado
  http: ^1.1.0              # HTTP client
  shared_preferences: ^2.2.2 # Almacenamiento local
```

## 🧪 Testing

Para ejecutar tests:
```bash
flutter test
```

## 📝 Notas de Desarrollo

### Configuración de IP
- La IP del backend se configura en `lib/services/api_service.dart`
- Para desarrollo local: usa la IP de tu máquina en la red
- Para emulador Android: usa `10.0.2.2`
- Para dispositivo físico: usa la IP local de tu máquina

### Manejo de Errores
- Los errores de red se muestran con SnackBars
- Los errores de validación se muestran en los formularios
- Los tokens expirados se refrescan automáticamente

### Persistencia
- Los tokens JWT se guardan en `SharedPreferences`
- Los datos del usuario se guardan temporalmente
- Los datos se recargan al iniciar la app

## 🚧 Funcionalidades Pendientes

- [ ] WebSocket para notificaciones en tiempo real
- [ ] Modo offline con sincronización
- [ ] Notificaciones push nativas
- [ ] Audio para pronunciación wayuunaiki
- [ ] Videos culturales integrados
- [ ] Sistema de logros y badges
- [ ] Compartir progreso en redes sociales
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)

## 📚 Documentación Adicional

- **[GUIA_FLUJO_DATOS.md](./GUIA_FLUJO_DATOS.md)**: Guía completa del flujo de datos de la aplicación
- Documentación del backend: Ver repositorio del backend Django
- Documentación de Flutter: [docs.flutter.dev](https://docs.flutter.dev)

## 👥 Roles y Permisos

### Usuario (user)
- Ver y tomar cursos
- Responder quizzes
- Ver su progreso
- Ver leaderboard
- Editar su perfil

### Moderador (moderator)
- Todas las funciones de usuario
- Crear cursos
- Crear quizzes
- Ver estadísticas de contenido

### Administrador (admin)
- Todas las funciones de moderador
- Gestionar usuarios
- Ver estadísticas de la plataforma
- Cambiar roles de usuarios

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es parte del ecosistema Yonna Akademia.

## 📞 Contacto

Para más información sobre el proyecto, consulta el repositorio del backend o el frontend web.

---

**Desarrollado con ❤️ para preservar y enseñar el idioma Wayuunaiki**
