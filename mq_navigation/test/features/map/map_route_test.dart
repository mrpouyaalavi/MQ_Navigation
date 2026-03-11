import 'package:flutter_test/flutter_test.dart';
import 'package:mq_navigation/features/map/domain/entities/route_leg.dart';

void main() {
  group('MapRoute', () {
    test('parses Google Directions API response into route instructions', () {
      final route = MapRoute.fromJson({
        'status': 'OK',
        'routes': [
          {
            'overview_polyline': {'points': 'abc123'},
            'legs': [
              {
                'distance': {'value': 1450, 'text': '1.5 km'},
                'duration': {'value': 480, 'text': '8 mins'},
                'steps': [
                  {
                    'distance': {'value': 100, 'text': '100 m'},
                    'html_instructions': 'Head <b>north</b>',
                  },
                  {
                    'distance': {'value': 20, 'text': '20 m'},
                    'html_instructions': 'Turn <b>right</b>',
                  },
                ],
              },
            ],
          },
        ],
      }, TravelMode.walk);

      expect(route.travelMode, TravelMode.walk);
      expect(route.distanceMeters, 1450);
      expect(route.durationSeconds, 480);
      expect(route.encodedPolyline, 'abc123');
      expect(route.instructions, hasLength(2));
      expect(route.instructions.first.text, 'Head north');
    });
  });
}
