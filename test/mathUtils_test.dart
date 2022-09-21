import 'package:pschool_math/utils/dataUtils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('check getFormatedRandom util function', () {
    num val = getFormatedRandom('9aa');
    expect(val, greaterThan(900));
    expect(val, lessThan(915));
  });
}
