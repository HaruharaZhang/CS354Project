import 'package:cs354_project/home.dart';
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
  OutlineInputBorder emailInputBorder = OutlineInputBorder();
  OutlineInputBorder passwdInputBorder = OutlineInputBorder();
  OutlineInputBorder repeatPasswdInputBorder = OutlineInputBorder();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController repeatPasswdController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _repeatPasswdFocusNode = FocusNode();
  FocusNode _passwdFocusNode = FocusNode();

  String emailError = '';
  String passwdError = '';
  String repeatPasswdError = '';
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
    emailInputBorder = outlineInputBorder;
    passwdInputBorder = outlineInputBorder;
    repeatPasswdInputBorder = outlineInputBorder;
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        email = emailController.text;
        setState(() {
          if (email.isNotEmpty) {
            if (!RegExp(emailReg).hasMatch(email)) {
              emailError = 'wrong email format';
              emailInputBorder = errorLineInputBorder;
            } else {
              emailInputBorder = correctLineInputBorder;
            }
          } else {
            emailError = 'Please input the email address';
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
            passwdError = "password must longer than 8 character";
            passwdInputBorder = errorLineInputBorder;
          } else {
            passwdError = '';
            passwdInputBorder = correctLineInputBorder;
          }
        } else {
          passwdError = 'please input password';
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
              repeatPasswdError = 'repeat password is not the same';
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

  Future<User> set(email, password) async {
    UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final User user = result.user!;
    return user;
  }

  void jumpToAnotherPage(BuildContext context, Class) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Class,
        ));
  }

  createUser() async {
    _counter.value = '';
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwdController.text);
      user = result.user!;
      user.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _counter.value = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        _counter.value = 'The account already exists for that email';
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
      appBar: AppBar(title: const Text("Register Page")),
      body: Column(children: <Widget>[
        TextField(
          controller: emailController,
          focusNode: _emailFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          decoration: InputDecoration(
              icon: const Icon(Icons.email),
              hintText: AutofillHints.email,
              counterText: emailError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15),
              enabledBorder: emailInputBorder,
              focusedBorder: focusLineInputBorder),
        ),
        TextField(
          obscureText: true,
          controller: passwdController,
          focusNode: _passwdFocusNode,
          decoration: InputDecoration(
              hintText: AutofillHints.password,
              icon: const Icon(Icons.password),
              enabledBorder: passwdInputBorder,
              focusedBorder: focusLineInputBorder,
              counterText: passwdError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15)),
        ),
        TextField(
          obscureText: true,
          controller: repeatPasswdController,
          focusNode: _repeatPasswdFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          decoration: InputDecoration(
              icon: const Icon(Icons.repeat),
              hintText: 'repeat your password',
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
                  title: const Text('Verify email sent'),
                  content: const Text(
                      'We already send you an email with verify link, '
                      'please click the link to complete your register.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                          (route) => route == null),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              //返回的提示都写在createUser里面了
            }
          },
          child: Text("Sign up"),
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
