import 'dart:math';

String generateMathExpression(int minNumber, int maxNumber, {bool useAddition = true, bool useSubtraction = true, bool useMultiplication = true}) {
  if (minNumber >= maxNumber) {
    throw ArgumentError('minNumber must be smaller than maxNumber');
  }

  List<String> allowedOperations = [];
  if (useAddition) allowedOperations.add('+');
  if (useSubtraction) allowedOperations.add('-');
  if (useMultiplication) allowedOperations.add('*');

  if (allowedOperations.isEmpty) {
    final random = Random();
    var digit = minNumber + random.nextInt(maxNumber - minNumber + 1);
    return '$digit';
  } else {
    final random = Random();
    final selectedOperation = allowedOperations[random.nextInt(allowedOperations.length)];
    late int operand1, operand2;
    operand1 = minNumber + random.nextInt(maxNumber - minNumber + 1);
    operand2 = minNumber + random.nextInt(maxNumber - minNumber + 1);

    switch (selectedOperation) {
      case '+':
        break;
      case '-':
        do {} while (operand2 == operand1);
        if (operand1 > operand2) {
          int operandTemp = operand1;
          operand1 = operand2;
          operand2 = operandTemp;
        }
        break;
      case '*':
        break;
    }

    return '$operand2 $selectedOperation $operand1';
  }
}
