# 📱 Guía Completa del Flujo de Datos - Yonna Akademia

## 📋 Índice
1. [Inicio de la Aplicación](#1-inicio-de-la-aplicación)
2. [Splash Screen](#2-splash-screen)
3. [Autenticación](#3-autenticación)
4. [Home Screen (Dashboard)](#4-home-screen-dashboard)
5. [Pantallas Principales](#5-pantallas-principales)
6. [Flujos Específicos](#6-flujos-específicos)
7. [Arquitectura de Datos](#7-arquitectura-de-datos)

---

## 1. Inicio de la Aplicación

### 📍 Punto de Entrada: `main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar ApiService (SharedPreferences)
  await ApiService().init();
  
  // 2. Ejecutar la aplicación
  runApp(const MyApp());
}
```

**Flujo:**
1. **Inicialización del Binding**: Asegura que Flutter esté listo
2. **Inicialización de ApiService**: 
   - Carga `SharedPreferences`
   - Lee tokens guardados (`access_token`, `refresh_token`)
   - Lee datos de usuario guardados (`userData`)
3. **Configuración de Providers**:
   - `AppProvider` se crea como singleton global
   - Gestiona todo el estado de la aplicación

### 🎨 Configuración de la App (`MyApp`)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppProvider()),
  ],
  child: MaterialApp(
    initialRoute: '/',  // ← Empieza en SplashScreen
    routes: { ... }
  )
)
```

**Rutas Definidas:**
- `/` → `SplashScreen`
- `/welcome` → `WelcomeScreen`
- `/login` → `LoginScreen`
- `/register` → `RegisterScreen`
- `/home` → `EnhancedHomeScreen`
- `/profile` → `ProfileScreen`
- `/courses` → `CoursesScreen`
- `/quizzes` → `QuizzesScreen`
- `/progress` → `ProgressScreen`
- `/notifications` → `NotificationsScreen`
- `/create-course` → `CreateCourseScreen`
- `/create-quiz` → `CreateQuizScreen`
- `/quiz-attempt` → `QuizAttemptScreen` (ruta dinámica)

---

## 2. Splash Screen

### 📍 Archivo: `lib/screens/splash_screen.dart`

### 🔄 Flujo de Datos

```
Usuario presiona el logo → SplashScreen se muestra
    ↓
Espera 3 segundos (mínimo)
    ↓
AppProvider.initializeApp()
    ↓
    ├─→ Verifica si hay tokens guardados
    │   ├─→ Si hay tokens → Intenta validar sesión
    │   │   ├─→ GET /api/auth/me/ (con token)
    │   │   ├─→ Si válido → Carga datos del usuario
    │   │   └─→ Si inválido → Limpia tokens
    │   └─→ Si no hay tokens → No hace nada
    │
    └─→ Si usuario autenticado:
        ├─→ loadUserData() → GET /api/auth/profile/
        ├─→ loadCourses() → GET /api/courses/available/
        ├─→ loadQuizzes() → GET /api/quizzes/available/
        ├─→ loadProgress() → GET /api/progress/
        └─→ loadNotifications() → GET /api/notifications/recent/
    ↓
Decisión de navegación:
    ├─→ Si isAuthenticated == true → Navigator.pushReplacementNamed('/home')
    └─→ Si isAuthenticated == false → Navigator.pushReplacementNamed('/welcome')
```

### 📊 Datos Cargados en el Splash

**Si el usuario está autenticado:**
1. **Datos del Usuario**:
   - `GET /api/auth/profile/`
   - Guarda en `AppProvider._user` (UserModel)
   - Incluye: id, email, nombre, rol, nivel, XP, perfil

2. **Cursos Disponibles**:
   - `GET /api/courses/available/`
   - Filtrados por nivel del usuario
   - Guarda en `AppProvider._courses` (List<CourseModel>)

3. **Quizzes Disponibles**:
   - `GET /api/quizzes/available/`
   - Guarda en `AppProvider._quizzes` (List<QuizModel>)

4. **Progreso del Usuario**:
   - `GET /api/progress/`
   - Guarda en `AppProvider._progress` (List<ProgressModel>)

5. **Notificaciones Recientes**:
   - `GET /api/notifications/recent/`
   - Guarda en `AppProvider._notifications` (List<NotificationModel>)
   - Actualiza contador de no leídas

---

## 3. Autenticación

### 🔐 Pantalla de Bienvenida (`WelcomeScreen`)

**Opciones:**
- Botón "Iniciar Sesión" → Navega a `/login`
- Botón "Registrarse" → Navega a `/register`
- Botón "Continuar con Google" → OAuth con Google

### 📝 Login (`LoginScreen`)

**Flujo:**

```
Usuario ingresa email y password
    ↓
Presiona "Iniciar Sesión"
    ↓
AppProvider.login(email, password)
    ↓
ApiService.login(email, password)
    ↓
POST /api/auth/login/
Body: {
  "email": "usuario@example.com",
  "password": "password123"
}
    ↓
Respuesta del Backend:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": { ... }
}
    ↓
ApiService guarda tokens:
    ├─→ SharedPreferences.setString('access_token', access)
    └─→ SharedPreferences.setString('refresh_token', refresh)
    ↓
AppProvider crea UserModel desde respuesta
    ↓
AppProvider._loadInitialData() (carga cursos, quizzes, etc.)
    ↓
Navigator.pushReplacementNamed('/home')
```

**Datos Guardados:**
- `access_token`: Token JWT válido por 60 minutos
- `refresh_token`: Token JWT válido por 7 días
- `userData`: Datos del usuario en JSON

### 📝 Registro (`RegisterScreen`)

**Flujo:**

```
Usuario completa formulario:
    ├─→ Nombre
    ├─→ Apellido
    ├─→ Email
    └─→ Password
    ↓
Presiona "Registrarse"
    ↓
AppProvider.register(...)
    ↓
ApiService.register(...)
    ↓
POST /api/auth/register/
Body: {
  "first_name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "password": "password123"
}
    ↓
Respuesta del Backend:
{
  "access": "...",
  "refresh": "...",
  "user": { ... }
}
    ↓
Mismo flujo que login (guarda tokens, crea UserModel)
    ↓
Navigator.pushReplacementNamed('/home')
```

### 🔄 Refresh Token Automático

**Cuando un request falla con 401 (Unauthorized):**

```
Request falla con 401
    ↓
ApiService._makeAuthenticatedRequest detecta error
    ↓
Intenta refrescar token:
    POST /api/token/refresh/
    Body: { "refresh": "<refresh_token>" }
    ↓
    ├─→ Si exitoso:
    │   ├─→ Obtiene nuevo access_token
    │   ├─→ Guarda nuevo token
    │   └─→ Reintenta request original
    │
    └─→ Si falla:
        ├─→ Limpia tokens
        ├─→ Limpia datos de usuario
        └─→ Fuerza logout → Navega a /welcome
```

---

## 4. Home Screen (Dashboard)

### 📍 Archivo: `lib/screens/enhanced_home_screen.dart`

### 🔄 Flujo de Datos al Abrir

```
EnhancedHomeScreen se construye
    ↓
initState() → _loadData()
    ↓
    ├─→ Si user == null → loadUserData()
    ├─→ loadCourses()
    ├─→ loadQuizzes()
    ├─→ loadProgress()
    ├─→ loadNotifications()
    └─→ Si es admin → _loadTotalUsers()
    ↓
Consumer<AppProvider> escucha cambios
    ↓
Renderiza contenido según rol:
    ├─→ Si es Admin → _buildAdminHome()
    ├─→ Si es Moderador → _buildModeratorHome()
    └─→ Si es Usuario → _buildUserHome()
```

### 👤 Vista de Usuario (`_buildUserHome`)

**Datos Mostrados:**

1. **Saludo Personalizado**:
   - `user.firstName` + hora del día
   - `user.level` (nivel actual)
   - `user.xp` (XP total)

2. **Estadísticas del Usuario** (`_buildUserStats`):
   - Cursos inscritos: `progress.length`
   - Quizzes completados: `quizzes.where((q) => q.isCompleted).length`
   - XP total: `user.xp`
   - Racha actual: `progress.first.currentStreak` (si existe)

3. **Cursos Destacados** (`_buildFeaturedCourses`):
   - `courses.where((c) => c.isActive && !c.isEnrolled)`
   - Muestra: título, descripción, nivel requerido, estudiantes inscritos

4. **Progreso Reciente** (`_buildRecentProgress`):
   - `progress.take(3)` (últimos 3 cursos)
   - Muestra: título, porcentaje, quizzes completados

5. **Quizzes Disponibles** (`_buildAvailableQuizzes`):
   - `quizzes.where((q) => q.canAttempt && q.isActive)`
   - Muestra: título, dificultad, XP recompensa, intentos

### 👨‍💼 Vista de Moderador (`_buildModeratorHome`)

**Datos Mostrados:**

1. **Estadísticas**:
   - Total de cursos: `courses.length`
   - Total de quizzes: `quizzes.length`
   - Estudiantes inscritos: `courses.sum(enrolledStudentsCount)`

2. **Acciones Rápidas**:
   - Crear curso → Navega a `/create-course`
   - Crear quiz → Navega a `/create-quiz`
   - Ver estadísticas → Navega a `/admin-stats`

3. **Cursos Creados**:
   - `courses.where((c) => c.createdBy == user.id)`
   - Muestra: título, estudiantes inscritos, estado

### 👑 Vista de Admin (`_buildAdminHome`)

**Datos Mostrados:**

1. **Estadísticas del Sistema**:
   - Total de usuarios: `_totalUsers` (cargado de `getAllUsers()`)
   - Total de cursos: `courses.length`
   - Total de quizzes: `quizzes.length`
   - Actividad hoy: (pendiente de implementar)

2. **Resumen del Sistema** (`_buildAdminOverview`):
   - Cursos activos
   - Quizzes activos
   - Usuarios registrados
   - Actividad del día

3. **Acciones de Administración**:
   - Gestionar usuarios → `/manage-users`
   - Ver estadísticas → `/admin-stats`
   - Crear contenido → `/create-course`, `/create-quiz`

### 🔄 Pull-to-Refresh

```
Usuario hace pull-to-refresh
    ↓
_refresh() se ejecuta
    ↓
Vuelve a cargar todos los datos:
    ├─→ loadCourses()
    ├─→ loadQuizzes()
    ├─→ loadProgress()
    ├─→ loadNotifications()
    └─→ Si es admin → _loadTotalUsers()
    ↓
Consumer se actualiza automáticamente
```

---

## 5. Pantallas Principales

### 📚 Courses Screen (`CoursesScreen`)

**Flujo:**

```
Pantalla se abre
    ↓
initState() → _loadCourses()
    ↓
AppProvider.loadCourses()
    ↓
ApiService.getAvailableCourses()
    ↓
GET /api/courses/available/
    ↓
Respuesta: Lista de cursos filtrados por nivel
    ↓
AppProvider._courses se actualiza
    ↓
Consumer renderiza lista de cursos
```

**Acciones:**

1. **Ver Detalle de Curso**:
   - Toca un curso → Muestra `CourseDetailSheet`
   - Datos: título, descripción, nivel, dificultad, quizzes

2. **Inscribirse en Curso**:
   - Presiona "Inscribirse"
   - `AppProvider.enrollInCourse(courseId)`
   - `POST /api/courses/enroll/` con `{"course_id": 1}`
   - Respuesta: Enrollment creado
   - Actualiza `AppProvider._courses` (marca como inscrito)
   - Notificación automática del backend

3. **Ver Progreso**:
   - Si está inscrito → Muestra barra de progreso
   - `progress.firstWhere((p) => p.course == courseId)`
   - Muestra: porcentaje, quizzes completados, racha

### 📝 Quizzes Screen (`QuizzesScreen`)

**Flujo:**

```
Pantalla se abre
    ↓
initState() → _loadQuizzes()
    ↓
AppProvider.loadQuizzes()
    ↓
ApiService.getAvailableQuizzes()
    ↓
GET /api/quizzes/available/
    ↓
Respuesta: Lista de quizzes disponibles
    ↓
AppProvider._quizzes se actualiza
    ↓
Consumer renderiza lista de quizzes
```

**Filtros:**
- Todos los quizzes
- Por curso: `quizzes.where((q) => q.course == courseId)`
- Disponibles: `quizzes.where((q) => q.canAttempt)`
- Completados: `quizzes.where((q) => q.isCompleted)`

**Acciones:**

1. **Ver Detalle de Quiz**:
   - Toca un quiz → Muestra `QuizDetailSheet`
   - Datos: título, descripción, dificultad, puntaje mínimo, XP, tiempo límite

2. **Comenzar Quiz**:
   - Presiona "Comenzar"
   - Navega a `/quiz-attempt` con `quiz` como argumento

### 🎯 Quiz Attempt Screen (`QuizAttemptScreen`)

**Flujo Completo:**

```
Usuario selecciona quiz
    ↓
Navigator.pushNamed('/quiz-attempt', arguments: quiz)
    ↓
QuizAttemptScreen se construye
    ↓
initState():
    ├─→ _loadQuizQuestions()
    └─→ _startTimer()
    ↓
_loadQuizQuestions():
    ├─→ provider.apiService.getQuizDetail(quiz.id)
    ├─→ GET /api/quizzes/<id>/
    └─→ Respuesta: Quiz con preguntas (SIN respuestas correctas)
    ↓
_questions se llena con QuestionModel
    ↓
Usuario responde preguntas:
    ├─→ Para multiple_choice/true_false: Selecciona opción
    └─→ Para short_answer: Escribe respuesta
    ↓
_answers[questionId] = respuesta
    ↓
Usuario presiona "Enviar"
    ↓
_submitQuiz():
    ├─→ Valida que todas las preguntas estén respondidas
    ├─→ provider.submitQuiz(quizId, answers, timeTaken)
    ├─→ ApiService.submitQuiz(...)
    ├─→ POST /api/quizzes/submit/
    │   Body: {
    │     "quiz_id": 15,
    │     "answers": {
    │       "45": "Jamaya",
    │       "46": "Verdadero",
    │       "47": "win"
    │     },
    │     "time_taken": 245
    │   }
    └─→ Backend evalúa automáticamente
    ↓
Respuesta del Backend:
{
  "message": "Quiz completado correctamente",
  "attempt": {
    "id": 123,
    "score": 66.67,
    "passed": false,
    "answers": {
      "45": {
        "user_answer": "Jamaya",
        "correct_answer": "Jamaya",
        "is_correct": true,
        "explanation": "..."
      },
      ...
    }
  },
  "xp_gained": 0,
  "current_level": 2,
  "total_xp": 450
}
    ↓
_showResultDialog():
    ├─→ Muestra puntaje
    ├─→ Muestra si aprobó o no
    ├─→ Muestra XP ganado (si aprobó)
    ├─→ Muestra revisión detallada de respuestas
    └─→ Muestra explicaciones
    ↓
Si aprobó:
    ├─→ Backend otorga XP automáticamente
    ├─→ Backend actualiza progreso del curso
    ├─→ Backend envía notificación
    └─→ AppProvider actualiza user.xp
    ↓
Usuario presiona "Continuar" o "Reintentar"
    ↓
Navigator.pop() → Vuelve a quizzes
```

**Efectos Secundarios del Backend (si aprobó):**
1. Otorga XP: `user.add_xp(quiz.xp_reward, source="quiz")`
2. Actualiza progreso: `Progress.update_user_progress_for_course()`
3. Notificación: Crea notificación de "Quiz aprobado"
4. Si completa todos los quizzes: Marca curso como completado

### ➕ Create Quiz Screen (`CreateQuizScreen`)

**Flujo:**

```
Moderador/Admin navega a /create-quiz
    ↓
Pantalla se construye
    ↓
initState() → loadCourses() (para selector)
    ↓
Usuario completa formulario:
    ├─→ Selecciona curso
    ├─→ Título
    ├─→ Descripción
    ├─→ Dificultad
    ├─→ Puntaje mínimo
    ├─→ XP recompensa
    ├─→ Tiempo límite
    ├─→ Intentos máximos
    └─→ Agrega preguntas:
        ├─→ Tipo (multiple_choice/true_false/short_answer)
        ├─→ Texto de pregunta
        ├─→ Opciones (si aplica)
        ├─→ Respuesta correcta
        └─→ Explicación (opcional)
    ↓
Presiona "Crear Quiz"
    ↓
_createQuiz():
    ├─→ Valida formulario
    ├─→ Valida que haya al menos una pregunta
    ├─→ Valida opciones y respuestas
    ├─→ provider.apiService.createQuiz(...)
    ├─→ POST /api/quizzes/create/
    │   Body: {
    │     "title": "Saludos en Wayuunaiki",
    │     "description": "...",
    │     "course": 1,
    │     "difficulty": "easy",
    │     "passing_score": 70.0,
    │     "xp_reward": 50,
    │     "time_limit": 10,
    │     "max_attempts": 3,
    │     "questions": [
    │       {
    │         "text": "¿Cómo se dice 'Hola'?",
    │         "question_type": "multiple_choice",
    │         "options": ["Jamaya", "Pütchi", "Anaa"],
    │         "correct_answer": "Jamaya",
    │         "explanation": "...",
    │         "order": 1
    │       },
    │       ...
    │     ]
    │   }
    └─→ Backend crea quiz y preguntas
    ↓
Respuesta:
{
  "message": "Quiz creado exitosamente",
  "quiz": { ... }
}
    ↓
Efectos Secundarios del Backend:
    ├─→ Crea quiz en base de datos
    ├─→ Crea preguntas asociadas
    ├─→ Notifica a usuarios inscritos en el curso
    └─→ Envía notificaciones WebSocket
    ↓
Navigator.pop() → Vuelve a home
    ↓
AppProvider.loadQuizzes() → Actualiza lista
```

### ➕ Create Course Screen (`CreateCourseScreen`)

**Flujo Similar:**

```
Moderador/Admin navega a /create-course
    ↓
Completa formulario:
    ├─→ Título
    ├─→ Descripción
    ├─→ Dificultad (opcional)
    └─→ Nivel requerido (opcional)
    ↓
Presiona "Crear Curso"
    ↓
provider.createCourse(title, description, ...)
    ↓
POST /api/courses/create/
    ↓
Backend crea curso
    ↓
Navigator.pop()
    ↓
AppProvider.loadCourses() → Actualiza lista
```

### 👤 Profile Screen (`ProfileScreen`)

**Flujo:**

```
Usuario navega a /profile
    ↓
initState() → loadUserData()
    ↓
AppProvider.loadUserData()
    ↓
GET /api/auth/profile/
    ↓
Respuesta: Datos completos del usuario
    ↓
AppProvider._user se actualiza
    ↓
Consumer renderiza:
    ├─→ Header con avatar, nombre, nivel, rol
    ├─→ Barra de progreso XP (si es usuario)
    ├─→ Información de contacto (email, teléfono, localidad)
    ├─→ Intereses (gustos)
    └─→ Estadísticas:
        ├─→ Cursos completados
        ├─→ Quizzes completados
        ├─→ XP total
        └─→ Racha actual
```

**Editar Perfil:**

```
Presiona botón de editar
    ↓
Navigator.pushNamed('/edit-profile')
    ↓
EditProfileScreen se construye
    ↓
Carga datos actuales en formulario
    ↓
Usuario edita:
    ├─→ Teléfono
    ├─→ Localidad
    └─→ Intereses (checkboxes)
    ↓
Presiona "Guardar"
    ↓
provider.updateProfile(telefono, localidad, gustos)
    ↓
PATCH /api/auth/profile/
    ↓
Backend actualiza perfil
    ↓
AppProvider._user se actualiza
    ↓
Navigator.pop()
    ↓
ProfileScreen se actualiza automáticamente
```

### 📊 Progress Screen (`ProgressScreen`)

**Flujo:**

```
Usuario navega a /progress
    ↓
initState() → _loadProgress()
    ↓
AppProvider.loadProgress()
    ↓
GET /api/progress/
    ↓
Respuesta: Lista de progreso por curso
    ↓
Consumer renderiza:
    ├─→ Progreso Global:
    │   ├─→ Total de cursos inscritos
    │   ├─→ Total de cursos completados
    │   ├─→ Total de quizzes completados
    │   ├─→ XP total
    │   └─→ Racha actual y más larga
    │
    └─→ Progreso por Curso:
        ├─→ Título del curso
        ├─→ Porcentaje de progreso
        ├─→ Quizzes completados / total
        ├─→ Última actualización
        └─→ Fecha de completado (si aplica)
```

### 🔔 Notifications Screen (`NotificationsScreen`)

**Flujo:**

```
Usuario navega a /notifications
    ↓
initState() → _loadNotifications()
    ↓
AppProvider.loadNotifications()
    ↓
GET /api/notifications/
    ↓
Respuesta: Lista de notificaciones
    ↓
Consumer renderiza lista
    ↓
Usuario toca notificación:
    ├─→ Si no está leída → markNotificationAsRead(id)
    ├─→ POST /api/notifications/mark-read/ con [id]
    └─→ Navega según tipo:
        ├─→ new_quiz → /quizzes
        ├─→ course_completed → /progress
        ├─→ level_up → /profile
        └─→ Otros → /home
```

**Marcar Todas como Leídas:**

```
Presiona "Marcar todas como leídas"
    ↓
provider.markAllNotificationsAsRead()
    ↓
POST /api/notifications/mark-all-read/
    ↓
Backend marca todas como leídas
    ↓
AppProvider._notifications se actualiza
    ↓
Contador de no leídas se resetea
```

### 🏆 Leaderboard Screen (`LeaderboardScreen`)

**Flujo:**

```
Usuario navega a /leaderboard
    ↓
initState() → _loadLeaderboard()
    ↓
AppProvider.loadLeaderboard()
    ↓
ApiService.getLeaderboard()
    ↓
GET /api/stats/leaderboard/
    ↓
Respuesta: Lista de usuarios ordenados por métrica
    ↓
Consumer renderiza tabla de clasificación
    ↓
Muestra:
    ├─→ Posición
    ├─→ Avatar
    ├─→ Nombre
    ├─→ Nivel
    ├─→ XP total
    └─→ Badge si es el usuario actual
```

---

## 6. Flujos Específicos

### 🎓 Flujo Completo: Crear Curso → Crear Quiz → Usuario Responde

```
1. MODERADOR CREA CURSO
   Moderador → /create-course
   ├─→ Completa formulario
   ├─→ POST /api/courses/create/
   └─→ Curso creado en backend

2. MODERADOR CREA QUIZ
   Moderador → /create-quiz
   ├─→ Selecciona curso
   ├─→ Completa información del quiz
   ├─→ Agrega preguntas
   ├─→ POST /api/quizzes/create/
   └─→ Quiz creado en backend
       └─→ Backend notifica a usuarios inscritos

3. USUARIO VE NOTIFICACIÓN
   Usuario → /notifications
   ├─→ Ve notificación "Nuevo quiz disponible"
   └─→ Toca notificación → Navega a /quizzes

4. USUARIO ABRE QUIZ
   Usuario → /quizzes
   ├─→ Ve quiz nuevo
   ├─→ Toca quiz → Ve detalle
   └─→ Presiona "Comenzar"

5. USUARIO RESPONDE QUIZ
   Usuario → /quiz-attempt
   ├─→ GET /api/quizzes/<id>/ (obtiene preguntas)
   ├─→ Responde todas las preguntas
   ├─→ POST /api/quizzes/submit/
   └─→ Backend evalúa:
       ├─→ Calcula score
       ├─→ Si aprobó:
       │   ├─→ Otorga XP
       │   ├─→ Actualiza progreso
       │   └─→ Envía notificación
       └─→ Responde con resultados detallados

6. USUARIO VE RESULTADOS
   QuizAttemptScreen muestra:
   ├─→ Puntaje obtenido
   ├─→ Si aprobó o no
   ├─→ XP ganado (si aprobó)
   └─→ Revisión detallada:
       ├─→ Pregunta
       ├─→ Tu respuesta
       ├─→ Respuesta correcta (si falló)
       └─→ Explicación

7. ACTUALIZACIÓN AUTOMÁTICA
   Backend actualiza:
   ├─→ Progreso del curso
   ├─→ XP del usuario
   ├─→ Nivel (si corresponde)
   └─→ Notificaciones
```

### 🔄 Flujo de Sincronización de Datos

```
Usuario hace pull-to-refresh en cualquier pantalla
    ↓
_refresh() o equivalente
    ↓
AppProvider recarga datos:
    ├─→ loadUserData() → GET /api/auth/profile/
    ├─→ loadCourses() → GET /api/courses/available/
    ├─→ loadQuizzes() → GET /api/quizzes/available/
    ├─→ loadProgress() → GET /api/progress/
    └─→ loadNotifications() → GET /api/notifications/recent/
    ↓
Todos los datos se actualizan en paralelo
    ↓
Consumer se actualiza automáticamente
    ↓
UI se refresca con datos nuevos
```

---

## 7. Arquitectura de Datos

### 🏗️ AppProvider (Estado Global)

**Ubicación:** `lib/providers/app_provider.dart`

**Estado Gestionado:**

```dart
class AppProvider extends ChangeNotifier {
  // Usuario
  UserModel? _user;
  bool _isLoading;
  String? _error;
  
  // Datos
  List<CourseModel> _courses;
  List<QuizModel> _quizzes;
  List<ProgressModel> _progress;
  List<NotificationModel> _notifications;
  List<QuizAttemptModel> _quizAttempts;
  int _unreadNotificationsCount;
}
```

**Métodos Principales:**

1. **Autenticación:**
   - `login(email, password)`
   - `register(...)`
   - `logout()`
   - `initializeApp()`

2. **Carga de Datos:**
   - `loadUserData()`
   - `loadCourses()`
   - `loadQuizzes()`
   - `loadProgress()`
   - `loadNotifications()`

3. **Acciones:**
   - `enrollInCourse(courseId)`
   - `submitQuiz(quizId, answers, timeTaken)`
   - `createCourse(title, description, ...)`
   - `createQuiz(...)`
   - `updateProfile(...)`
   - `markNotificationAsRead(id)`

### 🔌 ApiService (Capa de Red)

**Ubicación:** `lib/services/api_service.dart`

**Responsabilidades:**
- Gestión de tokens (guardar, leer, refrescar)
- Comunicación HTTP con el backend
- Manejo de errores y reintentos
- Transformación de respuestas

**Métodos Principales:**

```dart
class ApiService {
  // Autenticación
  Future<Map<String, dynamic>> login({email, password})
  Future<Map<String, dynamic>> register({...})
  Future<Map<String, dynamic>> getProfile()
  Future<Map<String, dynamic>> updateProfile({...})
  
  // Cursos
  Future<List<dynamic>> getAvailableCourses()
  Future<Map<String, dynamic>> createCourse({...})
  Future<bool> enrollInCourse(int courseId)
  
  // Quizzes
  Future<List<dynamic>> getAvailableQuizzes()
  Future<Map<String, dynamic>> getQuizDetail(int quizId)
  Future<Map<String, dynamic>> createQuiz({...})
  Future<Map<String, dynamic>> submitQuiz({...})
  
  // Progreso
  Future<List<dynamic>> getProgress()
  Future<List<dynamic>> getLeaderboard()
  
  // Notificaciones
  Future<List<dynamic>> getNotifications()
  Future<bool> markNotificationAsRead(int id)
}
```

### 📦 Modelos de Datos

**Ubicación:** `lib/models/`

**Modelos Principales:**

1. **UserModel** (`user_model.dart`):
   - id, email, firstName, lastName
   - role, level, xp
   - profile (telefono, localidad, gustos, avatar)

2. **CourseModel** (`course_model.dart`):
   - id, title, description
   - levelRequired, difficulty
   - enrolledStudentsCount, completedStudentsCount
   - isEnrolled, userProgress

3. **QuizModel** (`quiz_model.dart`):
   - id, title, description
   - course, courseTitle
   - difficulty, passingScore, xpReward
   - timeLimit, maxAttempts
   - questionCount, userAttempts, canAttempt, bestScore
   - questions (List<QuestionModel>)

4. **ProgressModel** (`progress_model.dart`):
   - course, courseTitle
   - percentage, completedQuizzes, totalQuizzes
   - courseCompleted, completedAt, updatedAt

5. **NotificationModel** (`notification_model.dart`):
   - id, type, title, message
   - isRead, createdAt
   - relatedCourseId, relatedQuizId

### 🔄 Flujo de Datos General

```
UI (Widget)
    ↓
Consumer<AppProvider>
    ↓
AppProvider (Estado)
    ↓
ApiService (Red)
    ↓
HTTP Request
    ↓
Backend API
    ↓
HTTP Response
    ↓
ApiService (Transforma)
    ↓
AppProvider (Actualiza estado)
    ↓
notifyListeners()
    ↓
Consumer (Re-renderiza)
    ↓
UI (Actualizada)
```

### 💾 Almacenamiento Local

**SharedPreferences (Persistencia):**

```dart
// Tokens
access_token: String (JWT)
refresh_token: String (JWT)

// Datos de usuario
userData: String (JSON)
```

**Memoria (Estado Temporal):**
- Todos los datos en `AppProvider` se mantienen en memoria
- Se recargan al reiniciar la app o hacer refresh

---

## 📝 Notas Importantes

### 🔐 Seguridad
- Los tokens se guardan en `SharedPreferences` (no es el más seguro, pero funcional)
- Cada request autenticado incluye: `Authorization: Bearer <access_token>`
- Si el token expira, se refresca automáticamente

### 🔄 Sincronización
- Los datos se cargan al iniciar la app
- Se pueden refrescar manualmente (pull-to-refresh)
- No hay sincronización automática en background (pendiente)

### 🌐 Conectividad
- La app requiere conexión a internet para funcionar
- No hay modo offline implementado (pendiente)
- Los errores de red se muestran con SnackBars

### 📱 Notificaciones
- Las notificaciones se cargan desde el backend
- No hay WebSocket implementado en Flutter (pendiente)
- Las notificaciones push requieren configuración adicional

---

## 🎯 Resumen Ejecutivo

**Flujo Principal:**
1. App inicia → SplashScreen
2. Verifica autenticación → Home o Welcome
3. Usuario navega por la app
4. Cada pantalla carga sus datos desde AppProvider
5. AppProvider obtiene datos de ApiService
6. ApiService hace requests HTTP al backend
7. Backend responde con datos
8. Datos fluyen de vuelta a la UI
9. UI se actualiza automáticamente

**Arquitectura:**
- **UI**: Widgets Flutter (pantallas)
- **Estado**: AppProvider (Provider pattern)
- **Red**: ApiService (HTTP client)
- **Backend**: Django REST Framework
- **Persistencia**: SharedPreferences

**Principios:**
- Separación de responsabilidades
- Estado centralizado (AppProvider)
- Reactividad (Consumer + notifyListeners)
- Reutilización de código
- Manejo de errores consistente

---

**Fin de la Guía** 🎉

Para más detalles sobre una pantalla específica, consulta el código fuente en `lib/screens/`.

