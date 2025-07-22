#!/bin/bash

# Project Renamer Script
# This script replaces flutter_boilerplate_template with a new snake_case project name
# and then deletes itself after completion

set -e

# ANSI color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate snake_case
validate_snake_case() {
    local name=$1
    if [[ ! $name =~ ^[a-z][a-z0-9_]*[a-z0-9]$ ]]; then
        if [[ ${#name} -eq 1 && $name =~ ^[a-z]$ ]]; then
            return 0  # Single letter is allowed
        fi
        return 1
    fi
    return 0
}

# Function to convert snake_case to camelCase
snake_to_camel() {
    local snake_case=$1
    echo $snake_case | sed -r 's/_([a-z])/\U\1/g'
}

# Function to convert snake_case to PascalCase
snake_to_pascal() {
    local snake_case=$1
    local camel_case=$(snake_to_camel $snake_case)
    echo "${camel_case^}"  # Capitalize first letter
}

# Function to backup a file before modification
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        cp "$file" "$file.backup"
        print_color $BLUE "📄 Backed up: $file"
    fi
}

# Function to replace text in file
replace_in_file() {
    local file=$1
    local old_text=$2
    local new_text=$3

    if [[ -f "$file" ]]; then
        if grep -q "$old_text" "$file"; then
            sed -i.tmp "s|$old_text|$new_text|g" "$file"
            rm "$file.tmp"
            print_color $GREEN "✅ Updated: $file"
        fi
    fi
}

# Function to rename directory
rename_directory() {
    local old_dir=$1
    local new_dir=$2

    if [[ -d "$old_dir" ]]; then
        mv "$old_dir" "$new_dir"
        print_color $GREEN "📁 Renamed directory: $old_dir -> $new_dir"
    fi
}

print_color $BLUE "
╔══════════════════════════════════════════════════════════════╗
║                    Flutter Project Renamer                   ║
║                                                              ║
║  This script will rename your Flutter project from          ║
║  'flutter_boilerplate_template' to your desired name        ║
╚══════════════════════════════════════════════════════════════╝
"

# Get current directory name
current_dir=$(basename "$(pwd)")
print_color $YELLOW "📍 Current directory: $current_dir"

# Prompt for new project name
while true; do
    print_color $YELLOW "
📝 Enter your new project name (snake_case only, e.g., my_awesome_app):"
    read -r new_project_name

    if [[ -z "$new_project_name" ]]; then
        print_color $RED "❌ Project name cannot be empty!"
        continue
    fi

    if validate_snake_case "$new_project_name"; then
        break
    else
        print_color $RED "❌ Invalid format! Please use snake_case (lowercase letters, numbers, underscores only)"
        print_color $YELLOW "   Valid examples: my_app, todo_list, awesome_project_2024"
        print_color $YELLOW "   Invalid examples: MyApp, my-app, myApp, 2project, _myapp"
    fi
done

# Generate different case variations
camel_case=$(snake_to_camel "$new_project_name")
pascal_case=$(snake_to_pascal "$new_project_name")

print_color $BLUE "
🔄 Project name variations:
   Snake case: $new_project_name
   Camel case: $camel_case
   Pascal case: $pascal_case
"

# Confirmation
print_color $YELLOW "⚠️  This will modify multiple files in your project. Continue? (y/N): "
read -r confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    print_color $RED "❌ Operation cancelled."
    exit 0
fi

print_color $GREEN "🚀 Starting project rename..."

# Create backup directory
backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
print_color $BLUE "📦 Created backup directory: $backup_dir"

# Files to update
declare -a files_to_update=(
    "README.md"
    "pubspec.yaml"
    "android/app/src/main/AndroidManifest.xml"
    "android/app/build.gradle"
    "ios/Runner/Info.plist"
    "ios/Runner.xcodeproj/project.pbxproj"
    "macos/Runner/Configs/AppInfo.xcconfig"
    "macos/Runner.xcodeproj/project.pbxproj"
    "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
    "linux/CMakeLists.txt"
    "linux/my_application.cc"
    "windows/CMakeLists.txt"
    "windows/runner/main.cpp"
    "windows/runner/Runner.rc"
    "web/manifest.json"
    "web/index.html"
    "test/widget_test.dart"
    "lib/core/di/service_locator.config.dart"
)

# Backup important files
print_color $BLUE "📦 Creating backups..."
for file in "${files_to_update[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$backup_dir/"
    fi
done

print_color $GREEN "🔄 Updating files..."

# Update pubspec.yaml
replace_in_file "pubspec.yaml" "name: flutter_boilerplate_template" "name: $new_project_name"

# Update README.md
replace_in_file "README.md" "# flutter_boilerplate_template" "# $new_project_name"
replace_in_file "README.md" "cd flutter_boilerplate_template" "cd $new_project_name"
replace_in_file "README.md" "xyz.marchell.flutter_boilerplate_template" "xyz.marchell.$new_project_name"

# Update Android files
replace_in_file "android/app/src/main/AndroidManifest.xml" "android:label=\"flutter_boilerplate_template\"" "android:label=\"$new_project_name\""
replace_in_file "android/app/build.gradle" "namespace \"xyz.marchell.flutter_boilerplate_template\"" "namespace \"xyz.marchell.$new_project_name\""
replace_in_file "android/app/build.gradle" "applicationId \"xyz.marchell.flutter_boilerplate_template\"" "applicationId \"xyz.marchell.$new_project_name\""

# Rename Android package directory and update package declarations
android_old_dir="android/app/src/main/kotlin/xyz/marchell/flutter_boilerplate_template"
android_new_dir="android/app/src/main/kotlin/xyz/marchell/$new_project_name"
if [[ -d "$android_old_dir" ]]; then
    rename_directory "$android_old_dir" "$android_new_dir"

    # Update package declarations in Kotlin files
    if [[ -f "$android_new_dir/MainActivity.kt" ]]; then
        replace_in_file "$android_new_dir/MainActivity.kt" "package xyz.marchell.flutter_boilerplate_template" "package xyz.marchell.$new_project_name"
    fi
    if [[ -f "$android_new_dir/MainApplication.kt" ]]; then
        replace_in_file "$android_new_dir/MainApplication.kt" "package xyz.marchell.flutter_boilerplate_template" "package xyz.marchell.$new_project_name"
    fi
fi

# Update iOS files
replace_in_file "ios/Runner/Info.plist" "<string>flutter_boilerplate_template</string>" "<string>$new_project_name</string>"
if [[ -f "ios/Runner.xcodeproj/project.pbxproj" ]]; then
    sed -i.tmp "s/xyz\.marchell\.flutterBoilerplateTemplate/xyz.marchell.$camel_case/g" "ios/Runner.xcodeproj/project.pbxproj"
    rm "ios/Runner.xcodeproj/project.pbxproj.tmp"
    print_color $GREEN "✅ Updated: ios/Runner.xcodeproj/project.pbxproj"
fi

# Update macOS files
replace_in_file "macos/Runner/Configs/AppInfo.xcconfig" "PRODUCT_NAME = flutter_boilerplate_template" "PRODUCT_NAME = $new_project_name"
replace_in_file "macos/Runner/Configs/AppInfo.xcconfig" "PRODUCT_BUNDLE_IDENTIFIER = xyz.marchell.flutterBoilerplateTemplate" "PRODUCT_BUNDLE_IDENTIFIER = xyz.marchell.$camel_case"

if [[ -f "macos/Runner.xcodeproj/project.pbxproj" ]]; then
    sed -i.tmp "s/flutter_boilerplate_template\.app/$new_project_name.app/g" "macos/Runner.xcodeproj/project.pbxproj"
    sed -i.tmp "s/flutter_boilerplate_template/$new_project_name/g" "macos/Runner.xcodeproj/project.pbxproj"
    sed -i.tmp "s/xyz\.marchell\.flutterBoilerplateTemplate/xyz.marchell.$camel_case/g" "macos/Runner.xcodeproj/project.pbxproj"
    rm "macos/Runner.xcodeproj/project.pbxproj.tmp"
    print_color $GREEN "✅ Updated: macos/Runner.xcodeproj/project.pbxproj"
fi

if [[ -f "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme" ]]; then
    sed -i.tmp "s/flutter_boilerplate_template\.app/$new_project_name.app/g" "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
    rm "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme.tmp"
    print_color $GREEN "✅ Updated: macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"
fi

# Update Linux files
replace_in_file "linux/CMakeLists.txt" "set(BINARY_NAME \"flutter_boilerplate_template\")" "set(BINARY_NAME \"$new_project_name\")"
replace_in_file "linux/CMakeLists.txt" "set(APPLICATION_ID \"xyz.marchell.flutter_boilerplate_template\")" "set(APPLICATION_ID \"xyz.marchell.$new_project_name\")"
replace_in_file "linux/my_application.cc" "gtk_header_bar_set_title(header_bar, \"flutter_boilerplate_template\");" "gtk_header_bar_set_title(header_bar, \"$new_project_name\");"
replace_in_file "linux/my_application.cc" "gtk_window_set_title(window, \"flutter_boilerplate_template\");" "gtk_window_set_title(window, \"$new_project_name\");"

# Update Windows files
replace_in_file "windows/CMakeLists.txt" "project(flutter_boilerplate_template LANGUAGES CXX)" "project($new_project_name LANGUAGES CXX)"
replace_in_file "windows/CMakeLists.txt" "set(BINARY_NAME \"flutter_boilerplate_template\")" "set(BINARY_NAME \"$new_project_name\")"
replace_in_file "windows/runner/main.cpp" "if (!window.Create(L\"flutter_boilerplate_template\", origin, size)) {" "if (!window.Create(L\"$new_project_name\", origin, size)) {"

if [[ -f "windows/runner/Runner.rc" ]]; then
    sed -i.tmp "s/flutter_boilerplate_template/$new_project_name/g" "windows/runner/Runner.rc"
    rm "windows/runner/Runner.rc.tmp"
    print_color $GREEN "✅ Updated: windows/runner/Runner.rc"
fi

# Update Web files
replace_in_file "web/manifest.json" "\"name\": \"flutter_boilerplate_template\"," "\"name\": \"$new_project_name\","
replace_in_file "web/manifest.json" "\"short_name\": \"flutter_boilerplate_template\"," "\"short_name\": \"$new_project_name\","
replace_in_file "web/index.html" "<meta name=\"apple-mobile-web-app-title\" content=\"flutter_boilerplate_template\">" "<meta name=\"apple-mobile-web-app-title\" content=\"$new_project_name\">"
replace_in_file "web/index.html" "<title>flutter_boilerplate_template</title>" "<title>$new_project_name</title>"

# Update test files
replace_in_file "test/widget_test.dart" "import 'package:flutter_boilerplate_template/main.dart';" "import 'package:$new_project_name/main.dart';"

# Update service locator config (if exists)
if [[ -f "lib/core/di/service_locator.config.dart" ]]; then
    sed -i.tmp "s/flutter_boilerplate_template/$new_project_name/g" "lib/core/di/service_locator.config.dart"
    rm "lib/core/di/service_locator.config.dart.tmp"
    print_color $GREEN "✅ Updated: lib/core/di/service_locator.config.dart"
fi

print_color $GREEN "
✅ Project rename completed successfully!

📋 Summary:
   Old name: flutter_boilerplate_template
   New name: $new_project_name

🔄 Next steps:
   1. Run 'flutter clean' to clear build cache
   2. Run 'flutter pub get' to update dependencies
   3. Run 'dart run build_runner build' to regenerate code
   4. Test your app: 'flutter run'

📦 Backup created in: $backup_dir
"

print_color $YELLOW "🗑️  This script will now delete itself. Continue? (y/N): "
read -r delete_confirm
if [[ $delete_confirm =~ ^[Yy]$ ]]; then
    script_path="$0"
    print_color $BLUE "🗑️  Deleting rename script..."
    rm "$script_path"
    print_color $GREEN "✅ Script deleted successfully!"
else
    print_color $BLUE "📝 Script kept at: $0"
fi

print_color $GREEN "
🎉 All done! Your project has been renamed to '$new_project_name'
   Happy coding! 🚀
"
