class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.success(T data) => ApiResponse(success: true, data: data);
  factory ApiResponse.error(String message) => ApiResponse(success: false, message: message);
}
