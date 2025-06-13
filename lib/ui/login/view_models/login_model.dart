import 'package:flutter/widgets.dart';
import 'package:web3_links/main.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'

class LoginViewModel with ChangeNotifier{

  

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  bool _obscureText = true;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  get title => _title;
  get formKey  => _formKey;
  get obscureText => _obscureText;

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
 
  @override
  void dispose(){
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    appLogger.info('sub');
    if(_formKey.currentState!.validate()){
      String user = userNameController.text;
      String password = passwordController.text;

      final res = await supabaseClient.auth.signInWithPassword(
        email: user,
        password: password
      );
      appLogger.info(res.toString());
      // userNameController.clear();
      // passwordController.clear();
    }
   
    
    
  }
   
}