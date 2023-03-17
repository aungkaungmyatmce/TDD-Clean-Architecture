import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture/core/error/exception.dart';

abstract class Failure extends Equatable {}

// General failure
class ServerFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => [ServerFailure];
}

class CacheFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => [CacheFailure];
}
