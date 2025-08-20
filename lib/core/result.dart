sealed class Result<T> {
  const Result();

  R fold<R>(R Function(T) ok, R Function(Object, StackTrace?) err);
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  R fold<R>(R Function(T) ok, R Function(Object, StackTrace?) err) => ok(value);
}

class Err<T> extends Result<T> {
  const Err(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  R fold<R>(R Function(T) ok, R Function(Object, StackTrace?) err) =>
      err(error, stackTrace);
}

extension ResultX<T> on Result<T> {
  T get orThrow => fold((v) => v, (e, st) {
    if (e is Exception) {
      if (st != null) Error.throwWithStackTrace(e, st);
      throw e;
    }
    if (e is Error) {
      if (st != null) Error.throwWithStackTrace(e, st);
      throw e;
    }
    throw Exception(e.toString());
  });
}
