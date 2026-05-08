import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/tweet.dart';
import '../services/tweet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TweetService _tweetService;
  final TextEditingController _tweetController = TextEditingController();
  List<Tweet> tweets = [];
  bool isLoading = false;
  int currentPage = 0;
  String? errorMessage;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    // Instanciar el servicio Singleton - solo una instancia en toda la app
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final baseUrl = kIsWeb
        ? (apiBaseUrl.isNotEmpty ? apiBaseUrl : 'http://localhost:8080/api')
        : 'http://10.0.2.2:8080/api';
    _tweetService = TweetService(
      // Reemplazar con la URL de Render cuando esté desplegado
      customBaseUrl: baseUrl,
    );
    _loadTweets();
  }

  /// Cargar todos los tweets con paginación
  Future<void> _loadTweets() async {
    setState(() => isLoading = true);
    errorMessage = null;

    final result = await _tweetService.getAllTweets(
      page: currentPage,
      size: 10,
    );

    setState(() {
      isLoading = false;
      if (result['success']) {
        tweets = result['tweets'] ?? [];
        errorMessage = null;
      } else {
        errorMessage = result['error'] ?? 'Error desconocido';
        tweets = [];
      }
    });
  }

  /// Crear un nuevo tweet
  Future<void> _createTweet() async {
    final content = _tweetController.text.trim();

    if (content.isEmpty) {
      _showMessage('El tweet no puede estar vacío', isError: true);
      return;
    }

    if (content.length > 140) {
      _showMessage('El tweet no puede exceder 140 caracteres', isError: true);
      return;
    }

    setState(() => isLoading = true);

    final result = await _tweetService.createTweet(content);

    setState(() {
      isLoading = false;
      if (result['success']) {
        _tweetController.clear();
        currentPage = 0;
        _showMessage('Tweet creado exitosamente!');
        _loadTweets();
      } else {
        _showMessage(result['error'] ?? 'Error al crear tweet', isError: true);
      }
    });
  }

  /// Eliminar un tweet
  Future<void> _deleteTweet(int tweetId) async {
    setState(() => isLoading = true);

    final result = await _tweetService.deleteTweet(tweetId);

    setState(() {
      isLoading = false;
      if (result['success']) {
        _showMessage('Tweet eliminado exitosamente!');
        _loadTweets();
      } else {
        _showMessage(result['error'] ?? 'Error al eliminar', isError: true);
      }
    });
  }

  /// Mostrar mensaje temporal
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweeter App'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Sección de crear tweet
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear nuevo tweet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tweetController,
                  maxLength: 140,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu tweet aquí...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '${_tweetController.text.length}/140',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _createTweet,
                    icon: const Icon(Icons.send),
                    label: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Enviar Tweet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Mostrar errores si existen
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          // Lista de tweets
          Expanded(
            child: isLoading && tweets.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tweets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay tweets aún',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Crea el primero!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tweets.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final tweet = tweets[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#${tweet.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'delete' &&
                                              tweet.id != null) {
                                            _deleteTweet(tweet.id!);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Eliminar'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tweet.tweet,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    tweet.createdAt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _loadTweets,
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }
}
