import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';

class CreatePostPage extends StatefulWidget {
  final bool isCirclePost;
  final String postType; // 'standard', 'event', 'confession'

  const CreatePostPage({
    super.key,
    this.isCirclePost = false,
    this.postType = 'standard',
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  final _postService = PostService();
  final _authService = AuthService();
  final _profileService = ProfileService();

  ProfileModel? _profile;
  File? _imageFile;
  bool _isLoading = false;
  bool _isProfileLoading = true;

  static const _primaryColor = Color(0xFF6B4CE6);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _profileService.getProfile(user.id);
        if (mounted) {
          setState(() {
            _profile = profile;
            _isProfileLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isProfileLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final size = await file.length();

      // 5MB limit
      if (size > PostService.maxFileSize) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image is too large. Please select an image under 5MB.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _submitPost() async {
    if ((_captionController.text.trim().isEmpty && _imageFile == null) &&
        widget.postType != 'confession') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo or write a caption.')),
      );
      return;
    }

    if (widget.postType == 'confession' &&
        _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confessions require text.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _postService.createPost(
        type: widget.postType,
        caption: _captionController.text.trim(),
        imageFile: _imageFile,
        isAnonymous: widget.postType == 'confession',
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Create Post';
    if (widget.postType == 'event') title = 'Create Event';
    if (widget.postType == 'confession') title = 'Anonymous Confession';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryColor,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryColor, Color(0xFF9D7CE8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.postType == 'confession')
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your identity is completely hidden. Feel free to share openly.',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.postType != 'confession')
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _isProfileLoading
                          ? const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  _profile?.profilePictureUrl != null
                                  ? NetworkImage(_profile!.profilePictureUrl!)
                                  : null,
                              backgroundColor: _primaryColor.withValues(
                                alpha: 0.5,
                              ),
                              child: _profile?.profilePictureUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.masks, color: Colors.grey[600]),
                      ),
                    ),

                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: null, // Auto-expand
                      minLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: widget.postType == 'confession'
                            ? 'What\'s your confession?'
                            : widget.postType == 'event'
                            ? 'Describe your event...'
                            : 'What\'s on your mind?',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.postType != 'confession')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: _imageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageFile = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: _primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add a photo',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Max size 5MB',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
