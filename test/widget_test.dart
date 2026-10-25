import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/media_url.dart';
import 'package:e_smart/core/format/minor_price.dart';
import 'package:e_smart/core/widgets/brand_title.dart';

void main() {
  test('minor price uses integer math', () {
    expect(formatMinorPrice(1100, 'SAR'), '11.00 SAR');
    expect(formatMinorPrice(5, 'SAR'), '0.05 SAR');
    expect(formatMinorPrice(-1100, 'SAR'), '-11.00 SAR');
  });

  test('media urls keep absolute links and prefix relative paths', () {
    expect(
      resolveMediaUrl('https://cdn.example/a.jpg'),
      'https://cdn.example/a.jpg',
    );
    expect(
      resolveMediaUrl('/uploads/a.jpg'),
      'https://e-smart.nmo.marketing/uploads/a.jpg',
    );
    expect(resolveMediaUrl('  '), isNull);
  });

  testWidgets('brand title shows the store name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrandTitle())),
    );
    expect(find.text(AppCopy.brandName), findsOneWidget);
  });
}
