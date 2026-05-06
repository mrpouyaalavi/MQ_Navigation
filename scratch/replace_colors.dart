import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      // Simple regex: replace `dark ? MqColors.black` with `dark ? MqColors.charcoal800`
      // and `isDark ? MqColors.black` with `isDark ? MqColors.charcoal800`
      // and `isDark ? Colors.black` with `isDark ? MqColors.charcoal800` (just in case)
      var newContent = content;
      newContent = newContent.replaceAll('dark ? MqColors.black', 'dark ? MqColors.charcoal800');
      newContent = newContent.replaceAll('isDark ? MqColors.black', 'isDark ? MqColors.charcoal800');
      newContent = newContent.replaceAll('dark ? Colors.black', 'dark ? MqColors.charcoal800');
      newContent = newContent.replaceAll('isDark ? Colors.black', 'isDark ? MqColors.charcoal800');
      
      // Also reverse matches
      newContent = newContent.replaceAll('MqColors.black : MqColors.red', 'MqColors.charcoal800 : MqColors.red');
      
      // What if it is `dark ? MqColors.black.withValues` ?
      // It's covered by the above!
      
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Updated \${file.path}');
      }
    }
  }
}
