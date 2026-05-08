# 📦 Estructura Completa del Proyecto Tweeter

```
twteer/
│
├── 📄 README.md                              # 📖 Documentación principal completa
├── 📄 QUICK_START.txt                        # ⚡ Guía rápida de configuración
├── 📄 API_TESTING.md                         # 🧪 Ejemplos de prueba de API
├── 📄 DEVELOPMENT.md                         # 🛠️ Guía de desarrollo local
├── 📄 deploy.sh                              # 🚀 Script automatizado de deploy
│
├── 📁 tweeter-api/                           # ⚙️ BACKEND (Spring Boot)
│   │
│   ├── 📄 pom.xml                            # Maven configuration
│   │   └── Dependencies:
│   │       - spring-boot-starter-web (REST)
│   │       - spring-boot-starter-data-jpa (Hibernate)
│   │       - postgresql (Driver)
│   │       - spring-boot-starter-validation (@NotBlank, @Size)
│   │
│   ├── 📄 Dockerfile                         # Multi-stage build (Maven → JDK25)
│   ├── 📄 .gitignore                         # Git ignore rules
│   │
│   └── 📁 src/
│       │
│       ├── 📁 main/
│       │   │
│       │   ├── 📁 java/com/tweeter/
│       │   │   │
│       │   │   ├── 📄 TweeterApiApplication.java     # Spring Boot main class
│       │   │   │   └── @SpringBootApplication
│       │   │   │   └── Inicia servidor en puerto 8080
│       │   │   │
│       │   │   ├── 📁 models/
│       │   │   │   └── 📄 Tweet.java                  # Entidad JPA
│       │   │   │       ├── @Entity @Table(name="tweets")
│       │   │   │       ├── id: Long @GeneratedValue
│       │   │   │       ├── tweet: String @Size(max=140)
│       │   │   │       ├── createdAt: LocalDateTime
│       │   │   │       ├── updatedAt: LocalDateTime
│       │   │   │       └── @PrePersist, @PreUpdate hooks
│       │   │   │
│       │   │   ├── 📁 repositories/
│       │   │   │   └── 📄 TweetRepository.java        # Data Access Object
│       │   │   │       ├── extends JpaRepository<Tweet, Long>
│       │   │   │       ├── findAllByOrderByCreatedAtDesc(Pageable)
│       │   │   │       └── @Repository annotation
│       │   │   │
│       │   │   └── 📁 controllers/
│       │   │       └── 📄 TweetController.java        # REST Endpoints
│       │   │           ├── @RestController @RequestMapping("/api/tweets")
│       │   │           ├── @CrossOrigin(origins="*")  # Para Flutter
│       │   │           ├── GET /api/tweets?page=0&size=10
│       │   │           ├── GET /api/tweets/{id}
│       │   │           ├── POST /api/tweets (crear)
│       │   │           ├── PUT /api/tweets/{id} (actualizar)
│       │   │           ├── DELETE /api/tweets/{id}
│       │   │           └── DELETE /api/tweets (eliminar todos)
│       │   │
│       │   └── 📁 resources/
│       │       └── 📄 application.properties             # Spring Boot config
│       │           ├── spring.datasource.url (Aiven PostgreSQL)
│       │           ├── spring.datasource.username
│       │           ├── spring.datasource.password
│       │           ├── spring.jpa.hibernate.ddl-auto=update
│       │           └── logging.level config
│       │
│       └── 📁 test/
│           └── 📁 java/com/tweeter/
│               └── 📄 TweeterApiApplicationTests.java  # Test básico
│
│
├── 📁 flutter_client/                        # 📱 FRONTEND (Flutter)
│   │
│   ├── 📄 pubspec.yaml                       # Flutter & Dart config
│   │   └── Dependencies:
│   │       - flutter (SDK)
│   │       - http: ^1.1.0 (HTTP client)
│   │       - intl: ^0.19.0 (Internacionalization)
│   │
│   ├── 📄 .gitignore                         # Flutter git ignore
│   │
│   ├── 📁 lib/                               # Código fuente principal
│   │   │
│   │   ├── 📄 main.dart                      # Entry point
│   │   │   ├── void main() => runApp(TweeterApp())
│   │   │   ├── TweeterApp extends StatelessWidget
│   │   │   ├── MaterialApp configuration
│   │   │   └── Theme: Material Design 3
│   │   │
│   │   ├── 📁 models/
│   │   │   └── 📄 tweet.dart                 # Modelo de datos
│   │   │       ├── class Tweet
│   │   │       ├── Propiedades: id, tweet, createdAt, updatedAt
│   │   │       ├── factory Tweet.fromJson(Map<String, dynamic>)
│   │   │       └── Map<String, dynamic> toJson()
│   │   │
│   │   ├── 📁 services/
│   │   │   └── 📄 tweet_service.dart         # Singleton HTTP Service
│   │   │       ├── class TweetService (Singleton Pattern)
│   │   │       ├── static final _instance
│   │   │       ├── factory constructor con customBaseUrl
│   │   │       ├── getAllTweets(page, size) → Future
│   │   │       ├── getTweetById(id) → Future
│   │   │       ├── createTweet(content) → Future
│   │   │       ├── updateTweet(id, content) → Future
│   │   │       ├── deleteTweet(id) → Future
│   │   │       ├── baseUrl configuration
│   │   │       └── Error handling & timeout (10s)
│   │   │
│   │   └── 📁 screens/
│   │       └── 📄 home_screen.dart           # UI principal
│   │           ├── class HomeScreen extends StatefulWidget
│   │           ├── _HomeScreenState (State management)
│   │           ├── TweetService singleton instantiation
│   │           ├── TextEditingController para input
│   │           ├── ListView.builder para tweets
│   │           ├── Funciones:
│   │           │   ├── _loadTweets() - Cargar tweets paginados
│   │           │   ├── _createTweet() - Crear nuevo tweet
│   │           │   ├── _deleteTweet(id) - Eliminar tweet
│   │           │   └── _showMessage() - SnackBar feedback
│   │           ├── UI Components:
│   │           │   ├── AppBar (Tweeter App title)
│   │           │   ├── TextField (max 140 char con contador)
│   │           │   ├── ElevatedButton (Enviar Tweet)
│   │           │   ├── Card (Tweet items)
│   │           │   ├── PopupMenuButton (Delete option)
│   │           │   └── FloatingActionButton (Refresh)
│   │           └── Error display & Loading states
│   │
│   └── 📁 android/
│       └── 📁 app/
│           ├── 📄 AndroidManifest.xml        # Android config
│           │   ├── <uses-permission android:name="android.permission.INTERNET" />
│           │   ├── MainActivity declaration
│           │   └── App metadata
│           │
│           └── 📄 MainActivity.java          # Android entry point
│               ├── extends FlutterActivity
│               └── configureFlutterEngine()

```

