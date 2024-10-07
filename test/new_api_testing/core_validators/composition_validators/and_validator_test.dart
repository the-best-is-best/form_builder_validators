import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

const String errorGt = 'error gt';
Validator<num> gt(num target) {
  return (num v) {
    return v > target ? null : errorGt;
  };
}

const String errorLtE = 'error lte';
Validator<num> ltE(num target) {
  return (num v) {
    return v <= target ? null : errorLtE;
  };
}

const String errorIsEven = 'error is even';
Validator<num> isEven() {
  return (num v) {
    if (v is int && v % 2 == 0) {
      return null;
    }
    return errorIsEven;
  };
}

void main() {
  group('Composition: and', () {
    test('Should validate using only one validator', () {
      final Validator<num> v1 = and(<Validator<num>>[gt(10)]);
      final Validator<num> v2 =
          and(<Validator<num>>[gt(10)], printErrorAsSoonAsPossible: false);

      expect(v1(9), errorGt);
      expect(v1(10), errorGt);
      expect(v1(11), isNull);

      expect(v2(9), errorGt);
      expect(v2(10), errorGt);
      expect(v2(11), isNull);
    });
    test('Should validate using two validators', () {
      final Validator<num> v1 = and(<Validator<num>>[gt(10), ltE(19)]);
      final Validator<num> v2 = and(<Validator<num>>[ltE(19), gt(10)],
          printErrorAsSoonAsPossible: false);

      expect(v1(9), errorGt);
      expect(v1(10), errorGt);
      expect(v1(11), isNull);
      expect(v1(18), isNull);
      expect(v1(19), isNull);
      expect(v1(20), errorLtE);

      expect(v2(9), errorGt);
      expect(v2(10), errorGt);
      expect(v2(11), isNull);
      expect(v2(18), isNull);
      expect(v2(19), isNull);
      expect(v2(20), errorLtE);
    });

    test(
        'Should validate if the input is even and a number greater than 4.6 and less than or equal to 9.0',
        () {
      final Validator<num> v1 =
          and([isEven(), gt(4.6), ltE(9.0)], printErrorAsSoonAsPossible: false);
      final Validator<num> v2 = and([ltE(9.0), gt(4.6), isEven()]);

      expect(v1(3), '$errorIsEven$andSeparatorTemporary$errorGt');
      expect(v1(4), errorGt);
      expect(v1(5), errorIsEven);
      expect(v1(6.0), errorIsEven);
      expect(v1(6), isNull);
      expect(v1(10.9), '$errorIsEven$andSeparatorTemporary$errorLtE');

      expect(v2(3), errorGt);
      expect(v2(4), errorGt);
      expect(v2(5), errorIsEven);
      expect(v2(6.0), errorIsEven);
      expect(v2(6), isNull);
      expect(v2(10.9), errorLtE);
    });

    test(
        'Should validate if the input is even, greater than 5 and divisible by 37 with custom prefix, suffix and separator.',
        () {
      const String prefix = 'prefix';
      const String suffix = 'suffix';
      const String separator = ' aNd ';
      const String errorDivBy37 = 'not divisible by 37';
      final Validator<int> v = and(
        <Validator<int>>[
          isEven(),
          gt(5),
          (int v) => v % 37 == 0 ? null : errorDivBy37
        ],
        printErrorAsSoonAsPossible: false,
        prefix: prefix,
        suffix: suffix,
        separator: separator,
      );

      expect(
          v(1),
          equals('$prefix${[
            errorIsEven,
            errorGt,
            errorDivBy37
          ].join(separator)}$suffix'));
      expect(v(2),
          equals('$prefix${[errorGt, errorDivBy37].join(separator)}$suffix'));
      expect(
          v(7),
          equals(
              '$prefix${[errorIsEven, errorDivBy37].join(separator)}$suffix'));
      expect(v(8), equals('$prefix${[errorDivBy37].join(separator)}$suffix'));
      expect(v(37), equals('$prefix${[errorIsEven].join(separator)}$suffix'));
      expect(v(74), isNull);
    });

    test('Should throw AssertionError when the validators input is empty', () {
      expect(() => and(<Validator<Object?>>[]), throwsAssertionError);
    });
  });
}
