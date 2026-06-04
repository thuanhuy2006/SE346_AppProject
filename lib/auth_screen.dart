import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'app_settings.dart';
import 'sound_manager.dart';
import 'user_progress.dart';

enum AuthScreenMode { login, signup, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  AuthScreenMode _screenMode = AuthScreenMode.login;
  int _forgotPasswordStep = 1; // 1: Email, 2: OTP, 3: New Password
  bool _isLoading = false;

  // Hàm xử lý Authentication
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_screenMode == AuthScreenMode.login) {
        // Đăng nhập
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await UserProgress().syncFromFirebase(); // Đồng bộ tiến trình từ Firebase
        SoundManager.instance.speakJapanese("おめでとう"); // Âm thanh vui
      } else if (_screenMode == AuthScreenMode.signup) {
        // Đăng ký
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await UserProgress().syncFromFirebase(); // Đồng bộ tiến trình từ Firebase
        SoundManager.instance.speakJapanese("おめでとう");
      }
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      SoundManager.instance.vibrate('error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Lỗi xác thực"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper hàm gọi API tới Google Apps Script và xử lý redirect 302 thủ công
  Future<http.Response> _sendRequestToGas(Map<String, dynamic> body) async {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse(AppSettings.otpBackendUrl))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body)
        ..followRedirects = false; // Tắt tự động redirect để xử lý bằng tay

      final response = await client.send(request);
      
      // Google Apps Script chuyển hướng 302 để trả về kết quả
      if (response.statusCode == 302 || 
          response.statusCode == 301 || 
          response.statusCode == 303 || 
          response.statusCode == 307 || 
          response.statusCode == 308) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Gửi một yêu cầu GET đến link mới để nhận kết quả JSON
          final getResponse = await http.get(Uri.parse(redirectUrl));
          return getResponse;
        }
      }
      
      final responseBody = await response.stream.bytesToString();
      return http.Response(responseBody, response.statusCode, headers: response.headers);
    } finally {
      client.close();
    }
  }

  // Hàm gửi mã OTP qua backend Google Apps Script
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập email hợp lệ"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _sendRequestToGas({
        "action": "sendOtp",
        "email": email,
      });

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text("Đã gửi mã OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  "Hệ thống đã gửi mã OTP xác nhận đến email của bạn.\n\n"
                  "Vui lòng kiểm tra hộp thư (và cả thư mục Spam nếu không thấy).",
                  style: TextStyle(fontSize: 15),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _forgotPasswordStep = 2;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3366FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("Tiếp tục", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        } else {
          throw Exception(result['message'] ?? "Lỗi không xác định từ máy chủ");
        }
      } else {
        throw Exception("Lỗi kết nối máy chủ: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi gửi OTP: ${e.toString().replaceAll("Exception: ", "")}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm xác minh OTP qua backend Google Apps Script
  Future<void> _verifyOtp() async {
    final entered = _otpController.text.trim();
    final email = _emailController.text.trim();
    if (entered.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mã OTP phải gồm 6 chữ số"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _sendRequestToGas({
        "action": "verifyOtp",
        "email": email,
        "otp": entered,
      });

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _forgotPasswordStep = 3;
          });
        } else {
          throw Exception(result['message'] ?? "Mã OTP không chính xác.");
        }
      } else {
        throw Exception("Lỗi kết nối máy chủ: ${response.statusCode}");
      }
    } catch (e) {
      SoundManager.instance.vibrate('error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm đặt lại mật khẩu mới qua backend Google Apps Script
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu mới phải dài từ 6 ký tự trở lên"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _sendRequestToGas({
        "action": "resetPassword",
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      });

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Đổi mật khẩu thành công", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                content: const Text(
                  "Mật khẩu của bạn đã được đặt lại thành công.\n\n"
                  "Bây giờ bạn có thể đăng nhập bằng mật khẩu mới này.",
                  style: TextStyle(fontSize: 14),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _screenMode = AuthScreenMode.login;
                        _forgotPasswordStep = 1;
                        _emailController.clear();
                        _passwordController.clear();
                        _otpController.clear();
                        _newPasswordController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("Quay lại đăng nhập", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        } else {
          throw Exception(result['message'] ?? "Đổi mật khẩu thất bại.");
        }
      } else {
        throw Exception("Lỗi kết nối máy chủ: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = "Đăng nhập";
    String subtitleText = "Chào mừng trở lại!";
    if (_screenMode == AuthScreenMode.signup) {
      titleText = "Tạo tài khoản";
      subtitleText = "Bắt đầu hành trình mới.";
    } else if (_screenMode == AuthScreenMode.forgotPassword) {
      titleText = "Quên mật khẩu";
      subtitleText = "Khôi phục tài khoản của bạn";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3366FF), Color(0xFF56CCF2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icon/AppHocTiengNhat.png',
                        height: 110,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        titleText,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _screenMode == AuthScreenMode.forgotPassword
                      ? _buildForgotPasswordForm()
                      : _buildLoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final isLogin = _screenMode == AuthScreenMode.login;
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Mật khẩu",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        if (isLogin) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _screenMode = AuthScreenMode.forgotPassword;
                  _forgotPasswordStep = 1;
                });
              },
              child: const Text(
                "Quên mật khẩu?",
                style: TextStyle(
                  color: Color(0xFF3366FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 12),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    isLogin ? "VÀO HỌC NGAY" : "ĐĂNG KÝ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () {
            setState(() {
              _screenMode = isLogin
                  ? AuthScreenMode.signup
                  : AuthScreenMode.login;
            });
          },
          child: Text(
            isLogin
                ? "Chưa có tài khoản? Đăng ký"
                : "Đã có tài khoản? Đăng nhập",
            style: const TextStyle(
              color: Color(0xFF3366FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        if (_forgotPasswordStep == 1) ...[
          const Text(
            "Nhập địa chỉ email của bạn để nhận mã OTP khôi phục mật khẩu.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "GỬI MÃ OTP",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ] else if (_forgotPasswordStep == 2) ...[
          const Text(
            "Nhập mã OTP gồm 6 chữ số đã được gửi tới email của bạn.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: "Mã OTP",
              prefixIcon: Icon(Icons.security),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: const Text(
                "XÁC MINH OTP",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ] else if (_forgotPasswordStep == 3) ...[
          const Text(
            "Thiết lập mật khẩu mới cho tài khoản của bạn.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mật khẩu mới",
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "ĐỔI MẬT KHẨU",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        TextButton(
          onPressed: () {
            setState(() {
              _screenMode = AuthScreenMode.login;
              _forgotPasswordStep = 1;
            });
          },
          child: const Text(
            "Quay lại đăng nhập",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
