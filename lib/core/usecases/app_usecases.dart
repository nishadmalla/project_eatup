

import 'package:dartz/dartz.dart';
import 'package:project_eatup/core/error/failures.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}