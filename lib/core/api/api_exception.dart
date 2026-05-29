class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  final int statusCode;
  final String message;
  final String? code;

  bool get isUnauthorized => statusCode == 401;
  bool get isConflict => statusCode == 409;
  bool get isValidation => code == 'VALIDATION_ERROR';

  @override
  String toString() => 'ApiException($statusCode${code != null ? ' $code' : ''}): $message';
}
