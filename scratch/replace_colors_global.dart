import 'dart:io';

void main() {
  final dir = Directory('lib');
  final regex = RegExp(r'MqColors\.black(?![0-9a-zA-Z])');
  
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('mq_colors.dart')) {
      final content = file.readAsStringSync();
      var newContent = content;
      
      newContent = newContent.replaceAll(regex, 'MqColors.charcoal800');
      
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Updated \${file.path}');
      }
    }
  }
}
