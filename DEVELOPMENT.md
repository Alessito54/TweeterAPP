# 🛠️ Guía de Desarrollo Local

## Requisitos del Sistema

### Hardware
- RAM: Mínimo 4GB (8GB recomendado)
- Espacio disco: 5GB libre
- CPU: Cualquier procesador moderno

### Software
- **Java 25** o superior
  ```bash
  java -version
  # openjdk version "25" 2024-09-17
  ```

- **Maven 3.9+**
  ```bash
  mvn -v
  # Apache Maven 3.9.x
  ```

- **Docker**
  ```bash
  docker --version
  # Docker version 20.10+
  ```

- **Flutter 3.0+**
  ```bash
  flutter --version
  # Flutter 3.x.x
  ```

- **Git** (opcional pero recomendado)

---

## Instalación en Linux/WSL

### 1. Java 25 (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install openjdk-25-jdk
```

### 2. Maven
```bash
sudo apt install maven
# o descargar desde https://maven.apache.org/download.cgi
```

### 3. Docker
```bash
sudo apt install docker.io
sudo usermod -aG docker $USER
```

### 4. Flutter
```bash
# Descargar desde https://flutter.dev/docs/get-started/install/linux
unzip flutter_linux_*.zip
export PATH="$PATH:~/flutter/bin"
flutter doctor
```

---

## Configuración de Base de Datos Local (Opcional)

Si quieres desarrollar **sin Aiven**, puedes usar PostgreSQL local:

### Instalación
```bash
# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib

# macOS
brew install postgresql

# Iniciar servicio
sudo service postgresql start
```

### Crear Base de Datos
```bash
sudo -u postgres psql

postgres=# CREATE DATABASE tweeter_db;
postgres=# CREATE USER tweeter_user WITH PASSWORD 'password123';
postgres=# GRANT ALL PRIVILEGES ON DATABASE tweeter_db TO tweeter_user;
postgres=# \q
```

### Actualizar application.properties
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/tweeter_db
spring.datasource.username=tweeter_user
spring.datasource.password=password123
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=create-drop
```

---

## Ejecutar Backend Localmente

### 1. Terminal 1: Base de Datos
```bash
# Si usas PostgreSQL local
psql -U tweeter_user -d tweeter_db
```

### 2. Terminal 2: Backend Spring Boot
```bash
cd tweeter-api
mvn spring-boot:run
```

Debería ver:
```
2024-05-07 10:30:45.123 INFO ... Started TweeterApiApplication
Server started on port 8080
```

### 3. Probar Endpoint
```bash
curl http://localhost:8080/api/tweets
```

---

## Ejecutar Cliente Flutter Localmente

### 1. Con Emulador Android
```bash
# Iniciar emulador Android Studio
flutter emulators --launch Pixel_5

# En Flutter client
cd flutter_client
flutter pub get
flutter run
```

### 2. Con Dispositivo físico
```bash
adb devices  # Listar dispositivos
flutter run
```

### 3. Web
```bash
flutter run -d chrome
```

### 4. iOS (macOS)
```bash
open -a Simulator  # Inicia simulador iOS
flutter run -d ios
```

---

## IDE Recomendados

### Para Backend (Spring Boot)
- **IntelliJ IDEA Community Edition** (gratuito)
  - Plugin: Spring Boot Extension Pack
  
- **VS Code** + Extensions:
  - Java Extension Pack
  - Spring Boot Extension Pack

### Para Flutter
- **Android Studio** (con Flutter Plugin)
- **VS Code** + Extensions:
  - Flutter
  - Dart
  - Android Emulator

---

## Debug y Logging

### Backend
Editar `application.properties`:
```properties
logging.level.root=DEBUG
logging.level.com.tweeter=DEBUG
logging.level.org.hibernate.SQL=DEBUG
```

### Flutter
```bash
flutter run -v  # Verbose mode
flutter logs    # Ver logs en tiempo real

# Analytics (optional)
flutter config --enable-analytics
```

---

## Estructura de Carpetas del Proyecto

