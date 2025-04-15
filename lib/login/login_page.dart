import 'package:flutter/material.dart';
import 'package:nsg_data/authorize/nsg_login_params.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_login/nsg_login.dart';

class LoginPage extends NsgLoginPage {
  LoginPage(NsgDataProvider provider, {super.key}) : super(provider, widgetParams: LoginPage.getWidgetParams);

  @override
  Widget getLogo() {
    var logo = Center(
        child: Transform.translate(
            offset: const Offset(0, -50),
            child: Transform.scale(
              scale: 2,
              child: Stack(
                children: [Image.asset('lib/assets/images/logo.png')],
              ),
            )));

    return logo;
  }

  @override
  Image getBackground() {
    var background = const Image(
      image: AssetImage('lib/assets/images/background.jpg'),
      fit: BoxFit.fill,
    );
    return background;
  }

  @override
  AppBar getAppBar(BuildContext context) {
    return AppBar(title: Text('Регистрация'.toUpperCase()), centerTitle: true);
  }

  static NsgLoginParams getWidgetParams() {
    return NsgLoginParams();
  }
}
