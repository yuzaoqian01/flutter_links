import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:web3_links/ui/login/view_models/login_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loginViewModel.title, style: const TextStyle(fontSize: 16),),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: loginViewModel.formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/ic_launcher.png',
                width: 70,
                height: 70,
              ),
              const SizedBox(height: 64),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '请输入账号邮箱',
                        labelText: '账号邮箱',
                        hintStyle:  const TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle:  const TextStyle(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 0.5
                          ),
                          borderRadius: BorderRadius.circular(16)
                        )
                      ),
                      controller: loginViewModel.userNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入账号邮箱';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: loginViewModel.obscureText,
                      decoration:  InputDecoration(
                        hintText: '请输入密码',
                        labelText: '密码',
                        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 0.5
                          ),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (loginViewModel.passwordController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                padding: EdgeInsets.zero,  // 去掉默认内边距
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                onPressed: ()=> loginViewModel.clearPasswordController(),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,  // 去掉默认内边距
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                icon: Icon(
                                  loginViewModel.obscureText ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => loginViewModel.changeobscureText(),
                              ),
                          ],
                        )
                      ),
                      controller: loginViewModel.passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // 错误信息显示
              if (loginViewModel.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loginViewModel.errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red.shade600, size: 20),
                        onPressed: loginViewModel.clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // 设置背景色
                    foregroundColor: Colors.white, // 设置文字颜色（可选）
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40), // 设置圆角
                    ),
                  ),
                  onPressed: loginViewModel.isLoading ? null : () async {
                    final success = await loginViewModel.login();
                    // 检查context是否仍然挂载，避免在异步操作后使用已销毁的context
                    if (context.mounted && success) {
                      context.go('/home');
                    }
                  },
                  child: loginViewModel.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('登录')
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}