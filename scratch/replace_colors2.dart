import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      var newContent = content;
      
      // We want to replace MqColors.black with MqColors.charcoal800
      // but only in lines that seem to be dark mode conditionals.
      // So let's replace all `MqColors.black` with `MqColors.charcoal800` IF the line contains `isDark` or `dark`.
      
      final lines = newContent.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('MqColors.black') && (lines[i].contains('isDark') || lines[i].contains('dark'))) {
          lines[i] = lines[i].replaceAll('MqColors.black', 'MqColors.charcoal800');
        }
      }
      
      newContent = lines.join('\n');
      
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Updated \${file.path}');
      }
    }
  }
}
