# 📱 Yonna App - Aplicación Móvil Educativa en Flutter

Aplicación móvil educativa y gamificada para el aprendizaje y preservación del idioma y cultura **Wayuunaiki**, desarrollada en **Flutter**. Forma parte integral del ecosistema **Yonna Akademia** junto con el backend Django REST Framework y la plataforma web React.

---

## 🎯 Visión y Experiencia de Usuario

**Yonna App** adopta una metodología de aprendizaje inmersivo inspirada en el bucle de retención (*Gamification Retention Loop*) de plataformas de alto impacto como Duolingo:

- **🎮 Bucle de Retención Gamificado**: Racha diaria de estudio, congeladores de racha (*streak freeze tokens*), acumulación de Puntos de Experiencia (XP), niveles crecientes e insignias coleccionables.
- **🗺️ Ruta de Aprendizaje Progresiva Estricta**: Árbol de lecciones interconectadas por niveles. Cada nivel requiere superar el anterior para desbloquearse, asegurando un aprendizaje estructurado y continuo.
- **🧊 Interfaz Glassmorphism de Alto Contraste**: Superficies translúcidas de vidrio esmerilado (*frosted glass*), orbes de luz ambiental desenfocados (*ambient blurred glow*) y bordes iridiscentes.
- **🌓 Soporte Dual de Temas (Claro / Oscuro / Sistema)**: Selector de tema en vivo totalmente integrado con contrastes cuidados y legibilidad optimizada bajo ambas modalidades.
- **✨ Cero Emojis - 100% Iconos Vectoriales Nativos**: Toda la iconografía se apoya en componentes de alta fidelidad vectoriales de **Google Material 3** y **Apple Cupertino** mediante el catálogo unificado `AppIcons`.
- **📊 Analítica y Gráficos Nativos**: Integración de **Syncfusion Flutter Charts** para visualizar tendencias de XP semanales y distribución de niveles de usuarios.
- **🗣️ Vocabulario con Repaso Espaciado (SRS)**: Tarjetas interactivas de estudio (Flashcards) con pronunciación nativa y sistema de repetición espaciada.
- **🎵 Multimedia y Cultura Wayuu**: Cánticos *Jayeechi*, toques de tambor *Kaasha* e historias de clanes ancestrales (*Apüshii*).

---

## 🏗️ Arquitectura General del Ecosistema

```
┌─────────────────────────────────┐
│     Frontend Web (React)        │  Portal cultural, difusión y landing
└────────────────┬────────────────┘
                 │
                 ├──────────────────────────────┐
                 │                              │
┌────────────────▼────────────────┐  ┌──────────▼───────────────────────┐
│   Backend API (Django REST)     │  │      Yonna App (Flutter)         │
│                                 │  │                                  │
│  - Autenticación JWT            │  │  - Experiencia Glassmorphism     │
│  - Cursos & Lecciones           │  │  - HUD Gamificado (Fuego/XP)     │
│  - Quizzes & Preguntas          │  │  - Árbol de Ruta Progresiva      │
│  - Gamificación & Rachas        │  │  - Repaso Espaciado (SRS)        │
│  - Vocabulario & Categorías     │  │  - Podio / Leaderboard en vivo   │
│  - Multimedia Cultural          │  │  - Gráficos Syncfusion           │
│  - Notificaciones & Stats       │  │  - Dual Theme (Claro / Oscuro)   │
└─────────────────────────────────┘  └──────────────────────────────────┘
```

---

## ✨ Módulos y Funcionalidades Principales

### 1. 🗺️ Ruta de Aprendizaje Gamificada (`LearningPathScreen`)
- Árbol de progresión secuencial con nodos circulares flotantes unidos por conectores visuales.
- Estados de nodos claramente diferenciados: **Completado** (con estrella dorada), **Activo / En curso** (con pulso brillante) y **Bloqueado** (con candado e indicador de nivel requerido).
- Al pulsar un nodo activo se despliega un modal de vidrio (`GlassSheet`) con los detalles del curso y acceso directo al quiz correspondiente.

