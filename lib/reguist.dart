import 'package:cs354_project/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => Register();
}

class Register extends State<RegisterPage> {
  OutlineInputBorder outlineInputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.grey, width: 2));
  OutlineInputBorder focusLineInputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.lightBlue, width: 2));
  OutlineInputBorder errorLineInputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.red, width: 2));
  OutlineInputBorder correctLineInputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.green, width: 2));

  OutlineInputBorder userNameInputBorder = OutlineInputBorder();
  OutlineInputBorder emailInputBorder = OutlineInputBorder();
  OutlineInputBorder passwdInputBorder = OutlineInputBorder();
  OutlineInputBorder repeatPasswdInputBorder = OutlineInputBorder();

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController repeatPasswdController = TextEditingController();

  FocusNode _userFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _repeatPasswdFocusNode = FocusNode();
  FocusNode _passwdFocusNode = FocusNode();

  String userNameError = '';
  String emailError = '';
  String passwdError = '';
  String repeatPasswdError = '';
  String userName = '';
  String email = '';
  String repeatPasswd = '';
  var emailReg =
      '^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$';
  String userPwd = '';
  String registerErr = '';

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  final ValueNotifier<String> _counter = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    userNameInputBorder = outlineInputBorder;
    emailInputBorder = outlineInputBorder;
    passwdInputBorder = outlineInputBorder;
    repeatPasswdInputBorder = outlineInputBorder;

    _userFocusNode.addListener(() {
      if (!_userFocusNode.hasFocus) {
        userName = userNameController.text;
        setState(() {
          if (userName.isNotEmpty) {
            if (userName.length < 8 && RegExp(emailReg).hasMatch(userName)) {
              userNameError = 'register_user_name_error'.tr();
              userNameInputBorder = errorLineInputBorder;
            } else {
              userNameInputBorder = correctLineInputBorder;
            }
          } else {
            userNameError = 'register_user_name_empty'.tr();
            userNameInputBorder = errorLineInputBorder;
          }
        });
      } else {
        setState(() {
          userNameError = '';
          userNameInputBorder = outlineInputBorder;
        });
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        email = emailController.text;
        setState(() {
          if (email.isNotEmpty) {
            if (!RegExp(emailReg).hasMatch(email)) {
              emailError = 'register_invalid_email'.tr();
              emailInputBorder = errorLineInputBorder;
            } else {
              emailInputBorder = correctLineInputBorder;
            }
          } else {
            emailError = 'register_empty_email'.tr();
            emailInputBorder = errorLineInputBorder;
          }
        });
      } else {
        setState(() {
          emailError = '';
          emailInputBorder = outlineInputBorder;
        });
      }
    });
    _passwdFocusNode.addListener(() {
      userPwd = passwdController.text;
      passwdError = '';
      if (!_passwdFocusNode.hasFocus) {
        if (userPwd.isNotEmpty) {
          if (userPwd.length < 8) {
            passwdError = "register_invalid_passwd".tr();
            passwdInputBorder = errorLineInputBorder;
          } else {
            passwdError = '';
            passwdInputBorder = correctLineInputBorder;
          }
        } else {
          passwdError = 'register_empty_passwd'.tr();
          passwdInputBorder = errorLineInputBorder;
        }
      }
    });
    _repeatPasswdFocusNode.addListener(() {
      if (!_repeatPasswdFocusNode.hasFocus) {
        repeatPasswd = repeatPasswdController.text;
        userPwd = passwdController.text;
        setState(() {
          if (repeatPasswd.isNotEmpty) {
            if (repeatPasswd != userPwd) {
              repeatPasswdError = 'register_invalid_repeat_passwd'.tr();
              repeatPasswdInputBorder = errorLineInputBorder;
            } else {
              repeatPasswdInputBorder = correctLineInputBorder;
            }
          }
        });
      } else {
        setState(() {
          repeatPasswdError = '';
          repeatPasswdInputBorder = outlineInputBorder;
        });
      }
    });
  }

  // Future<User> set(email, password) async {
  //   UserCredential result = await auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   final User user = result.user!;
  //   return user;
  // }
  //
  // void jumpToAnotherPage(BuildContext context, Class) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => Class,
  //       ));
  // }

  createUser() async {
    _counter.value = '';
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwdController.text);
      user = result.user!;
      user.sendEmailVerification();
      user.updateDisplayName(userName);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _counter.value = 'register_weak_passwd'.tr();
      } else if (e.code == 'email-already-in-use') {
        _counter.value = 'register_account_exist'.tr();
      }
      return false;
    } catch (e) {
      _counter.value = e.toString();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("register_title".tr())),
      body: Column(children: <Widget>[

        //用户名
        TextField(
          controller: userNameController,
          focusNode: _userFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          decoration: InputDecoration(
              icon: const Icon(Icons.supervised_user_circle),
              hintText: 'register_user_name_hit_text'.tr(),
              counterText: userNameError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15),
              enabledBorder: userNameInputBorder,
              focusedBorder: focusLineInputBorder),
        ),

        //用户Email
        TextField(
          controller: emailController,
          focusNode: _emailFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          decoration: InputDecoration(
              icon: const Icon(Icons.email),
              hintText: 'register_email_hit_text'.tr(),
              counterText: emailError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15),
              enabledBorder: emailInputBorder,
              focusedBorder: focusLineInputBorder),
        ),
        //用户密码
        TextField(
          obscureText: true,
          controller: passwdController,
          focusNode: _passwdFocusNode,
          decoration: InputDecoration(
              hintText: 'register_passwd_hit_text'.tr(),
              icon: const Icon(Icons.password),
              enabledBorder: passwdInputBorder,
              focusedBorder: focusLineInputBorder,
              counterText: passwdError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15)),
        ),
        //重复用户密码
        TextField(
          obscureText: true,
          controller: repeatPasswdController,
          focusNode: _repeatPasswdFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          decoration: InputDecoration(
              icon: const Icon(Icons.repeat),
              hintText: 'register_passwd_hit_text'.tr(),
              counterText: repeatPasswdError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15),
              enabledBorder: repeatPasswdInputBorder,
              focusedBorder: focusLineInputBorder),
        ),
        ValueListenableBuilder<String>(
          builder: _buildWithValue,
          valueListenable: _counter,
        ),
        ElevatedButton(
          onPressed: () async {
            //true - 成功，提示后返回home, false - 失败，无法登录
            if (await createUser()) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('register_email_send'.tr()),
                  content: Text("register_email_send_desc".tr()),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                          (route) => route == null),
                      child: Text('register_email_send_confirm'.tr()),
                    ),
                  ],
                ),
              );
            } else {
              //返回的提示都写在createUser里面了
            }
          },
          child: Text("register_sign_up_btn".tr()),
        ),
      ]),
    );
  }

  Widget _buildWithValue(BuildContext context, String str, Widget? child) {
    return Text(
      str,
      style: const TextStyle(color: Colors.red, fontSize: 18),
    );
  }
}