```
twteer/
├── tweeter-api/                              # Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/tweeter/
│   │   │   │   ├── TweeterApiApplication.java       # Main app
│   │   │   │   ├── controllers/
│   │   │   │   │   └── TweetController.java         # Endpoints REST
│   │   │   │   ├── services/
│   │   │   │   │   └── TweetService.java            # Business logic
│   │   │   │   ├── repositories/
│   │   │   │   │   └── TweetRepository.java         # Data access
│   │   │   │   └── models/
│   │   │   │       └── Tweet.java                   # Entity
│   │   │   └── resources/
│   │   │       └── application.properties           # Configuration
│   │   └── test/
│   │       └── TweeterApiApplicationTests.java
│   ├── pom.xml                                      # Maven config
│   └── Dockerfile                                   # Container config
│
├── flutter_client/                           # Frontend
│   ├── lib/
│   │   ├── main.dart                              # Punto de entrada
│   │   ├── models/
│   │   │   └── tweet.dart                         # Modelo Tweet
│   │   ├── screensservices/
│   │   │   └── tweet_service.dart                 # Singleton HTTP
│   │   └── screens/
│   │       └── home_screen.dart                   # Interfaz principal
│   ├── android/
│   │   └── app/
│   │       ├── AndroidManifest.xml                # Permisos Android
│   │       └── MainActivity.java
│   └── pubspec.yaml                               # Dependencies
│
├── README.md                                 # Documentación principal
├── QUICK_START.txt                          # Guía rápida
├── API_TESTING.md                           # Ejemplos de API
├── DEVELOPMENT.md                           # Este archivo
└── deploy.sh                                # Script de deploy
```

---

## Variables de Ambiente

### Backend (.env)
```env
# Database (Aiven)
SPRING_DATASOURCE_URL=jdbc:postgresql://...
SPRING_DATASOURCE_USERNAME=avnadmin
SPRING_DATASOURCE_PASSWORD=xxx

# Server
SERVER_PORT=8080
```

### Flutter
En `lib/screens/home_screen.dart`:
```dart
// Desarrollo
final service = TweetService(
  customBaseUrl: 'http://10.0.2.2:8080/api',
);

// Producción
final service = TweetService(
  customBaseUrl: 'https://tweeter-api-xxx.render.com/api',
);
```

---

## Testing

### Backend Tests
```bash
cd tweeter-api
mvn test

# Test específico
mvn test -Dtest=TweetControllerTest

# Con cobertura
mvn clean test jacoco:report
```

### Frontend Tests
```bash
cd flutter_client
flutter test

# Con cobertura
flutter test --coverage
```

---

## Hot Reload / Hot Restart

### Spring Boot DevTools
```bash
# Auto-recompila cambios en Java
mvn spring-boot:run
```

Edita cualquier archivo y guarda → Automáticamente recarga

### Flutter Hot Reload
```bash
flutter run

# Presiona 'r' en terminal para hot reload
# Presiona 'R' para hot restart
# Presiona 'q' para quit
```

---

## Troubleshooting

### Error: "Port 8080 already in use"
```bash
# Buscar proceso usando puerto
lsof -i :8080

# Matar proceso
kill -9 <PID>
```

### Error: "Unable to connect to database"
```bash
# Verificar conexión PostgreSQL
psql -h localhost -U tweeter_user -d tweeter_db -c "SELECT 1"
```

### Flutter: "CocoaPods dependency error" (macOS)
```bash
cd flutter_client/ios
rm Podfile.lock
pod install
cd ../..
flutter run
```

### Android Emulator lento
```bash
# Usar HAXM (Hardware Acceleration)
# En Android Studio: Settings > System Settings > Android SDK > SDK Manager
# Tools > Emulator > Files > Check "Enable hardware acceleration"
```

---

## IDE Configuration

### IntelliJ IDEA
1. Open "tweeter-api" as Maven project
2. Configure JDK: File > Project Structure > Project
   - Set JDK 25
3. Run > Edit Configuration
   - Add "Maven" configuration
   - Command: `spring-boot:run`

### VS Code
1. Instalar extension "Spring Boot Extension Pack"
2. Command palette: "Java: Create Java Project"
3. Auto-detecta `pom.xml`
4. F5 para Debug

### Android Studio (Flutter)
1. File > Open > "flutter_client"
2. Android Studio auto-configura Flutter plugin
3. Click ▶️ (Run) o presiona Shift+F10 (Android)

---

## Debugging

### Backend
```bash
# Con breakpoints en VS Code
# Debug > Add Configuration > Select "Java" > "Spring Boot App"
# F5 para start debugging
```

### Frontend
```bash
flutter run
# Click en Dart DevTools (URL que aparece en terminal)
# Inspeccionar widgets, timeline, memory, etc.
```

---

## Checklist de Desarrollo

- [ ] JDK 25 instalado y verificado
- [ ] Maven compilar sin errores
- [ ] PostgreSQL local configurado (opcional)
- [ ] Backend corre en `localhost:8080`
- [ ] Flutter pub get sin issues
- [ ] Emulador Android inicia
- [ ] Hot reload funciona
- [ ] Cambios en database reflejados sin restart

---

## Recursos Útiles

- **Spring Boot Docs**: https://spring.io/projects/spring-boot
- **Spring Data JPA**: https://spring.io/projects/spring-data-jpa
- **Flutter Docs**: https://flutter.dev/docs
- **PostgreSQL Guide**: https://www.postgresql.org/docs/
- **Docker Reference**: https://docs.docker.com/
- **Render Docs**: https://render.com/docs

---

¡Listo para desarrollar! Happy coding! 🎉