### 2. ⚡ HUD Superior de Gamificación (`GlassHudBar`)
Barra flotante de vidrio accesible desde las pantallas clave que muestra:
- 🔥 **Racha actual (Streak)** con contador de días en naranja fuego.
- ❄️ **Fichas de congelamiento (Freeze Tokens)** para proteger la racha en azul glacial.
- ⚡ **Puntos de Experiencia (XP)** acumulados con indicador ámbar.
- 📈 **Nivel del usuario** con insignia dinámica.

### 3. 📝 Evaluaciones Interactivas (`GlassQuizLessonScreen`)
- Experiencia de evaluación inmersiva con barra de progreso superior de vidrio.
- Preguntas de opción múltiple, selección interactiva y retroalimentación inmediata.
- Ventana inferior de resultados con sonidos hápticos, cálculo de puntaje, otorgamiento de XP y avance curricular en la base de datos.

### 4. 📇 Vocabulario & Motor de Tarjetas SRS 3D (`VocabularyScreen`)
- **Modo Dual Integrado**: Alternancia fluida entre práctica intensiva de **Tarjetas SRS** y consulta rápida del **Diccionario**.
- **Tarjeta Central 3D Flip**: Efecto de perspectiva y rotación tridimensional en vidrio esmerilado con pronunciación bilingüe mediante botón nativo de audio `NativeAudioButton` en anverso y reverso.
- **Botones Ergonómicos de Autoevaluación SRS**: Opciones flotantes `Difícil` (1), `Bien` (2) y `Fácil` (3) que alimentan el algoritmo de repetición espaciada y programan los repasos.
- **Hoja Deslizante de Finalización (`GlassSheet`)**: Resumen de progreso al culminar la baraja sin interrumpir el flujo con cuadros de diálogo invasivos.
- "Palabra del Día" destacada en tarjeta de vidrio iridiscente con ejemplos contextuales.

### 5. 🏆 Podio y Clasificación Global (`GlassLeaderboardScreen`)
- Podio visual de los tres primeros lugares con avatares enmarcados, coronas doradas, plateadas y de bronce.
- Ranking en tiempo real con competidores activos, estadísticas de XP y resaltado de la posición del usuario actual.

### 6. 👤 Perfil y Personalización (`GlassProfileScreen`)
- Avatar del usuario con insignia de rol y nivel alcanzado.
- Vitrina de insignias y logros obtenidos (*Racha de Fuego, Maestro del Saber, Coleccionista, etc.*).
- Selector de tema de la aplicación: **Modo Claro**, **Modo Oscuro** o **Automático del Sistema**.
- Acceso directo a la configuración dinámica del servidor backend con estado de enlace en tiempo real.

### 7. 🌐 Capa de Red Inteligente y Resiliencia (`NetworkConfig` & `GlassConnectionSheet`)
- **Resolución Dinámica de Servidor**: Conmutación inmediata de host y puerto sin necesidad de recompilar la aplicación.
- **Presets Integrados**: Compatibilidad lista con túnel USB ADB (`127.0.0.1:8000`), Emulador Android (`10.0.2.2:8000`) y direcciones IP locales de red LAN.
- **Diagnóstico Asistido**: Detección inteligente de fallos de conexión (como `SocketException: Connection refused (errno 111)`) con indicaciones exactas paso a paso para el usuario.
- **Acceso Rápido**: Disponible tanto desde la pantalla de inicio de sesión/registro como desde el perfil del usuario.

### 8. 📐 Enfoque Modular del Ecosistema
Siguiendo las especificaciones arquitectónicas de `Arquitectura_Ecosistema_Yonna_Akademia.md`:
- **Aplicación Móvil (Flutter)**: Dedicada exclusivamente al consumo educativo y al bucle activo de gamificación del estudiante (Ruta de aprendizaje, Quizzes, SRS, Podio y Perfil).
- **Plataforma Web (Angular/React)**: Centraliza la gestión administrativa, analítica institucional y creación de contenidos (CMS).

