import 'dart:io';

void main() {
  final dir = Directory('lib');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('mq_colors.dart')) {
      final content = file.readAsStringSync();
      var newContent = content;
      
      // We will replace all darker charcoals with charcoal800
      newContent = newContent.replaceAll('MqColors.charcoal950', 'MqColors.charcoal800');
      newContent = newContent.replaceAll('MqColors.charcoal900', 'MqColors.charcoal800');
      newContent = newContent.replaceAll('MqColors.charcoal850', 'MqColors.charcoal800');
      
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Updated \${file.path}');
      }
    }
  }
}
