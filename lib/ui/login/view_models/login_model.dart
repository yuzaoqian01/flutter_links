import 'package:flutter/widgets.dart';
import 'package:web3_links/main.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'

import 'package:web3_links/data/services/login_service.dart';

class LoginViewModel with ChangeNotifier{

  

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  bool _obscureText = true;
  bool _isLoading = false;
  String _errorMessage = '';

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  get title => _title;
  get formKey  => _formKey;
  get obscureText => _obscureText;
  get isLoading => _isLoading;
  get errorMessage => _errorMessage;

  LoginViewModel() {
    passwordController.addListener(() {
      notifyListeners(); // 每次文本变化通知UI更新
    });
  }

 

  void clearPasswordController(){
    passwordController.clear();
    notifyListeners();
  }

  void changeobscureText(){
    _obscureText = !_obscureText;
    notifyListeners();
  }


  void changeTitle(){
    _title = _title == 'home'?'login':'home';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
 
  @override
  void dispose(){
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    appLogger.info('开始登录流程');
    
    if(_formKey.currentState!.validate()){
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      try {
        String user = userNameController.text;
        String password = passwordController.text;
        
        appLogger.info('尝试登录用户: $user');
        final res = await loginWithEmail(user, password);
        
        if (res.user != null) {
          appLogger.info('登录成功: ${res.user!.email}');
          // 登录成功，清空输入框
          userNameController.clear();
          passwordController.clear();
          return true; // 返回登录成功
        } else {
          _errorMessage = '登录失败：用户信息无效';
          appLogger.warning('登录失败：用户信息无效');
          return false;
        }
      } catch (e) {
        _errorMessage = '登录失败：${e.toString()}';
        appLogger.error('登录异常: $e');
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
    return false;
  }
   
}