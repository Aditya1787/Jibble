$lib = "d:\Uniclub\Application\jibble\lib"
# Create core folders
$coreFolders = "constants", "utils", "theme", "errors", "network", "services"
foreach ($f in $coreFolders) { New-Item -ItemType Directory -Force -Path "$lib\core\$f" }

# Create features and their internal layers
$features = "auth", "home", "profile", "chat", "post", "circle", "search", "follow", "notifications"
$layers = "data\models", "data\datasources", "data\repositories", "domain\entities", "domain\repositories", "domain\usecases", "presentation\screens", "presentation\widgets", "presentation\provider"
foreach ($f in $features) {
    foreach ($l in $layers) {
        New-Item -ItemType Directory -Force -Path "$lib\features\$f\$l"
    }
}

# Add onboarding screen folder to auth
New-Item -ItemType Directory -Force -Path "$lib\features\auth\presentation\screens\onboarding"

# Create shared folders
$sharedFolders = "widgets", "components"
foreach ($f in $sharedFolders) { New-Item -ItemType Directory -Force -Path "$lib\shared\$f" }

# Move core files
Move-Item -Path "$lib\config\supabase_config.dart" -Destination "$lib\core\network\"

# Move Auth files
Move-Item -Path "$lib\services\auth_service.dart" -Destination "$lib\features\auth\data\datasources\"
Move-Item -Path "$lib\services\first_launch_service.dart" -Destination "$lib\features\auth\data\datasources\"
Move-Item -Path "$lib\screens\Authentication\*" -Destination "$lib\features\auth\presentation\screens\"
Move-Item -Path "$lib\screens\splash\splash_screen.dart" -Destination "$lib\features\auth\presentation\screens\"
Move-Item -Path "$lib\screens\onboarding\*" -Destination "$lib\features\auth\presentation\screens\onboarding\"
Move-Item -Path "$lib\widgets\auth_gate.dart" -Destination "$lib\features\auth\presentation\widgets\"
Move-Item -Path "$lib\widgets\onboarding_gate.dart" -Destination "$lib\features\auth\presentation\widgets\"
Move-Item -Path "$lib\providers\auth_provider.dart" -Destination "$lib\features\auth\presentation\provider\"

# Move Home files
Move-Item -Path "$lib\screens\home_page.dart" -Destination "$lib\features\home\presentation\screens\"
Move-Item -Path "$lib\widgets\home_drawer.dart" -Destination "$lib\features\home\presentation\widgets\"
Move-Item -Path "$lib\providers\feed_provider.dart" -Destination "$lib\features\home\presentation\provider\"

# Move Profile files
Move-Item -Path "$lib\models\profile_model.dart" -Destination "$lib\features\profile\data\models\"
Move-Item -Path "$lib\services\profile_service.dart" -Destination "$lib\features\profile\data\datasources\"
Move-Item -Path "$lib\screens\Profile\*" -Destination "$lib\features\profile\presentation\screens\"

# Move Chat files
Move-Item -Path "$lib\models\chat_model.dart" -Destination "$lib\features\chat\data\models\"
Move-Item -Path "$lib\models\group_model.dart" -Destination "$lib\features\chat\data\models\"
Move-Item -Path "$lib\models\group_message_model.dart" -Destination "$lib\features\chat\data\models\"
Move-Item -Path "$lib\models\message_model.dart" -Destination "$lib\features\chat\data\models\"
Move-Item -Path "$lib\services\chat_service.dart" -Destination "$lib\features\chat\data\datasources\"
Move-Item -Path "$lib\services\group_service.dart" -Destination "$lib\features\chat\data\datasources\"
Move-Item -Path "$lib\screens\Chat\*" -Destination "$lib\features\chat\presentation\screens\"
Move-Item -Path "$lib\widgets\Chat\*" -Destination "$lib\features\chat\presentation\widgets\"

# Move Post files
Move-Item -Path "$lib\models\post_model.dart" -Destination "$lib\features\post\data\models\"
Move-Item -Path "$lib\services\post_service.dart" -Destination "$lib\features\post\data\datasources\"
Move-Item -Path "$lib\screens\create_post_page.dart" -Destination "$lib\features\post\presentation\screens\"
Move-Item -Path "$lib\widgets\post_card_widget.dart" -Destination "$lib\features\post\presentation\widgets\"

# Move Circle files
Move-Item -Path "$lib\models\circle_member_model.dart" -Destination "$lib\features\circle\data\models\"
Move-Item -Path "$lib\services\circle_service.dart" -Destination "$lib\features\circle\data\datasources\"
Move-Item -Path "$lib\screens\Circle\*" -Destination "$lib\features\circle\presentation\screens\"

# Move Search files
Move-Item -Path "$lib\models\user_search_model.dart" -Destination "$lib\features\search\data\models\"
Move-Item -Path "$lib\services\user_search_service.dart" -Destination "$lib\features\search\data\datasources\"
Move-Item -Path "$lib\screens\Search\search_page.dart" -Destination "$lib\features\search\presentation\screens\"
Move-Item -Path "$lib\screens\Search\user_search_result_widget.dart" -Destination "$lib\features\search\presentation\widgets\"

# Move Follow files
Move-Item -Path "$lib\models\follow_model.dart" -Destination "$lib\features\follow\data\models\"
Move-Item -Path "$lib\services\follow_service.dart" -Destination "$lib\features\follow\data\datasources\"
Move-Item -Path "$lib\screens\Follow\follow_button_widget.dart" -Destination "$lib\features\follow\presentation\widgets\"
Move-Item -Path "$lib\screens\Follow\user_list_item_widget.dart" -Destination "$lib\features\follow\presentation\widgets\"

# Move Shared files
Move-Item -Path "$lib\widgets\custom_bottom_nav_bar.dart" -Destination "$lib\shared\widgets\"
Move-Item -Path "$lib\widgets\cached_image_widget.dart" -Destination "$lib\shared\widgets\"

# Delete empty directories
$oldDirs = "config", "models", "providers", "screens", "services", "widgets"
foreach ($d in $oldDirs) {
    if (Test-Path "$lib\$d") {
        Remove-Item -Recurse -Force "$lib\$d"
    }
}
