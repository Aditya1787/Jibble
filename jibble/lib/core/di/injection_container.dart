import 'package:get_it/get_it.dart';
import 'package:jibble/features/auth/data/datasources/auth_service.dart';
import 'package:jibble/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jibble/features/auth/domain/repositories/auth_repository.dart';
import 'package:jibble/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:jibble/features/profile/data/datasources/profile_service.dart';
import 'package:jibble/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:jibble/features/profile/domain/repositories/profile_repository.dart';
import 'package:jibble/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jibble/features/profile/domain/usecases/is_username_available_usecase.dart';
import 'package:jibble/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:jibble/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:jibble/features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:jibble/features/home/domain/usecases/get_home_feed_usecase.dart';
import 'package:jibble/features/home/domain/repositories/home_repository.dart';
import 'package:jibble/features/home/data/repositories/home_repository_impl.dart';
import 'package:jibble/features/post/domain/usecases/toggle_like_usecase.dart';
import 'package:jibble/features/post/domain/usecases/create_post_usecase.dart';
import 'package:jibble/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:jibble/features/post/domain/usecases/get_user_posts_usecase.dart';
import 'package:jibble/features/post/domain/usecases/get_circle_feed_usecase.dart';
import 'package:jibble/features/post/domain/repositories/post_repository.dart';
import 'package:jibble/features/post/data/repositories/post_repository_impl.dart';
import 'package:jibble/features/post/data/datasources/post_service.dart';
import 'package:jibble/features/chat/domain/usecases/get_recent_chats_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_recent_chats_stream_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_messages_stream_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:jibble/features/chat/data/datasources/chat_service.dart';
import 'package:jibble/features/chat/domain/usecases/get_user_groups_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_user_groups_stream_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/create_group_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_group_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_group_messages_stream_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/send_group_message_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_group_by_id_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/subscribe_to_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/unsubscribe_from_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/subscribe_to_group_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/unsubscribe_from_group_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/is_owner_of_group_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/update_group_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/add_group_members_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/remove_group_member_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/transfer_group_ownership_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/exit_group_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/delete_group_usecase.dart';
import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/data/repositories/group_repository_impl.dart';
import 'package:jibble/features/chat/data/datasources/group_service.dart';
import 'package:jibble/features/circle/domain/usecases/get_current_user_college_usecase.dart';
import 'package:jibble/features/circle/domain/usecases/get_circle_members_usecase.dart';
import 'package:jibble/features/circle/domain/usecases/search_circle_members_usecase.dart';
import 'package:jibble/features/circle/domain/repositories/circle_repository.dart';
import 'package:jibble/features/circle/data/repositories/circle_repository_impl.dart';
import 'package:jibble/features/circle/data/datasources/circle_service.dart';
import 'package:jibble/features/follow/domain/usecases/follow_user_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/unfollow_user_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/is_following_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/get_follower_count_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/get_following_count_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/get_followers_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/get_following_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/remove_follower_usecase.dart';
import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';
import 'package:jibble/features/follow/data/repositories/follow_repository_impl.dart';
import 'package:jibble/features/follow/data/datasources/follow_service.dart';
import 'package:jibble/features/search/domain/usecases/search_users_usecase.dart';
import 'package:jibble/features/search/domain/usecases/get_user_profile_for_search_usecase.dart';
import 'package:jibble/features/search/domain/usecases/get_user_basic_info_usecase.dart';
import 'package:jibble/features/search/domain/repositories/user_search_repository.dart';
import 'package:jibble/features/search/data/repositories/user_search_repository_impl.dart';
import 'package:jibble/features/search/data/datasources/user_search_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance; // sl is Service Locator

Future<void> init() async {
  // Features - Auth
  sl.registerLazySingleton(() => GetAuthStateChangesUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));

  // Features - Profile
  // UseCases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => IsUsernameAvailableUseCase(sl()));
  sl.registerLazySingleton(() => CreateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfilePictureUseCase(sl()));

  // Features - Post
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => GetUserPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetCircleFeedUseCase(sl()));

  // Features - Home
  sl.registerLazySingleton(() => GetHomeFeedUseCase(sl()));

  // Features - Chat
  sl.registerLazySingleton(() => GetRecentChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentChatsStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesStreamUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToMessagesUseCase(sl()));
  sl.registerLazySingleton(() => UnsubscribeFromMessagesUseCase(sl()));

  // Features - Group
  sl.registerLazySingleton(() => GetUserGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserGroupsStreamUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupMessagesStreamUseCase(sl()));
  sl.registerLazySingleton(() => SendGroupMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupByIdUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToGroupMessagesUseCase(sl()));
  sl.registerLazySingleton(() => UnsubscribeFromGroupUseCase(sl()));
  sl.registerLazySingleton(() => IsOwnerOfGroupUseCase());
  sl.registerLazySingleton(() => UpdateGroupUseCase(sl()));
  sl.registerLazySingleton(() => AddGroupMembersUseCase(sl()));
  sl.registerLazySingleton(() => RemoveGroupMemberUseCase(sl()));
  sl.registerLazySingleton(() => TransferGroupOwnershipUseCase(sl()));
  sl.registerLazySingleton(() => ExitGroupUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGroupUseCase(sl()));

  // Features - Circle
  sl.registerLazySingleton(() => GetCurrentUserCollegeUseCase(sl()));
  sl.registerLazySingleton(() => GetCircleMembersUseCase(sl()));
  sl.registerLazySingleton(() => SearchCircleMembersUseCase(sl()));

  // Features - Follow
  sl.registerLazySingleton(() => FollowUserUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(sl()));
  sl.registerLazySingleton(() => IsFollowingUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowerCountUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingCountUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowersUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFollowerUseCase(sl()));

  // Features - Search
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileForSearchUseCase(sl()));
  sl.registerLazySingleton(() => GetUserBasicInfoUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CircleRepository>(
    () => CircleRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FollowRepository>(
    () => FollowRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserSearchRepository>(
    () => UserSearchRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<ProfileService>(() => ProfileService());
  sl.registerLazySingleton<PostService>(() => PostService());
  sl.registerLazySingleton<ChatService>(() => ChatService());
  sl.registerLazySingleton<GroupService>(() => GroupService());
  sl.registerLazySingleton<CircleService>(() => CircleService());
  sl.registerLazySingleton<FollowService>(() => FollowService());
  sl.registerLazySingleton<UserSearchService>(() => UserSearchService());

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
