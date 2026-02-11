import 'package:flutter/material.dart';
import '../../services/follow_service.dart';

/// Follow Button Widget
///
/// Reusable button for following/unfollowing users
class FollowButtonWidget extends StatefulWidget {
  final String userId;
  final bool initialIsFollowing;
  final VoidCallback? onFollowChanged;

  const FollowButtonWidget({
    super.key,
    required this.userId,
    required this.initialIsFollowing,
    this.onFollowChanged,
  });

  @override
  State<FollowButtonWidget> createState() => _FollowButtonWidgetState();
}

class _FollowButtonWidgetState extends State<FollowButtonWidget> {
  final _followService = FollowService();
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
  }

  Future<void> _toggleFollow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        await _followService.unfollowUser(widget.userId);
      } else {
        await _followService.followUser(widget.userId);
      }

      setState(() {
        _isFollowing = !_isFollowing;
      });

      widget.onFollowChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing
            ? Colors.grey.shade300
            : const Color(0xFF6B4CE6),
        foregroundColor: _isFollowing ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isFollowing ? Colors.black : Colors.white,
                ),
              ),
            )
          : Text(
              _isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
    );
  }
}
