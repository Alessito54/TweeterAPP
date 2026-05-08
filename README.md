# Tweeter App - Documentación Completa

## 📋 Descripción General
Aplicación de Twitter/Tweeter con arquitectura de tres capas:
- **Backend**: Spring Boot 4.0.3 con PostgreSQL (Aiven)
- **Deployment**: Docker + Render.com
- **Frontend**: Flutter (iOS/Android y Web)

---

## 🔧 PARTE 1: BACKEND (Spring Boot & PostgreSQL)

### 1.1 Requisitos Previos
- Java 25 instalado
- Maven instalado
- Cuenta en Aiven.io para PostgreSQL en la nube
- Docker instalado (para el deployment)
- Cuenta en Docker Hub
- Cuenta en Render.com

### 1.2 Configuración Base de Datos en Aiven

1. **Ir a Aiven.io** → Sign Up/Login
2. **Crear nuevo servicio PostgreSQL**:
   - Seleccionar PostgreSQL 17
   - Elegir región
   - Copiar la **Service URI** que se vería como:
     ```
     postgresql://avnadmin:contraseña@host-xxxx.a.aivencloud.com:12345/defaultdb
     ```

3. **Actualizar `application.properties`**:
   ```properties
   spring.datasource.url=jdbc:postgresql://host-xxxx.a.aivencloud.com:12345/defaultdb?sslmode=require
   spring.datasource.username=avnadmin
   spring.datasource.password=TU_CONTRASEÑA_AQUI
   spring.jpa.hibernate.ddl-auto=update
   ```

### 1.3 Compilar el Proyecto

```bash
cd tweeter-api
mvn clean package
```

Esto generará: `target/tweeter-api-0.0.1-SNAPSHOT.jar`

---

## 🐳 PARTE 2: DOCKERIZACIÓN Y DEPLOYMENT

### 2.1 Compilar Imagen Docker

```bash
cd tweeter-api
sudo docker build -t tu-usuario-dockerhub/tweeter-api:latest .
```

### 2.2 Subir a Docker Hub

```bash
sudo docker login
sudo docker push tu-usuario-dockerhub/tweeter-api:latest
```

### 2.3 Deploy en Render.com

1. **Crear cuenta en Render.com**
2. **New Web Service**
3. Seleccionar: **"Deploy from a container image"**
4. Ingresar: `tu-usuario-dockerhub/tweeter-api:latest`
5. **Environment Variables**:
   ```
   SPRING_DATASOURCE_URL=jdbc:postgresql://host-aiven:puerto/defaultdb?sslmode=require
   SPRING_DATASOURCE_USERNAME=avnadmin
   SPRING_DATASOURCE_PASSWORD=contraseña
   SPRING_JPA_HIBERNATE_DDL_AUTO=update
   ```
6. **Deploy** → Copiar URL pública (ej: `https://tweeter-api.render.com`)

---

## 📱 PARTE 3: CLIENTE FLUTTER

### 3.1 Configuración Inicial

```bash
cd flutter_client
flutter pub get
```

### 3.2 Patrón Singleton en TweetService

El archivo `lib/services/tweet_service.dart` implementa:

```dart
class TweetService {
  static final TweetService _instance = TweetService._internal();
  
  factory TweetService({String? customBaseUrl}) {
    if (customBaseUrl != null) {
      _instance.baseUrl = customBaseUrl;
    }
    return _instance;
  }
  
  TweetService._internal() {
    baseUrl = 'http://localhost:8080/api'; // Por defecto
  }
}
```

**Uso**:
```dart
// Siempre retorna la misma instancia
final service = TweetService(customBaseUrl: 'https://tweeter-api.render.com/api');
```

### 3.3 Configuración de API URL

**En desarrollo (emulador Android)**:
```dart
final service = TweetService(
  customBaseUrl: 'http://10.0.2.2:8080/api',
);
```

**En producción (Render)**:
```dart
final service = TweetService(
  customBaseUrl: 'https://tu-app-name.render.com/api',
);
```

### 3.4 Estructura del Proyecto Flutter

