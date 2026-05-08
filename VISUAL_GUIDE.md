# 🎬 GUÍA VISUAL PASO A PASO

## PARTE 1: BASE DE DATOS (Aiven)

### Paso 1: Crear Cuenta en Aiven

```
1. Abre https://aiven.io
2. Click en "Sign Up"
3. Usa tu email o GitHub
4. Verifica email
```

![Aiven signup]

### Paso 2: Crear Servicio PostgreSQL

```
1. Dashboard → Create Service
2. Selecciona PostgreSQL
3. Version: PostgreSQL 17
4. Cloud: Cualquiera (recomendado: AWS/GCP)
5. Region: La más cercana a ti
6. Plan: Free tier (para desarrollo)
7. Nombre: tweeter-db (opcional)
8. Create Service
```

⏳ Espera ~5 minutos

### Paso 3: Copiar Credenciales

```
1. En dashboard, busca tu servicio
2. Click en el nombre
3. Mira "Connection information"
4. Copia la "Service URI" que se ve así:

postgresql://avnadmin:contraseña@pg-xxxxx.aivencloud.com:12345/defaultdb

       ↓↓↓ Desglosado:
       
   Usuario:   avnadmin
   Contraseña: contraseña (cambiar después si quieres)
   Host:      pg-xxxxx.aivencloud.com
   Puerto:    12345
   Base de datos: defaultdb
```

---

## PARTE 2: CONFIGURAR SPRING BOOT

### Paso 1: Actualizar Credenciales

```bash
# Abre con editor:
tweeter-api/src/main/resources/application.properties

# Busca estas líneas:
spring.datasource.url=jdbc:postgresql://...
spring.datasource.username=avnadmin
spring.datasource.password=...

# Reemplaza con TUS credenciales de Aiven:
spring.datasource.url=jdbc:postgresql://pg-xxxxx.aivencloud.com:12345/defaultdb?sslmode=require
spring.datasource.username=avnadmin
spring.datasource.password=tu_contraseña_aqui
```

### Paso 2: Compilar (Maven)

```bash
cd tweeter-api
mvn clean package
```

✅ Esperado:
```
[INFO] Building jar: .../target/tweeter-api-0.0.1-SNAPSHOT.jar
[INFO] BUILD SUCCESS
```

---

## PARTE 3: DOCKER (Construcción de Imagen)

### Paso 1: Crear Cuenta Docker Hub

```
1. Abre https://hub.docker.com
2. Click "Sign Up"
3. Crea username: tu-usuario-docker
4. Verifica email
```

### Paso 2: Construir Imagen

```bash
cd tweeter-api

docker build -t tu-usuario-docker/tweeter-api:latest .
```

✅ Esperado:
```
Successfully built XXXXXXXXX
Successfully tagged tu-usuario-docker/tweeter-api:latest
```

### Paso 3: Login en Docker

```bash
docker login

# Te pedirá:
# Username: tu-usuario-docker
# Password: tu-contraseña-docker
# Login Succeeded ✓
```

### Paso 4: Subir a Hub

```bash
docker push tu-usuario-docker/tweeter-api:latest
```

✅ Esperado:
```
Pushing tu-usuario-docker/tweeter-api:latest...
Digest: sha256:xxxxx...
Status: Pushed
```

---

## PARTE 4: DESPLEGAR EN RENDER

### Paso 1: Crear Cuenta Render

```
1. Abre https://render.com
2. Click "Get started"
3. Usa GitHub o Email
4. Verifica email
```

### Paso 2: Crear Web Service

```
1. Dashboard
2. Click "New +"
3. Selecciona "Web Service"
4. Selecciona "Deploy from a container image"
5. Selecciona "Continue with Docker Hub"
6. Imagen: tu-usuario-docker/tweeter-api:latest
7. Click "Continue"
```

### Paso 3: Configurar Variables de Ambiente

```
En el formulario, agrega Environment Variables:

Variable: SPRING_DATASOURCE_URL
Value:    jdbc:postgresql://pg-xxxxx.aivencloud.com:12345/defaultdb?sslmode=require

Variable: SPRING_DATASOURCE_USERNAME
Value:    avnadmin

Variable: SPRING_DATASOURCE_PASSWORD
Value:    tu_contraseña_de_aiven

Variable: SPRING_JPA_HIBERNATE_DDL_AUTO
Value:    update
```

### Paso 4: Deploy

```
1. Click "Create Web Service"
2. Espera ~5-10 minutos mientras building
3. Cuando veas "Active", ¡listo! ✅

Busca arriba la URL pública, algo como:
https://tu-app-xxxxx.render.com
```

---

## PARTE 5: CLIENTE FLUTTER

### Paso 1: Instalar Dependencias

```bash
cd flutter_client
flutter pub get
```

✅ Esperado: Sin errores

### Paso 2: Actualizar URL de API

```dart
# Abre:
lib/screens/home_screen.dart

# Busca (línea ~25):
_tweetService = TweetService(
  customBaseUrl: 'http://10.0.2.2:8080/api',
);

# Reemplaza con tu URL de Render:
_tweetService = TweetService(
  customBaseUrl: 'https://tu-app-xxxxx.render.com/api',
);
```

