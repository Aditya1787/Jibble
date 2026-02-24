import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full Screen Photo Page
///
/// Displays a profile picture (or any image URL) in a full-screen,
/// dismissible, pinch-to-zoom viewer.
class FullScreenPhotoPage extends StatefulWidget {
  final String? imageUrl;
  final String heroTag;
  final String displayName;

  const FullScreenPhotoPage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.displayName,
  });

  @override
  State<FullScreenPhotoPage> createState() => _FullScreenPhotoPageState();
}

class _FullScreenPhotoPageState extends State<FullScreenPhotoPage>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late final AnimationController _animController;
  Animation<Matrix4>? _resetAnimation;

  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _transformController = TransformationController();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_resetAnimation != null) {
            _transformController.value = _resetAnimation!.value;
          }
        });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_isZoomed) {
      // Reset to original
      _resetAnimation =
          Matrix4Tween(
            begin: _transformController.value,
            end: Matrix4.identity(),
          ).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          );
      _animController.forward(from: 0);
      setState(() => _isZoomed = false);
    } else {
      // Zoom in to 2.5x
      _resetAnimation =
          Matrix4Tween(
            begin: _transformController.value,
            end: Matrix4.diagonal3Values(2.5, 2.5, 1.0),
          ).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          );
      _animController.forward(from: 0);
      setState(() => _isZoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: widget.imageUrl == null
          ? _buildPlaceholder()
          : GestureDetector(
              onDoubleTap: _onDoubleTap,
              child: Center(
                child: Hero(
                  tag: widget.heroTag,
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 1.0,
                    maxScale: 5.0,
                    onInteractionEnd: (details) {
                      final scale = _transformController.value
                          .getMaxScaleOnAxis();
                      setState(() => _isZoomed = scale > 1.05);
                    },
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      fit: BoxFit.contain,
                      progressIndicatorBuilder: (context, url, progress) {
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.person, size: 64, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          Text(
            widget.displayName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No profile photo',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
