import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/util/input_converter.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );

    registerFallbackValue(Params(number: 1));
  });

  test('initialState should be empty', () {
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test', number: 1);

    // test(
    //     'should call the InputConverter to validate and convert the String to an unsigned integer',
    //     () async {
    //   when(() => mockInputConverter.stringToUnsignedInteger(any()))
    //       .thenReturn(Right(tNumberParsed));
    //   bloc.add(GetTriviaForConcreteNumber(tNumberString));
    //   // await untilCalled(
    //   //     () => mockInputConverter.stringToUnsignedInteger(any()));
    //   verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
    // });

    // test('should emit [Error] when the input is invalid', () async {
    //   when(() => mockInputConverter.stringToUnsignedInteger(any()))
    //       .thenReturn(Left(InvalidInputFailure()));
    //   final expected = [
    //     Empty(),
    //     Error(message: INVALID_INPUT_FAILURE_MESSAGE),
    //   ];
    //   print(bloc.state);
    //   expectLater(bloc.state, emitsInOrder(expected));
    //   bloc.add(GetTriviaForConcreteNumber(tNumberString));
    // });

    // test('should get data from the concrete use case', () async {
    //   when(() => mockInputConverter.stringToUnsignedInteger(any()))
    //       .thenReturn(Right(tNumberParsed));
    //   when(() => mockGetConcreteNumberTrivia(any()))
    //       .thenAnswer((invocation) async => Right(tNumberTrivia));
    //   bloc.add(GetTriviaForConcreteNumber(tNumberString));
    //   await untilCalled(() => mockGetConcreteNumberTrivia(any()));
    //   verify(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    // });

    test('should emit [Loading,Loaded] when data is gotten successfully',
        () async {
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Right(tNumberParsed));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => Right(tNumberTrivia));
      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading,Error] when getting data fails', () async {
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(ServerFailure()));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => Right(tNumberTrivia));
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading,Error] with a proper message when getting data fails',
        () async {
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(CacheFailure()));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => Right(tNumberTrivia));
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
}
