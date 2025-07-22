# Project Rename Script

This script (`rename_project.sh`) allows you to easily rename your Flutter project from `flutter_boilerplate_template` to any snake_case name of your choice.

## Usage

1. **Run the script:**
   ```bash
   ./rename_project.sh
   ```

2. **Follow the prompts:**
   - Enter your desired project name in snake_case format (e.g., `my_awesome_app`)
   - Confirm the operation
   - The script will update all necessary files

3. **After completion:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build
   flutter run
   ```

## What it does

The script updates:
- ✅ Package name in `pubspec.yaml`
- ✅ App name and bundle identifiers across all platforms (Android, iOS, macOS, Linux, Windows, Web)
- ✅ Import statements in Dart files
- ✅ Configuration files for all platforms
- ✅ Documentation and README files

## Safety Features

- 🔒 **Input validation** - Only accepts valid snake_case names
- 📦 **Automatic backup** - Creates timestamped backup of all modified files
- 🗑️ **Self-deleting** - Removes itself after successful completion (optional)
- ✅ **Preview** - Shows what will be changed before proceeding

## Example

```
Current project: flutter_boilerplate_template
New project name: my_todo_app

Generated variations:
- Snake case: my_todo_app
- Camel case: myTodoApp
- Pascal case: MyTodoApp
```

## Requirements

- Bash shell (macOS/Linux)
- Valid Flutter project structure
- Write permissions in project directory

---

**Note:** This script will delete itself after successful completion to keep your project clean.
