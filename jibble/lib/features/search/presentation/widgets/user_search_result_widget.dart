import 'package:flutter/material.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';
import 'package:jibble/features/follow/presentation/widgets/user_list_item_widget.dart';

/// User Search Result Widget
///
/// Displays a single user search result
class UserSearchResultWidget extends StatelessWidget {
  final UserSearchEntity user;

  const UserSearchResultWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return UserListItemWidget(user: user, showFollowButton: true);
  }
}
