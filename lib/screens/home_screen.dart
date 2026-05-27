import 'package:flutter/material.dart';

import '../models/car_post.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/car_post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final CarPostService _postService = CarPostService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Future<List<CarPost>> _postsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.fetchPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _photoUrlController.dispose();
    _descriptionController.dispose();
    _postService.dispose();
    super.dispose();
  }

  User? get _currentUser => _authService.getUser();

  void _reloadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts();
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final photoUrl = _photoUrlController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || photoUrl.isEmpty) {
      _showErrorDialog('Completa al menos el titulo y la URL de la foto.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _postService.createPost(
        title: title,
        brand: brand.isEmpty ? null : brand,
        model: model.isEmpty ? null : model,
        year: year,
        photoUrl: photoUrl,
        description: description.isEmpty ? null : description,
      );

      _titleController.clear();
      _brandController.clear();
      _modelController.clear();
      _yearController.clear();
      _photoUrlController.clear();
      _descriptionController.clear();
      _reloadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicacion creada')),
        );
      }
    } catch (e) {
      _showErrorDialog('No se pudo publicar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
      filled: true,
    );
  }

  Widget _buildComposer() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Publicar auto', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: _fieldDecoration('Titulo', Icons.title),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _photoUrlController,
            decoration: _fieldDecoration('URL de la foto', Icons.image),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _brandController,
                  decoration: _fieldDecoration('Marca', Icons.directions_car),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _modelController,
                  decoration: _fieldDecoration('Modelo', Icons.label),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: _fieldDecoration('Año', Icons.calendar_today),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: _fieldDecoration('Descripcion', Icons.notes),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publicar auto'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(CarPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                post.photoUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  if ((post.description ?? '').isNotEmpty) Text(post.description!),
                  const SizedBox(height: 8),
                  Text(
                    'Marca: ${post.brand ?? '-'} | Modelo: ${post.model ?? '-'} | Año: ${post.year?.toString() ?? '-'}',
                  ),
                  const SizedBox(height: 6),
                  Text('Publicado por: ${post.authorDisplayName}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarTweeter - Publicaciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                'Usuario: ${user?.displayName ?? user?.username ?? 'Invitado'}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesion')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildComposer(),
          Expanded(
            child: FutureBuilder<List<CarPost>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _reloadPosts,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final posts = snapshot.data ?? const <CarPost>[];
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No hay publicaciones todavia'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _reloadPosts();
                    await _postsFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(posts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