---

## 🌐 Arquitectura General

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE FLUTTER                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │ HomeScreen (UI)                                  │   │
│  │ - ListView de Tweets                             │   │
│  │ - TextField para crear tweet (max 140 char)      │   │
│  │ - Botones: Enviar, Eliminar, Refresh            │   │
│  └──────────────────────────────────────────────────┘   │
│               ↓                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │ TweetService (Singleton)                         │   │
│  │ - HTTP calls a Backend                           │   │
│  │ - Manejo de errores y timeouts                   │   │
│  │ - Único cliente HTTP para toda la app            │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────┐
│                  BACKEND (Spring Boot)                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │ TweetController (/api/tweets)                    │   │
│  │ - GET /tweets (paginado)                         │   │
│  │ - GET /tweets/{id}                               │   │
│  │ - POST /tweets (crear)                           │   │
│  │ - PUT /tweets/{id} (actualizar)                  │   │
│  │ - DELETE /tweets/{id}                            │   │
│  │ - CORS enabled (*) para Flutter                  │   │
│  └──────────────────────────────────────────────────┘   │
│               ↓                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │ TweetRepository (JPA)                            │   │
│  │ - findAllByOrderByCreatedAtDesc(Pageable)        │   │
│  │ - save(Tweet)                                    │   │
│  │ - findById(id)                                   │   │
│  │ - deleteById(id)                                 │   │
│  └──────────────────────────────────────────────────┘   │
│               ↓                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Tweet (Entity con Hibernate)                     │   │
│  │ - @Entity @Table(name="tweets")                  │   │
│  │ - @Size(max=140), @NotBlank                      │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                        ↓ SQL
┌─────────────────────────────────────────────────────────┐
│              BASE DE DATOS (PostgreSQL)                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Tabla: tweets                                    │   │
│  │ - id: BIGINT PRIMARY KEY                         │   │
│  │ - tweet: VARCHAR(140)                            │   │
│  │ - created_at: TIMESTAMP                          │   │
│  │ - updated_at: TIMESTAMP                          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Host: Aiven PostgreSQL (Cloud)                        │
│  SSL: Requerido (sslmode=require)                      │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### Crear Tweet (POST)
```
Usuario escribe tweet (UI TextField)
    ↓
Valida: no vacío, máx 140 caracteres (Flutter)
    ↓
TweetService.createTweet(content)
    ↓
POST /api/tweets
    ↓
TweetController.createTweet(@Valid @RequestBody Tweet)
    ↓
Valida: @NotBlank, @Size(max=140) (Spring)
    ↓
TweetRepository.save(tweet)
    ↓
Hibernate ejecuta INSERT SQL → PostgreSQL
    ↓
Tweet guardado con id, timestamps
    ↓
Respuesta 201 + Tweet JSON
    ↓
Flutter procesa respuesta
    ↓
ListView se actualiza automáticamente
    ↓
Usuario ve su tweet en la lista
```

