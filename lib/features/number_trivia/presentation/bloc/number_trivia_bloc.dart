import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import '../../../../core/util/input_converter.dart';
import 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Sever Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;
  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty());

  NumberTriviaState get initialState => Empty();

  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      yield* inputEither.fold((failure) async* {
        yield Error(message: _mapFailureToMessage(failure));
      }, (integer) async* {
        yield Loading();
        final failureOfTrivia =
            await getConcreteNumberTrivia(Params(number: integer));
        yield* _eitherLoadedOrErrorState(failureOfTrivia);
      });
    } else if (event is GetTriviaForRandomNumber) {
      yield Loading();
      final failureOfTrivia = await getRandomNumberTrivia(NoParams());
      yield* _eitherLoadedOrErrorState(failureOfTrivia);
    }
  }
}

Stream<NumberTriviaState> _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOfTrivia) async* {
  yield failureOfTrivia.fold(
      (failure) => Error(message: SERVER_FAILURE_MESSAGE),
      (trivia) => Loaded(trivia: trivia));
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexpected error';
  }
}

// class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
//   NumberTriviaBloc({
//     required GetConcreteNumberTrivia concrete,
//     required GetRandomNumberTrivia random,
//     required this.inputConverter,
//   })  : assert(concrete != null),
//         assert(random != null),
//         assert(inputConverter != null),
//         getConcreteNumberTrivia = concrete,
//         getRandomNumberTrivia = random,
//         super(Empty());
//
//   final GetConcreteNumberTrivia getConcreteNumberTrivia;
//   final GetRandomNumberTrivia getRandomNumberTrivia;
//   final InputConverter inputConverter;
//
//   @override
//   Stream<NumberTriviaState> mapEventToState(
//       NumberTriviaEvent event,
//       ) async* {
//     if (event is GetTriviaForConcreteNumber) {
//       final inputEither =
//       inputConverter.stringToUnsignedInteger(event.numberString);
//       yield* inputEither.fold(
//             (failure) async* {
//           yield Error(message: INVALID_INPUT_FAILURE_MESSAGE);
//         },
//             (integer) async* {
//           yield Loading();
//           final failureOrTrivia =
//           await getConcreteNumberTrivia(Params(number: integer));
//           yield* _eitherErrorOrLoadedState(failureOrTrivia);
//         },
//       );
//     } else if (event is GetTriviaForRandomNumber) {
//       yield Loading();
//       final failureOrTrivia = await getRandomNumberTrivia(NoParams());
//       yield* _eitherErrorOrLoadedState(failureOrTrivia);
//     }
//   }
//
//   Stream<NumberTriviaState> _eitherErrorOrLoadedState(
//       Either<Failure, NumberTrivia> either) async* {
//     yield either.fold(
//             (failure) => Error(message: _mapFailureToMessage(failure)),
//             (trivia) => Loaded(trivia: trivia));
//   }
//
//   String _mapFailureToMessage(Failure failure) {
//     // Instead of a regular 'if (failure is ServerFailure)...'
//     switch (failure.runtimeType) {
//       case ServerFailure:
//         return SERVER_FAILURE_MESSAGE;
//       case CacheFailure:
//         return CACHE_FAILURE_MESSAGE;
//       default:
//         return 'Unexpected Error';
//     }
//   }
// }
