import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  static const Map<String, String> _reactionEmoji = {
    'LIKE': '👍',
    'LOVE': '❤️',
    'ANGRY': '😡',
    'SAD': '😢',
    'WOW': '😮',
    'LAUGH': '😂',
  };

  final AuthService _authService = AuthService();
  final CarPostService _postService = CarPostService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Future<List<CarPost>> _postsFuture;
  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageDataUri;
  final Set<int> _reactingPostIds = <int>{};

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
    final photoUrl = _selectedImageDataUri ?? _photoUrlController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || photoUrl.isEmpty) {
      _showErrorDialog('Completa al menos el titulo y agrega una foto (URL, galeria o camara).');
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
      _selectedImageBytes = null;
      _selectedImageDataUri = null;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 78,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      final mime = _mimeTypeFromPath(image.path);
      final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageDataUri = dataUri;
      });
    } catch (e) {
      _showErrorDialog('No se pudo seleccionar la imagen: $e');
    }
  }

  String _mimeTypeFromPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  void _clearPickedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageDataUri = null;
    });
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reactToPost(CarPost post, String reactionType) async {
    if (_reactingPostIds.contains(post.id)) {
      return;
    }

    setState(() {
      _reactingPostIds.add(post.id);
    });

    try {
      await _postService.reactToPost(postId: post.id, reactionType: reactionType);
      _reloadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo reaccionar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _reactingPostIds.remove(post.id);
        });
      }
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _showImageSourceSheet,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Elegir foto (galeria/camara)'),
          ),
          if (_selectedImageBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _selectedImageBytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _clearPickedImage,
                icon: const Icon(Icons.close),
                label: const Text('Quitar foto seleccionada'),
              ),
            ),
          ],
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
    Widget imageWidget;
    if (post.photoUrl.startsWith('data:image')) {
      final parts = post.photoUrl.split(',');
      if (parts.length == 2) {
        try {
          final bytes = base64Decode(parts[1]);
          imageWidget = Image.memory(
            bytes,
            fit: BoxFit.contain,
          );
        } catch (_) {
          imageWidget = Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image),
          );
        }
      } else {
        imageWidget = Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image),
        );
      }
    } else {
      imageWidget = Image.network(
        post.photoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }

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
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: imageWidget,
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reactionEmoji.entries.map((entry) {
                final reactionType = entry.key;
                final reactionIcon = entry.value;
                final count = post.reactions[reactionType] ?? 0;
                final selected = post.userReaction == reactionType;
                final reacting = _reactingPostIds.contains(post.id);

                return ChoiceChip(
                  label: Text('$reactionIcon $count'),
                  selected: selected,
                  onSelected: reacting
                      ? null
                      : (_) => _reactToPost(post, reactionType),
                );
              }).toList(),
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
