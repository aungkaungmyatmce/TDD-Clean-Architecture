part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();
}

class Empty extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class Loading extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  Loaded({required this.trivia}) : super();

  @override
  List<Object> get props => [];
}

class Error extends NumberTriviaState {
  final String message;

  Error({required this.message});

  @override
  List<Object> get props => [];
}
