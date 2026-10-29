import 'user_model.dart';

class LoginResponseModel {
  final String? message;
  final String? token;
  final String? tokenType;
  final UserModel? user;

  LoginResponseModel({
    this.message,
    this.token,
    this.tokenType,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponseModel(
      message: json['message'] as String?,
      token: data?['token'] as String?,
      tokenType: data?['token_type'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

