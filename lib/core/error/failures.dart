import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture/core/error/exception.dart';

abstract class Failure extends Equatable {}

// General failure
class SeverFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => [SeverFailure];
}

class CacheFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => [CacheFailure];
}
