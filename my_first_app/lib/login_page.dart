
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'page/main_page.dart';

// ตรวจสอบสถานะล็อกอินและนำทางไปยังหน้าที่เหมาะสม
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainPage();
        }

        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วน';
      });
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        switch (e.code) {
          case 'weak-password':
            _error = 'รหัสผ่านสั้นเกินไป (ต้องไม่ต่ำกว่า 6 ตัวอักษร)';
            break;

          case 'email-already-in-use':
            _error = 'อีเมลนี้ถูกใช้งานไปแล้วในระบบ';
            break;

          case 'invalid-email':
            _error = 'รูปแบบของอีเมลไม่ถูกต้อง';
            break;

          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _error = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
            break;

          case 'operation-not-allowed':
            _error =
                'ยังไม่ได้เปิดใช้งานการเข้าสู่ระบบด้วย Email/Password ใน Firebase';
            break;

          case 'network-request-failed':
            _error = 'เชื่อมต่อเครือข่ายไม่สำเร็จ กรุณาลองอีกครั้ง';
            break;

          default:
            _error = 'เกิดข้อผิดพลาด (${e.code}): '
                '${e.message ?? 'ไม่ทราบสาเหตุ'}';
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Unexpected Auth Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = 'เกิดข้อผิดพลาดที่ไม่รู้จัก กรุณาลองอีกครั้ง';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Icon(
                Icons.book,
                size: 80,
                color: Colors.indigo,
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _submit();
                  }
                },
              ),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                        ),
                ),
              ),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _error = '';
                        });
                      },
                child: Text(
                  _isLogin
                      ? 'ยังไม่มีบัญชี? สมัครเลย'
                      : 'มีบัญชีแล้ว? เข้าสู่ระบบ',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
