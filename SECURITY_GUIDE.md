# 🔐 Guía de Configuración de Credenciales Segura

## ⚠️ IMPORTANTE: NUNCA commitar credenciales a Git

---

## 1️⃣ CREDENCIALES DE AIVEN (Base de Datos)

### Obtener Credenciales
1. Ir a https://aiven.io → Dashboard
2. Servicios → PostgreSQL → Seleccionar tu servicio
3. Connection information → "Service URI"

Verás algo como:
```
postgresql://avnadmin:senha12345@pg-abc123.a.aivencloud.com:12345/defaultdb
```

### Desglosar:
- **Usuario**: `avnadmin`
- **Contraseña**: `senha12345` (ese cambio después)
- **Host**: `pg-abc123.a.aivencloud.com`
- **Puerto**: `12345`
- **Database**: `defaultdb`

### Configurar en Spring Boot

Editar: `tweeter-api/src/main/resources/application.properties`

```properties
# ===== DATABASE =====
spring.datasource.url=jdbc:postgresql://pg-abc123.a.aivencloud.com:12345/defaultdb?sslmode=require
spring.datasource.username=avnadmin
spring.datasource.password=senha12345
spring.datasource.driver-class-name=org.postgresql.Driver

# Resto de configuración...
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQL92Dialect
spring.jpa.hibernate.ddl-auto=update
```

---

## 2️⃣ DOCKER HUB

### Crear Cuenta
1. Ir a https://hub.docker.com
2. Sign Up
3. Verifica email

### Login Local
```bash
docker login
# Te pedirá username y token
# Username: tu-usuario-dockerhub
# Password: Token de acceso (genera en Settings)
```

### Generar Token (Recomendado)
1. Ir a https://hub.docker.com/settings/security
2. "New Access Token"
3. Copiar token
4. Usar como password en `docker login`

---

## 3️⃣ RENDER.COM

### Crear Cuenta
1. Ir a https://render.com
2. Sign Up (puedes usar GitHub)

### Variables de Ambiente en Render
Cuando depliegas, Render te pide variables de ambiente:

```
SPRING_DATASOURCE_URL=jdbc:postgresql://pg-abc123.a.aivencloud.com:12345/defaultdb?sslmode=require
SPRING_DATASOURCE_USERNAME=avnadmin
SPRING_DATASOURCE_PASSWORD=senha12345
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```

⚠️ **Render encripta estas variables** → Seguro

---

## 4️⃣ FLUTTER CONFIGURATION

### Para desarrollo local
En `flutter_client/lib/screens/home_screen.dart`:

```dart
// DESARROLLO (emulador Android)
_tweetService = TweetService(
  customBaseUrl: 'http://10.0.2.2:8080/api',
);

// PRODUCCIÓN (Render)
_tweetService = TweetService(
  customBaseUrl: 'https://tu-app.render.com/api',
);
```

No necesita credenciales (la API es pública con CORS abierto).

---

## 🔒 Mejores Prácticas de Seguridad

### ❌ NO HACER
```properties
# ❌ NUNCA guardar en Git
spring.datasource.password=senha12345
```

### ✅ HACER

#### Opción 1: Variables de Ambiente
```bash
export SPRING_DATASOURCE_PASSWORD=senha12345
```

Entonces en `application.properties`:
```properties
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
```

#### Opción 2: application-*.properties
```properties
# application.properties (publicado)
spring.profiles.active=@activatedProperties@

# application-prod.properties (ignorado en .gitignore)
spring.datasource.password=senha12345
spring.datasource.url=jdbc:postgresql://...
```

En `.gitignore`:
```
src/main/resources/application-*.properties
!src/main/resources/application-dev.properties
```

#### Opción 3: application.yml (YAML)
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: update
```

#### Opción 4: .env (Para desarrollo local)
```bash
# .env (añadir a .gitignore)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tweeter_db
DB_USERNAME=tweeter_user
DB_PASSWORD=password123
```

---

## 🐳 Secrets en Docker

### Build-time (incluido en imagen)
```dockerfile
ARG DB_URL
ENV SPRING_DATASOURCE_URL=${DB_URL}
```

```bash
docker build \
  --build-arg DB_URL="jdbc:postgresql://..." \
  -t my-app:latest .
```

### Runtime (pasado al contenedor)
```bash
docker run \
  -e SPRING_DATASOURCE_PASSWORD=senha12345 \
  my-app:latest
```

### Render (Recomendado)
- Dashboard > Environment
- Añadir variables
- Render las encripta automáticamente
- ✅ Más seguro

---

## 🔄 Flujo Seguro de Deployment

```
1. Desarrollo Local
   ├─ application.properties (local, gitignored)
   └─ Credenciales en variables de ambiente

2. Build Docker
   ├─ pom.xml (público)
   ├─ Dockerfile (público)
   └─ Credenciales: NO incluidas

3. Docker Hub
   ├─ Imagen pública (sin secretos)
   └─ Cualquiera puede descargar

4. Render Deployment
   ├─ Imagen de Hub → Pull
   ├─ Variables de ambiente → Inyectar
   └─ ✅ Secretos seguros en Render
```

---

## 📋 Checklist de Seguridad

- [ ] NUNCA commit secrets a Git
- [ ] `.gitignore` incluye `**/application-*.properties`
- [ ] Docker image NO contiene credenciales
- [ ] Variables de ambiente en Render son encriptadas
- [ ] Contraseña de Aiven es fuerte (>15 char)
- [ ] Token de Docker Hub rotado regularmente
- [ ] Token de Render.com tiene permisos limitados
- [ ] Cliente Flutter NO almacena credenciales
- [ ] CORS abierto solo en desarrollo (`*`), en prod específico
- [ ] SSH keys (si usas Git SSH) no son reenviados

---

## 🆘 Troubleshooting

### Error: "Connection refused" Base de Datos
1. Verificar URL correcta en `application.properties`
2. Verificar usuario/contraseña
3. Verificar que `sslmode=require` está ahí
4. Ping al host: `ping pg-abc123.a.aivencloud.com`

### Error: Docker push rejected
```bash
# Verificar login
docker login

# Verificar nombre imagen
docker tag mi-imagen tu-usuario/tweeter-api:latest

# Retry
docker push tu-usuario/tweeter-api:latest
```

### Error: Render no puede conectar a DB
1. Verificar variables de ambiente en Render
2. Verificar que no hay typos
3. Verificar SSL mode en URL
4. Revisar logs de Render: `Logs` en dashboard

### Error: Flutter no conecta a API
1. Verificar URL correcta (sin trailing slash)
2. Verificar que Backend está desplegado
3. En emulador: `10.0.2.2` en lugar de `localhost`
4. Verificar CORS en Backend

---

## 🔐 Rotación de Credenciales

### Cambiar contraseña Aiven
1. En Aiven dashboard: Settings → Database users
2. Reset password
3. Copiar nueva contraseña
4. Actualizar en Render variables de ambiente
5. Redeploy automático

### Crear nuevo Docker Hub token
1. Settings → Security
2. New Access Token
3. Usar nuevo token: `docker login`

---

## 📚 Referencias
- [Aiven Security](https://aiven.io/docs/doku.php?id=docs:security)
- [Spring Security](https://spring.io/projects/spring-security)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Render Environment Variables](https://render.com/docs/environment-variables)

---

**Recuerda: Con grandes poderes vienen grandes responsabilidades** 🦸‍♂️
