import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test('should get trivia from the repository', () async {
    when(() => mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));
    final result = await usecase(NoParams());
    expect(result, Right(tNumberTrivia));
    verify(() => mockNumberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