---

## 🎨 Sistema de Diseño Glassmorphism

La interfaz está construida sobre una arquitectura modular de componentes translúcidos:

| Componente | Archivo | Descripción |
| :--- | :--- | :--- |
| `GlassBackground` | `lib/widgets/glass/glass_background.dart` | Fondo reactivo con gradientes suaves y orbes luminosos desenfocados. |
| `GlassCard` | `lib/widgets/glass/glass_card.dart` | Tarjetas con borde iridiscente, desenfoque gaussiano y sombras sutiles. |
| `GlassContainer` | `lib/widgets/glass/glass_container.dart` | Contenedor base con recorte de esquinas y filtro `BackdropFilter`. |
| `GlassButton` | `lib/widgets/glass/glass_button.dart` | Botones de vidrio táctiles con respuesta háptica, loaders y variantes primarias/secundarias. |
| `GlassSheet` | `lib/widgets/glass/glass_sheet.dart` | Hojas modales inferiores (*bottom sheets*) estilizadas para detalles y quizzes. |
| `GlassNavBar` | `lib/widgets/glass/glass_nav_bar.dart` | Barra de navegación inferior flotante con iconos vectoriales y píldoras activas. |
| `GlassIconBadge` | `lib/widgets/common/glass_icon_badge.dart` | Insignias circulares o redondeadas de vidrio para resaltar iconos temáticos. |
| `AppIcons` | `lib/core/constants/app_icons.dart` | Catálogo centralizado de iconos vectoriales nativos (Google Material 3 y Apple Cupertino). |

---

## 📂 Estructura del Proyecto

```
lib/
├── core/
│   └── constants/
│       └── app_icons.dart              # Catálogo unificado de iconos vectoriales
├── models/
│   ├── user_model.dart                 # Usuario, perfiles y roles
│   ├── course_model.dart               # Cursos, requisitos y duración
│   ├── quiz_model.dart                 # Quizzes, preguntas y opciones
│   ├── progress_model.dart             # Progreso de estudio del usuario
│   ├── notification_model.dart         # Notificaciones del sistema
│   ├── gamification_model.dart         # Rachas, congeladores, medallas y leaderboard
│   ├── vocabulary_model.dart           # Vocabulario, categorías y estado SRS
│   └── media_model.dart                # Recursos de audio y multimedia cultural
├── providers/
│   ├── app_provider.dart               # Estado global de la aplicación (Cursos, Quizzes, Auth)
│   └── theme_provider.dart             # Gestión reactiva de tema (Claro / Oscuro / Sistema)
├── screens/
│   ├── splash_screen.dart              # Pantalla de carga con verificación de sesión
│   ├── welcome_screen.dart             # Bienvenida con acceso rápido y cambio de tema
│   ├── login_screen.dart               # Inicio de sesión con inputs de vidrio
│   ├── register_screen.dart            # Registro con doble validación de contraseña
│   ├── shell_navigation_screen.dart    # Shell contenedor con GlassNavBar inferior
│   ├── learning_path/
│   │   └── learning_path_screen.dart   # Árbol de aprendizaje tipo Duolingo
│   ├── quiz/
│   │   └── glass_quiz_lesson_screen.dart # Experiencia interactiva de evaluación
│   ├── vocabulary/
│   │   ├── vocabulary_screen.dart      # Catálogo de vocabulario bilingüe
│   │   └── flashcard_srs_screen.dart   # Tarjetas interactivas de repaso espaciado
│   ├── leaderboard/
│   │   └── glass_leaderboard_screen.dart # Podio y tabla de clasificación global
│   ├── profile/
│   │   └── glass_profile_screen.dart   # Perfil, insignias y selector de tema
│   ├── progress_screen.dart            # Analítica con gráficos Syncfusion
│   ├── notifications_screen.dart       # Bandeja de notificaciones en tarjetas de vidrio
│   ├── courses_screen.dart             # Catálogo de cursos disponibles
│   ├── quizzes_screen.dart             # Listado de evaluaciones
│   ├── edit_profile_screen.dart        # Edición de información del estudiante
│   ├── admin_stats_screen.dart         # Dashboard estadístico de administración
│   ├── manage_users_screen.dart        # Gestión y roles de usuarios
│   ├── create_course_screen.dart       # Creador de cursos para docentes/admins
│   └── create_quiz_screen.dart         # Creador de evaluaciones interactivas
├── services/
│   └── api_service.dart                # Cliente HTTP, JWT, headers y endpoints REST
├── theme/
│   └── app_theme.dart                  # Temas Claro/Oscuro y propiedades GlassThemeData
└── widgets/
    ├── common/
    │   ├── glass_icon_badge.dart       # Insignias de iconos vectoriales
    │   └── native_audio_button.dart    # Botón reproductor de audio cultural
    ├── gamification/
    │   └── glass_hud_bar.dart          # Barra superior HUD (Fuego, XP, Hielo, Nivel)
    ├── glass/
    │   ├── glass_background.dart       # Fondo ambiental con orbes de luz
    │   ├── glass_button.dart           # Botones de vidrio interactivos
    │   ├── glass_card.dart             # Tarjetas con borde iridiscente
    │   ├── glass_container.dart        # Contenedor base de vidrio esmerilado
    │   ├── glass_nav_bar.dart          # Barra de navegación inferior flotante
    │   └── glass_sheet.dart            # Hojas modales inferiores en vidrio
    └── course_detail_sheet.dart        # Modal de detalle de curso
```

