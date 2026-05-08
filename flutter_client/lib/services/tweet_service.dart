import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tweet.dart';

/// Servicio Singleton para manejar todas las llamadas HTTP a la API
/// Garantiza una única instancia durante toda la aplicación
class TweetService {
  // Instancia privada estática - única en toda la aplicación
  static final TweetService _instance = TweetService._internal();

  // URL base de la API (obtenida de Render.com)
  // Cambiar por: https://tu-app-name.render.com
  late String baseUrl;
  
  // Modo offline: usar datos locales sin conectarse a servidor
  bool _offlineMode = false;
  
  // Almacenamiento local de tweets para modo offline
  final List<Tweet> _localTweets = [
    Tweet(
      id: 1,
      tweet: '¡Hola! Bienvenido a Tweeter 🚀',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    ),
    Tweet(
      id: 2,
      tweet: 'Este es un tweet de prueba con datos locales 💻',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    ),
  ];
  
  int _nextId = 3;

  /// Constructor privado para patrón Singleton
  TweetService._internal() {
    // Inicializar baseUrl por defecto
    // En producción, usar la URL de Render: https://adsoftsito-api.render.com
    baseUrl = 'http://localhost:8080/api';
  }

  /// Factory constructor que retorna la instancia única
  factory TweetService({String? customBaseUrl}) {
    if (customBaseUrl != null) {
      _instance.baseUrl = customBaseUrl;
    }
    return _instance;
  }
  
  /// Activar o desactivar modo offline (usa datos locales)
  void setOfflineMode(bool offline) {
    _offlineMode = offline;
  }

  /// Obtener todos los tweets con paginación
  /// 
  /// Parámetros:
  /// - page: número de página (default: 0)
  /// - size: cantidad de tweets por página (default: 10)
  Future<Map<String, dynamic>> getAllTweets({
    int page = 0,
    int size = 10,
  }) async {
    try {
      // Modo offline: usar datos locales
      if (_offlineMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de red
        
        // Ordenar por fecha descendente (más recientes primero)
        final sorted = List<Tweet>.from(_localTweets)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Aplicar paginación
        final startIndex = page * size;
        final endIndex = (startIndex + size).clamp(0, sorted.length);
        
        final paginatedTweets = startIndex >= sorted.length 
          ? <Tweet>[]
          : sorted.sublist(startIndex, endIndex);
        
        return {
          'success': true,
          'tweets': paginatedTweets,
          'totalElements': sorted.length,
          'totalPages': (sorted.length / size).ceil(),
          'currentPage': page,
        };
      }
      
      // Modo online: conectar al servidor
      final Uri url = Uri.parse(
        '$baseUrl/tweets?page=$page&size=$size',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('La solicitud tardó demasiado'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        
        // Procesar la respuesta paginada
        final List<dynamic> content = json['content'] ?? [];
        final tweets = content
            .map((item) => Tweet.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'tweets': tweets,
          'totalElements': json['totalElements'] ?? 0,
          'totalPages': json['totalPages'] ?? 0,
          'currentPage': json['number'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener un tweet específico por ID
  Future<Map<String, dynamic>> getTweetById(int id) async {
    try {
      final Uri url = Uri.parse('$baseUrl/tweets/$id');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final tweet = Tweet.fromJson(jsonDecode(response.body));
        return {
          'success': true,
          'tweet': tweet,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Tweet no encontrado',
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Crear un nuevo tweet
  /// 
  /// Parámetro:
  /// - content: contenido del tweet (máximo 140 caracteres)
  Future<Map<String, dynamic>> createTweet(String content) async {
    if (content.isEmpty) {
      return {
        'success': false,
        'error': 'El tweet no puede estar vacío',
      };
    }

    if (content.length > 140) {
      return {
        'success': false,
        'error': 'El tweet no puede exceder 140 caracteres',
      };
    }

    try {
      // Modo offline: guardar localmente
      if (_offlineMode) {
        await Future.delayed(const Duration(milliseconds: 300)); // Simular delay
        
        final newTweet = Tweet(
          id: _nextId++,
          tweet: content,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        _localTweets.add(newTweet);
        
        return {
          'success': true,
          'tweet': newTweet,
          'message': 'Tweet creado exitosamente (local)',
        };
      }
      
      // Modo online: conectar al servidor
      final Uri url = Uri.parse('$baseUrl/tweets');
      final tweet = Tweet(
        tweet: content,
        createdAt: DateTime.now().toIso8601String(),
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(tweet.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newTweet = Tweet.fromJson(jsonDecode(response.body));
        return {
          'success': true,
          'tweet': newTweet,
          'message': 'Tweet creado exitosamente',
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Actualizar un tweet existente
  Future<Map<String, dynamic>> updateTweet(int id, String content) async {
    if (content.isEmpty) {
      return {
        'success': false,
        'error': 'El tweet no puede estar vacío',
      };
    }

    if (content.length > 140) {
      return {
        'success': false,
        'error': 'El tweet no puede exceder 140 caracteres',
      };
    }

    try {
      // Modo offline: actualizar localmente
      if (_offlineMode) {
        await Future.delayed(const Duration(milliseconds: 300)); // Simular delay
        
        final index = _localTweets.indexWhere((t) => t.id == id);
        if (index == -1) {
          return {
            'success': false,
            'error': 'Tweet no encontrado',
          };
        }
        
        final updatedTweet = Tweet(
          id: id,
          tweet: content,
          createdAt: _localTweets[index].createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        _localTweets[index] = updatedTweet;
        
        return {
          'success': true,
          'tweet': updatedTweet,
          'message': 'Tweet actualizado exitosamente (local)',
        };
      }
      
      // Modo online: conectar al servidor
      final Uri url = Uri.parse('$baseUrl/tweets/$id');
      final tweet = Tweet(
        tweet: content,
        createdAt: DateTime.now().toIso8601String(),
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(tweet.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final updatedTweet = Tweet.fromJson(jsonDecode(response.body));
        return {
          'success': true,
          'tweet': updatedTweet,
          'message': 'Tweet actualizado exitosamente',
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Eliminar un tweet
  Future<Map<String, dynamic>> deleteTweet(int id) async {
    try {
      // Modo offline: eliminar localmente
      if (_offlineMode) {
        await Future.delayed(const Duration(milliseconds: 300)); // Simular delay
        
        final index = _localTweets.indexWhere((t) => t.id == id);
        if (index == -1) {
          return {
            'success': false,
            'error': 'Tweet no encontrado',
          };
        }
        
        _localTweets.removeAt(index);
        
        return {
          'success': true,
          'message': 'Tweet eliminado exitosamente (local)',
        };
      }
      
      // Modo online: conectar al servidor
      final Uri url = Uri.parse('$baseUrl/tweets/$id');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tweet eliminado exitosamente',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Tweet no encontrado',
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
}

/// Excepción personalizada para timeouts
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
