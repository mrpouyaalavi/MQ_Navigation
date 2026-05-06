import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('mq_colors.dart')) {
      final content = file.readAsStringSync();
      var newContent = content;
      
      final lines = newContent.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if ((lines[i].contains('isDark') || lines[i].contains('dark')) && lines[i].contains('Colors.black')) {
          // If it matches dark ? Colors.black or isDark ? Colors.black
          lines[i] = lines[i].replaceAll('dark ? Colors.black', 'dark ? MqColors.charcoal800');
          lines[i] = lines[i].replaceAll('isDark ? Colors.black', 'isDark ? MqColors.charcoal800');
          // Reverse:
          lines[i] = lines[i].replaceAll('Colors.black : MqColors', 'MqColors.charcoal800 : MqColors');
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
