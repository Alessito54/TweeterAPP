# API Testing

Puedes usar curl o Postman para probar los endpoints:

## 1. Crear Tweet
```bash
curl -X POST http://localhost:8080/api/tweets \
  -H "Content-Type: application/json" \
  -d '{
    "tweet": "Mi primer tweet!"
  }'
```

## 2. Obtener Todos los Tweets (Paginado)
```bash
curl "http://localhost:8080/api/tweets?page=0&size=10"
```

## 3. Obtener Tweet por ID
```bash
curl http://localhost:8080/api/tweets/1
```

## 4. Actualizar Tweet
```bash
curl -X PUT http://localhost:8080/api/tweets/1 \
  -H "Content-Type: application/json" \
  -d '{
    "tweet": "Tweet actualizado!"
  }'
```

## 5. Eliminar Tweet
```bash
curl -X DELETE http://localhost:8080/api/tweets/1
```

## 6. Eliminar Todos los Tweets
```bash
curl -X DELETE http://localhost:8080/api/tweets
```

---

## Respuestas de Ejemplo

### Crear/Actualizar (201/200):
```json
{
  "id": 1,
  "tweet": "Mi primer tweet!",
  "createdAt": "2024-05-07T10:30:45.123456",
  "updatedAt": "2024-05-07T10:30:45.123456"
}
```

### Listar (200):
```json
{
  "content": [
    {
      "id": 2,
      "tweet": "Otro tweet",
      "createdAt": "2024-05-07T10:35:00",
      "updatedAt": "2024-05-07T10:35:00"
    },
    {
      "id": 1,
      "tweet": "Mi primer tweet!",
      "createdAt": "2024-05-07T10:30:45",
      "updatedAt": "2024-05-07T10:30:45"
    }
  ],
  "pageable": {
    "sort": {
      "empty": false,
      "sorted": true,
      "unsorted": false
    },
    "offset": 0,
    "pageSize": 10,
    "pageNumber": 0,
    "paged": true,
    "unpaged": false
  },
  "totalElements": 2,
  "totalPages": 1,
  "last": true,
  "size": 10,
  "number": 0,
  "sort": {
    "empty": false,
    "sorted": true,
    "unsorted": false
  },
  "first": true,
  "numberOfElements": 2,
  "empty": false
}
```

### Error Validación (400):
```json
{
  "timestamp": "2024-05-07T10:40:00.123456",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/tweets"
}
```

### No Encontrado (404):
```json
{
  "timestamp": "2024-05-07T10:40:00.123456",
  "status": 404,
  "error": "Not Found",
  "message": "Tweet not found",
  "path": "/api/tweets/999"
}
```
