

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

}


// Local database failure
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String message =  " Local database failure"}) : super(message);
}


class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}