```
lib/
├── main.dart                    # Entry point
├── models/
│   └── tweet.dart             # Modelo con fromJson/toJson
├── services/
│   └── tweet_service.dart      # Singleton con HTTP client
└── screens/
    └── home_screen.dart        # UI principal con ListView
```

### 3.5 Permisos Android

En `android/app/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

✅ **Ya está configurado en el proyecto**

### 3.6 Ejecutar la App

```bash
# Android
flutter run

# Web
flutter run -d chrome

# iOS (macOS)
flutter run -d ios
```

---

## 🔌 ENDPOINTS API

### GET - Obtener Tweets
```
GET /api/tweets?page=0&size=10
```
**Response** (200):
```json
{
  "content": [
    {
      "id": 1,
      "tweet": "Hola mundo!",
      "createdAt": "2024-05-07T10:30:00",
      "updatedAt": "2024-05-07T10:30:00"
    }
  ],
  "totalElements": 1,
  "totalPages": 1,
  "number": 0
}
```

### GET - Obtener Tweet por ID
```
GET /api/tweets/{id}
```

### POST - Crear Tweet
```
POST /api/tweets
Content-Type: application/json

{
  "tweet": "Mi primer tweet!"
}
```
**Response** (201):
```json
{
  "id": 1,
  "tweet": "Mi primer tweet!",
  "createdAt": "2024-05-07T10:30:00",
  "updatedAt": "2024-05-07T10:30:00"
}
```

### PUT - Actualizar Tweet
```
PUT /api/tweets/{id}
{
  "tweet": "Tweet actualizado"
}
```

### DELETE - Eliminar Tweet
```
DELETE /api/tweets/{id}
```
**Response** (204): Sin contenido

---

## 📊 Validaciones

### Tweet
- **@NotBlank**: No puede estar vacío
- **@Size(max = 140)**: Máximo 140 caracteres (como Twitter original)

### Respuestas HTTP
| Código | Significado |
|--------|-------------|
| 200 | OK - Operación exitosa |
| 201 | Created - Recurso creado |
| 204 | No Content - Eliminado correctamente |
| 404 | Not Found - Recurso no encontrado |
| 400 | Bad Request - Datos inválidos |

---

## 🛠️ Troubleshooting

### Error: "Connection refused"
- Verificar que Spring Boot esté ejecutándose
- En emulador Android: usar `10.0.2.2` en lugar de `localhost`

### Error: "SSL certificate problem"
- En development: usar `http://` en lugar de `https://`
- En production: Render proporciona certificados SSL automáticamente

### Base de datos no se conecta
- Verificar credenciales en `application.properties`
- Verificar que Aiven permita conexiones SSL
- Confirmar que `?sslmode=require` esté en la URL

### Tweets no aparecen en Flutter
- Validar que la URL de API sea correcta
- Revisar logs: `flutter logs`
- Usar DevTools: `flutter pub global activate devtools && devtools`

---

## 📈 Flujo Completo

1. **Usuario escribe tweet** en TextField
2. **App valida** (no vacío, max 140 caracteres)
3. **TweetService.createTweet()** hace POST a `/api/tweets`
4. **Backend valida** con `@NotBlank` y `@Size`
5. **JPA Hibernate** inserta en PostgreSQL (Aiven)
6. **API responde** con tweet creado (201)
7. **Flutter recibe** y actualiza ListView
8. **Usuario ve** su tweet en tiempo real

---

## 🚀 Próximas Mejoras

- [ ] Autenticación (JWT)
- [ ] Búsqueda de tweets
- [ ] Likes/Favoritos
- [ ] Respuestas a tweets
- [ ] Followers/Following
- [ ] Notificaciones push
- [ ] Modo oscuro
- [ ] Caché local

---

## 📝 Notas Importantes

✅ **CORS habilitado**: `@CrossOrigin(origins = "*")`
✅ **Validación de entrada**: Server-side en Spring Boot
✅ **Paginación implementada**: Evita cargar todas las tweets
✅ **Singleton Pattern**: Una única conexión HTTP en toda la app
✅ **Manejo de errores**: Try-catch en todos los endpoints

---

**¡Tu aplicación Tweeter está lista para producción!** 🎉