### Cargar Tweets (GET)
```
HomeScreen.initState() → _loadTweets()
    ↓
TweetService.getAllTweets(page: 0, size: 10)
    ↓
GET /api/tweets?page=0&size=10
    ↓
TweetController.getAllTweets(int page, int size)
    ↓
TweetRepository.findAllByOrderByCreatedAtDesc(Pageable)
    ↓
Hibernate ejecuta SELECT... ORDER BY created_at DESC
    ↓
PostgreSQL retorna Page<Tweet>
    ↓
Usuario puede paginar (próxima página, anterior, etc.)
    ↓
Respuesta 200 + Page JSON
    ↓
Flutter mapea a List<Tweet>
    ↓
setState() redibuja ListView
    ↓
Usuario ve tweets ordenados por fecha (más recientes primero)
```

---

## 📊 Estado de Componentes

### Tweet
```
{
  "id": 1,                         # Auto-generado por DB
  "tweet": "Mi primer tweet!",     # Máx 140 caracteres
  "createdAt": "2024-05-07T...",  # Auto-asignado
  "updatedAt": "2024-05-07T..."   # Auto-actualizado
}
```

### Page<Tweet> (Paginación)
```
{
  "content": [Tweet, Tweet, ...],  # Array de tweets
  "totalElements": 100,             # Total de tweets
  "totalPages": 10,                 # Con size=10
  "number": 0,                      # Página actual (0-indexed)
  "first": true,                    # ¿Es primera página?
  "last": false                     # ¿Es última página?
}
```

---

## 🔐 Validaciones

### Frontend (Flutter)
- ✅ Campo no vacío
- ✅ Máximo 140 caracteres
- ✅ Validación en tiempo real (contador)

### Backend (Spring Boot)
- ✅ @NotBlank: No permite null/vacío
- ✅ @Size(max=140): Máximo 140 caracteres
- ✅ Retorna 400 Bad Request si falla

---

## 🚀 Deployment

### Etapas
1. **Maven Build** → JAR (Spring Boot)
2. **Docker Build** → Image (Multi-stage)
3. **Docker Push** → Docker Hub
4. **Render Deploy** → Servidor en la nube

### URL Pública Final
```
https://tweeter-api-xxxxx.render.com
```
Reemplazar en Flutter:
```dart
customBaseUrl: 'https://tweeter-api-xxxxx.render.com/api'
```

---

## 📝 Archivos Generados

| Archivo | Propósito |
|---------|-----------|
| `pom.xml` | Configuración Maven (dependencias) |
| `application.properties` | Spring Boot config (DB, logging) |
| `TweeterApiApplication.java` | Main class |
| `Tweet.java` | Entity (modelo) |
| `TweetRepository.java` | DAO (acceso a datos) |
| `TweetController.java` | REST endpoints |
| `Dockerfile` | Construcción de imagen |
| `pubspec.yaml` | Flutter dependencies |
| `main.dart` | App entry point |
| `tweet_service.dart` | Singleton HTTP service |
| `home_screen.dart` | UI principal |
| `AndroidManifest.xml` | Permisos Android |

---

## ✅ Checklist de Features

- [x] Crear entidad Tweet con validaciones
- [x] Repositorio JPA para CRUD
- [x] API REST con 5 endpoints
- [x] CORS habilitado para Flutter
- [x] Paginación de tweets
- [x] Timestamps automáticos (createdAt, updatedAt)
- [x] Dockerización con multi-stage build
- [x] Flutter Singleton service pattern
- [x] UI con ListView.builder
- [x] Crear, leer, actualizar, eliminar tweets
- [x] Contador de caracteres (max 140)
- [x] Manejo de errores y loading states
- [x] Permisos de internet Android
- [x] Documentación completa

---

¡Proyecto Tweeter completamente generado y listo! 🎉