### Paso 3: Ejecutar en Emulador

```bash
# Inicia Android Studio
# Open Android Emulator

# En terminal:
flutter run

# Cuando veas "Launching emulator..." espera
# Cuando veas el logo de Flutter, ¡éxito! ✅
```

---

## PRUEBAS

### Test 1: Crear Tweet

```
1. En Flutter app, ve al TextField
2. Escribe: "¡Hola Tweeter!"
3. Click "Enviar Tweet"
4. Espera 2 segundos
5. Deberías ver el tweet en la lista ✅
```

### Test 2: Ver Tweets

```
1. Presiona el botón de refresh (⟲ ícono)
2. Deberías ver todos los tweets cargados
3. Ordenados de más reciente a más viejo ✅
```

### Test 3: Eliminar Tweet

```
1. Mantén presionado un tweet
2. Click en "Eliminar"
3. Tweet desaparece ✅
```

### Test 4: Validaciones

```
1. Intenta enviar sin texto → Verás error ✅
2. Intenta escribir >140 caracteres → No te deja escribir ✅
```

---

## TROUBLESHOOTING

### ❌ "Connection refused"
```
PROBLEMA: Backend no conecta
SOLUCIÓN:
  1. ¿Render está "Active"? Ver dashboard
  2. Espera 2-3 min después de deploy
  3. Recarga página Render
```

### ❌ "SSL certificate problem"
```
PROBLEMA: Error de SSL en conexión
SOLUCIÓN:
  1. Verificar ?sslmode=require en URL
  2. En Aiven, clickear "Force SSL" si existe
```

### ❌ "Database connection failed"
```
PROBLEMA: No conecta a Aiven
SOLUCIÓN:
  1. Copiar exactamente credenciales de Aiven
  2. Verificar que "password" es correcta
  3. Aiven requiere SSL (already seteado)
  4. Probar conexión local: psql postgresql://...
```

### ❌ "Flutter app no ve tweets"
```
PROBLEMA: ListaVista vacía
SOLUCIÓN:
  1. Abre Flutter DevTools en la URL que aparece
  2. Mira "Logging" → busca errores
  3. Revisa URL de API es correcta
  4. En emulador Android, usar 10.0.2.2 no localhost
```

### ❌ "Docker push error"
```
PROBLEMA: No puedo subir imagen
SOLUCIÓN:
  1. docker login
  2. docker build -t usuario/nombre:latest .
   Nota: usuario debe coincidir con Docker Hub username
  3. docker push usuario/nombre:latest
```

---

## 🎯 CHECKLIST FINAL

- [ ] Aiven account creada ✓
- [ ] PostgreSQL 17 desplegado ✓
- [ ] Credenciales copiadas a application.properties ✓
- [ ] Maven build sin errores ✓
- [ ] Docker image construida ✓
- [ ] Docker Hub login funciona ✓
- [ ] Imagen subida a Docker Hub ✓
- [ ] Render account creada ✓
- [ ] Web Service desplegado ✓
- [ ] URL pública copiada ✓
- [ ] Flutter pub get sin errores ✓
- [ ] API URL actualizada en Flutter ✓
- [ ] Emulador Android iniciado ✓
- [ ] Flutter run ejecutado ✓
- [ ] ¡Puedo crear tweets! ✓
- [ ] ¡Puedo ver tweets! ✓
- [ ] ¡Puedo eliminar tweets! ✓

Si todo está chequeado → 🎉 ¡ÉXITO TOTAL!

---

## 📱 DISPOSITIVO FÍSICO (Opcional)

Si quieres usar tu teléfono en lugar del emulador:

```bash
# Conecta tu teléfono Android vía USB
adb devices

# Te mostrará el teléfono:
# XXXXXX  device

# Ejecuta Flutter
flutter run

# Selecciona tu teléfono cuando te pida
```

---

## 🌐 EJECUTAR EN WEB (Opcional)

```bash
flutter run -d chrome

# Se abre navegador con la app
# Mismo funciona como en mobile
```

---

## 💾 GUARDAR CAMBIOS (Git)

```bash
# Desde raíz del proyecto:
git init
git add .
git commit -m "Initial tweeter project setup"
git branch -M main
git remote add origin https://github.com/tu-usuario/tweeter.git
git push -u origin main
```

---

## 🚀 ACTUALIZAR CÓDIGO DESPUÉS

Si cambias código:

### Backend
```bash
cd tweeter-api
mvn clean package
docker build -t usuario/tweeter-api:latest .
docker push usuario/tweeter-api:latest
# En Render: Auto-redeploy o manual
```

### Frontend
```bash
cd flutter_client
flutter pub get
flutter run
```

---

## 📚 DOCUMENTACIÓN ADICIONAL

- `README.md` → Completo (3000+ líneas)
- `QUICK_START.txt` → Resumen rápido
- `API_TESTING.md` → Ejemplos curl
- `DEVELOPMENT.md` → Setup local
- `SECURITY_GUIDE.md` → Credenciales y secretos

---

¡Felicidades! 🎉 Tu aplicación Tweeter está lista para producción.

Next step: README.md para detalles técnicos.

═══════════════════════════════════════════════════════════════════════════════
