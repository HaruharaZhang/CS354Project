import 'package:cs354_project/reguist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'GlobalVariable.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  //从全局变量中获取指定语言
  String userLanguage = await GlobalVariable.getUserLanguage();
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en'), Locale('zh')], //支持的语言列表
    path: 'assets/translations', // translations文件夹的路径
    fallbackLocale: Locale('en'), //用户所选语言不支持的时候，使用的语言
    startLocale: Locale(userLanguage), // 指定默认语言
    useOnlyLangCode: true,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //初始化语言设置相关
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      //主题颜色设置
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
    EasyLoading.show(status: 'main_trying_to_login'.tr());

    //验证当前用户是否已经登陆
    if (FirebaseAuth.instance.currentUser != null) {
      //showMsg();
      //登陆成功提示
      EasyLoading.showSuccess('main_welcome_back'
          .tr(args: ['${FirebaseAuth.instance.currentUser!.displayName}']));

      //使用 Delay方法来延迟加载页面，否则会触发bug导致程序闪退
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(),
            ),
            (route) => route == null);
      });
      EasyLoading.showError('main_auto_login_fail'.tr());
    } else {
      EasyLoading.showError('main_no_user_found'.tr());
    }

    emailInputBorder = outlineInputBorder;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        email = emailController.text;
        setState(() {
          if (!RegExp(emailReg).hasMatch(email)) {
            emailError = 'main_invalid_email_format'.tr();
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

  showMsg() async {
    print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, ru_RU]
    print(context.fallbackLocale); // output: en_US
    print("current user id is: ${FirebaseAuth.instance.currentUser?.uid}");
    print(
        "current user name is: ${FirebaseAuth.instance.currentUser?.displayName}");
    String? data = await FirebaseAuth.instance.currentUser?.getIdToken();
    String? userId = await FirebaseAuth.instance.currentUser?.uid;
    print("current user token is: $data");
    print("current user id is: $userId");
  }

  login() async {
    if (emailController.text.isEmpty) {
      return false;
    } else {
      try {
        UserCredential result = await auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwdController.text);
        user = result.user!;
        if (!user.emailVerified) {
          //提醒用户在邮箱中验证
          _notify.value = 'main_verify_email'.tr();
          return false;
        }
        return true;
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'wrong-password':
            _notify.value = "main_wrong_passwd".tr();
            break;
          case 'user-not-found':
            _notify.value = "main_user_not_found".tr();
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
        title: Text('main_title'.tr()),
      ),
      body: Column(children: <Widget>[
        Text('main_login_page_desc'.tr(),
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
            EasyLoading.show(status: 'main_trying_to_login'.tr());
            if (await login()) {
              EasyLoading.showSuccess('main_welcome_back'
                  .tr(args: ['${FirebaseAuth.instance.currentUser!.displayName}']));
              //跳转页面，取消返回按钮
              //但是会导致安卓用户在点击返回之后直接退出app
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                  (route) => route == null);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => HomePage(),
              //     ));
            } else {
              //Fluttertoast.showToast(msg: "fail!");
            }
          },
          child: Text(
            'main_login_btn'.tr(),
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
          child: Text(
            'main_register_btn'.tr(),
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
