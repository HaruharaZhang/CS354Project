import 'package:cs354_project/reguist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      builder: EasyLoading.init(), //加载 EasyLoading选项
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String emailError = '';
  String passwdError = '';
  String email = '';
  var emailReg =
      '^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$';
  String userPwd = '';

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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  final ValueNotifier<String> _notify = ValueNotifier<String>('');

  @override
  void initState() {
    //显示加载框
    EasyLoading.show(status: 'Trying to login...');

    //验证当前用户是否已经登陆
    if (FirebaseAuth.instance.currentUser != null) {
      print("current user id is: ${FirebaseAuth.instance.currentUser?.uid}");
      print("current user name is: ${FirebaseAuth.instance.currentUser?.displayName}");

      //登陆成功提示
      EasyLoading.showSuccess('Welcome back, ${FirebaseAuth.instance.currentUser!.email}');

      //使用 Delay方法来延迟加载页面，否则会触发bug导致程序闪退
      Future.delayed(Duration.zero,(){
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
              builder: (context) => MapPage(),
            ), (route) => route == null);
      });
      EasyLoading.showError('Failed with auto-login');
    } else {
      EasyLoading.showError('Not user information found, please login');
    }


    emailInputBorder = outlineInputBorder;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        email = emailController.text;
        setState(() {
          if (!RegExp(emailReg).hasMatch(email)) {
            emailError = 'wrong email format';
            emailInputBorder = errorLineInputBorder;
          } else {
            emailInputBorder = correctLineInputBorder;
          }
        });
      } else {
        setState(() {
          emailError = '';
          emailInputBorder = outlineInputBorder;
        });
      }
    });
    super.initState();
  }

  login() async {
    if (emailController.text.isEmpty) {
      return false;
    } else {
      try {
        UserCredential result = await auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwdController.text);
        user = result.user!;
        if(!user.emailVerified){
          //提醒用户在邮箱中验证
          _notify.value = 'please verify your email address in your email inbox. If you cannot find the email, please check the spam.';
          return false;
        }
        return true;

      } on FirebaseAuthException catch (e){
        switch(e.code){
          case 'wrong-password':
            _notify.value = "the password is not match your email address";
            break;
          case 'user-not-found':
            _notify.value = "cannot find user with this email address";
            break;
        }
        return false;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),

      ),
      body: Column(children: <Widget>[
        const Text('Login with your email address',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                height: 5)),
        TextField(
          controller: emailController,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp("[a-zA-Z0-9@.]"), allow: true)
          ],
          focusNode: _focusNode,
          decoration: InputDecoration(
              hintText: AutofillHints.email,
              counterText: emailError,
              counterStyle: const TextStyle(color: Colors.red, fontSize: 15),
              icon: const Icon(Icons.email),
              enabledBorder: emailInputBorder,
              focusedBorder: focusLineInputBorder),
        ),
        TextField(
          obscureText: true,
          controller: passwdController,
          decoration: InputDecoration(
              hintText: AutofillHints.password,
              icon: const Icon(Icons.password),
              enabledBorder: outlineInputBorder,
              focusedBorder: focusLineInputBorder,
              counterText: passwdError,
              counterStyle: TextStyle(color: Colors.red, fontSize: 15)),
        ),
        ValueListenableBuilder<String>(
          builder: _buildWithValue,
          valueListenable: _notify,
        ),
        ElevatedButton(
          onPressed: () async {
            if (await login()) {

              //跳转页面，取消返回按钮
              //但是会导致安卓用户在点击返回之后直接退出app
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(),
                  ), (route) => route == null);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => HomePage(),
              //     ));
            } else {
              //Fluttertoast.showToast(msg: "fail!");
            }
          },
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterPage(),
                ));
          },
          child: const Text(
            'Register',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
