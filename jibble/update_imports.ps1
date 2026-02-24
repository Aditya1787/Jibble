$libDir = "d:\Uniclub\Application\jibble\lib"
$files = Get-ChildItem -Path $libDir -Recurse -Filter *.dart

# Define the replacements as a hash table
$replacements = @{
    # Core
    "import 'package:jibble/config/supabase_config.dart';" = "import 'package:jibble/core/network/supabase_config.dart';"
    
    # Auth
    "import 'package:jibble/services/auth_service.dart';" = "import 'package:jibble/features/auth/data/datasources/auth_service.dart';"
    "import 'package:jibble/services/first_launch_service.dart';" = "import 'package:jibble/features/auth/data/datasources/first_launch_service.dart';"
    "import 'package:jibble/screens/Authentication/login_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/login_page.dart';"
    "import 'package:jibble/screens/Authentication/register_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/register_page.dart';"
    "import 'package:jibble/screens/Authentication/logout_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/logout_page.dart';"
    "import 'package:jibble/screens/splash/splash_screen.dart';" = "import 'package:jibble/features/auth/presentation/screens/splash_screen.dart';"
    "import 'package:jibble/screens/onboarding/college_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/onboarding/college_page.dart';"
    "import 'package:jibble/screens/onboarding/date_of_birth_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/onboarding/date_of_birth_page.dart';"
    "import 'package:jibble/screens/onboarding/profile_picture_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/onboarding/profile_picture_page.dart';"
    "import 'package:jibble/screens/onboarding/username_page.dart';" = "import 'package:jibble/features/auth/presentation/screens/onboarding/username_page.dart';"
    "import 'package:jibble/widgets/auth_gate.dart';" = "import 'package:jibble/features/auth/presentation/widgets/auth_gate.dart';"
    "import 'package:jibble/widgets/onboarding_gate.dart';" = "import 'package:jibble/features/auth/presentation/widgets/onboarding_gate.dart';"
    "import 'package:jibble/providers/auth_provider.dart';" = "import 'package:jibble/features/auth/presentation/provider/auth_provider.dart';"

    # Home
    "import 'package:jibble/screens/home_page.dart';" = "import 'package:jibble/features/home/presentation/screens/home_page.dart';"
    "import 'package:jibble/widgets/home_drawer.dart';" = "import 'package:jibble/features/home/presentation/widgets/home_drawer.dart';"
    "import 'package:jibble/providers/feed_provider.dart';" = "import 'package:jibble/features/home/presentation/provider/feed_provider.dart';"

    # Profile
    "import 'package:jibble/models/profile_model.dart';" = "import 'package:jibble/features/profile/data/models/profile_model.dart';"
    "import 'package:jibble/services/profile_service.dart';" = "import 'package:jibble/features/profile/data/datasources/profile_service.dart';"
    "import 'package:jibble/screens/Profile/account_information_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/account_information_page.dart';"
    "import 'package:jibble/screens/Profile/edit_profile_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/edit_profile_page.dart';"
    "import 'package:jibble/screens/Profile/followers_list_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/followers_list_page.dart';"
    "import 'package:jibble/screens/Profile/following_list_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/following_list_page.dart';"
    "import 'package:jibble/screens/Profile/fullscreen_photo_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/fullscreen_photo_page.dart';"
    "import 'package:jibble/screens/Profile/profile_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/profile_page.dart';"
    "import 'package:jibble/screens/Profile/settings_drawer.dart';" = "import 'package:jibble/features/profile/presentation/screens/settings_drawer.dart';"
    "import 'package:jibble/screens/Profile/user_profile_page.dart';" = "import 'package:jibble/features/profile/presentation/screens/user_profile_page.dart';"

    # Chat
    "import 'package:jibble/models/chat_model.dart';" = "import 'package:jibble/features/chat/data/models/chat_model.dart';"
    "import 'package:jibble/models/group_model.dart';" = "import 'package:jibble/features/chat/data/models/group_model.dart';"
    "import 'package:jibble/models/group_message_model.dart';" = "import 'package:jibble/features/chat/data/models/group_message_model.dart';"
    "import 'package:jibble/models/message_model.dart';" = "import 'package:jibble/features/chat/data/models/message_model.dart';"
    "import 'package:jibble/services/chat_service.dart';" = "import 'package:jibble/features/chat/data/datasources/chat_service.dart';"
    "import 'package:jibble/services/group_service.dart';" = "import 'package:jibble/features/chat/data/datasources/group_service.dart';"
    "import 'package:jibble/screens/Chat/chat_arena_page.dart';" = "import 'package:jibble/features/chat/presentation/screens/chat_arena_page.dart';"
    "import 'package:jibble/screens/Chat/chat_list_page.dart';" = "import 'package:jibble/features/chat/presentation/screens/chat_list_page.dart';"
    "import 'package:jibble/screens/Chat/create_group_page.dart';" = "import 'package:jibble/features/chat/presentation/screens/create_group_page.dart';"
    "import 'package:jibble/screens/Chat/group_arena_page.dart';" = "import 'package:jibble/features/chat/presentation/screens/group_arena_page.dart';"
    "import 'package:jibble/screens/Chat/group_settings_page.dart';" = "import 'package:jibble/features/chat/presentation/screens/group_settings_page.dart';"
    "import 'package:jibble/widgets/Chat/chat_list_item_widget.dart';" = "import 'package:jibble/features/chat/presentation/widgets/chat_list_item_widget.dart';"
    "import 'package:jibble/widgets/Chat/message_bubble_widget.dart';" = "import 'package:jibble/features/chat/presentation/widgets/message_bubble_widget.dart';"

    # Post
    "import 'package:jibble/models/post_model.dart';" = "import 'package:jibble/features/post/data/models/post_model.dart';"
    "import 'package:jibble/services/post_service.dart';" = "import 'package:jibble/features/post/data/datasources/post_service.dart';"
    "import 'package:jibble/screens/create_post_page.dart';" = "import 'package:jibble/features/post/presentation/screens/create_post_page.dart';"
    "import 'package:jibble/widgets/post_card_widget.dart';" = "import 'package:jibble/features/post/presentation/widgets/post_card_widget.dart';"

    # Circle
    "import 'package:jibble/models/circle_member_model.dart';" = "import 'package:jibble/features/circle/data/models/circle_member_model.dart';"
    "import 'package:jibble/services/circle_service.dart';" = "import 'package:jibble/features/circle/data/datasources/circle_service.dart';"
    "import 'package:jibble/screens/Circle/circle_feed_page.dart';" = "import 'package:jibble/features/circle/presentation/screens/circle_feed_page.dart';"
    "import 'package:jibble/screens/Circle/circle_members_page.dart';" = "import 'package:jibble/features/circle/presentation/screens/circle_members_page.dart';"
    "import 'package:jibble/screens/Circle/circle_member_tile.dart';" = "import 'package:jibble/features/circle/presentation/screens/circle_member_tile.dart';"
    "import 'package:jibble/screens/Circle/circle_page.dart';" = "import 'package:jibble/features/circle/presentation/screens/circle_page.dart';"
    "import 'package:jibble/screens/Circle/placeholder_page.dart';" = "import 'package:jibble/features/circle/presentation/screens/placeholder_page.dart';"

    # Search
    "import 'package:jibble/models/user_search_model.dart';" = "import 'package:jibble/features/search/data/models/user_search_model.dart';"
    "import 'package:jibble/services/user_search_service.dart';" = "import 'package:jibble/features/search/data/datasources/user_search_service.dart';"
    "import 'package:jibble/screens/Search/search_page.dart';" = "import 'package:jibble/features/search/presentation/screens/search_page.dart';"
    "import 'package:jibble/screens/Search/user_search_result_widget.dart';" = "import 'package:jibble/features/search/presentation/widgets/user_search_result_widget.dart';"

    # Follow
    "import 'package:jibble/models/follow_model.dart';" = "import 'package:jibble/features/follow/data/models/follow_model.dart';"
    "import 'package:jibble/services/follow_service.dart';" = "import 'package:jibble/features/follow/data/datasources/follow_service.dart';"
    "import 'package:jibble/screens/Follow/follow_button_widget.dart';" = "import 'package:jibble/features/follow/presentation/widgets/follow_button_widget.dart';"
    "import 'package:jibble/screens/Follow/user_list_item_widget.dart';" = "import 'package:jibble/features/follow/presentation/widgets/user_list_item_widget.dart';"

    # Shared
    "import 'package:jibble/widgets/custom_bottom_nav_bar.dart';" = "import 'package:jibble/shared/widgets/custom_bottom_nav_bar.dart';"
    "import 'package:jibble/widgets/cached_image_widget.dart';" = "import 'package:jibble/shared/widgets/cached_image_widget.dart';"
}

foreach ($file in $files) {
    if ($file.Extension -ne ".dart") { continue }
    
    $content = Get-Content $file.FullName -Raw
    $modified = $false

    foreach ($key in $replacements.Keys) {
        $escapedKey = [regex]::Escape($key)
        if ($content -match $escapedKey) {
            $content = $content -replace $escapedKey, $replacements[$key]
            $modified = $true
        }
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Updated imports in $($file.Name)"
    }
}