---

## 🚀 Puesta en Marcha y Pruebas

### 1. Requisitos
- **Flutter SDK**: 3.29.x o superior
- **Dart SDK**: 3.7.x o superior
- **Dispositivo Android / iOS** o emulador (probado y optimizado en **Samsung Galaxy A54 5G**).
- **Backend Django de Yonna Akademia** corriendo en `http://127.0.0.1:8000`.

### 2. Sembrado de la Base de Datos (Backend Django)
Para disponer de cursos reales, quizzes, competidores en el podio y vocabulario, ejecuta en el repositorio del backend:
```bash
cd ~/Proyectos/yonna_akademia/backend
source .venv/bin/activate
python manage.py seed_yonna_data
```
Esto creará automáticamente:
- 5 Cursos secuenciales de Wayuunaiki con niveles requeridos del 1 al 5.
- 5 Quizzes con 14 preguntas interactivas y explicaciones bilingües.
- 6 Insignias gamificadas.
- 18 Términos de vocabulario organizados en 5 categorías con ejemplos.
- 6 Estudiantes virtuales con puntajes de XP para dinamizar el Leaderboard.

### 3. Enrutamiento en Dispositivo Físico Android
Si ejecutas la aplicación en un dispositivo móvil físico conectado por cable USB:
```bash
# Redirigir el puerto del backend Django directamente al teléfono por ADB
adb reverse tcp:8000 tcp:8000
```

### 4. Ejecución de la App
```bash
# Obtener dependencias
flutter pub get

# Ejecutar pruebas automáticas
flutter test

# Compilar y correr en el dispositivo
flutter run
```

---

## 🧪 Calidad y Verificación

- **`flutter analyze`**: **0 errores**, **0 warnings**.
- **`flutter test`**: Pruebas de integración y smoke test aprobadas al 100%.
- **Escaneo de Emojis**: **0 emojis en toda la interfaz de usuario**. Toda la iconografía es puramente vectorial.
- **Compilación**: Verificada mediante `flutter build apk --debug`.

---

## 📄 Licencia

Este proyecto forma parte del ecosistema **Yonna Akademia**, enfocado en la educación, tecnología y preservación del patrimonio lingüístico Wayuu.
