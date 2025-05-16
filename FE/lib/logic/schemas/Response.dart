//schemas/Response.dart
class NetworkResponse<T> {
  int statusCode;
  String? err;
  T? response;

  NetworkResponse.error(this.statusCode, this.err);
  NetworkResponse.success(this.statusCode, this.response);
}
