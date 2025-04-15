// import 'package:flutter/material.dart';
// import 'package:nsg_data/authorize/nsg_login_params.dart';

// import '../helper.dart';

// class LoginParams extends NsgLoginParams {
//   LoginParams()
//       : super(
//           cardColor: Colors.grey[100],
//           buttonSize: 32,
//           //headerMessage: 'ТИТАН 112',
//           headerMessageVisible: false,
//           headerMessageVerification: tran.login_headerMessageVerification,
//           descriptionMessegeVerificationPhone: tran.login_descriptionMessegeVerificationPhone('phone'),
//           textEnterPhone: tran.login_textEnterPhone,
//           textResendSms: tran.login_textResendSms,
//           textSendSms: tran.login_textSendSms,
//           textEnterCaptcha: tran.login_textEnterCaptcha,
//           textLoginSuccessful: tran.login_textLoginSuccessful,
//           textEnterCorrectPhone: tran.login_textEnterCorrectPhone,
//           textCheckInternet: tran.login_textCheckInternet,
//           appbar: false,
//           useCaptcha: false,
//           useEmailLogin: true,
//           textEnterEmail: tran.login_textEnterEmail,
//           descriptionMessegeVerificationEmail: tran.login_descriptionMessegeVerificationEmail('email'),
//           textRememberUser: tran.login_textRememberUser,
//           headerMessageLogin: tran.login_headerMessageLogin,
//           textConfirm: tran.login_textConfirm,
//           usePasswordLogin: true,
//           textEnterPassword: tran.enter_your_password,
//           textEnterPasswordAgain: tran.enter_your_password_again,
//           textEnterNewPassword: tran.enter_your_password_new,
//           textBackToEnterPage: tran.return_to_login_page,
//           textEnter: tran.login,
//           textEnterCode: tran.code,
//           textRegistration: tran.registerOrForgotPassword,
//           textReturnToLogin: tran.alreadyRegisteredOrLogin,
//         );

//   @override
//   String errorMessage(int statusCode) {
//     String message;
//     switch (statusCode) {
//       case 40101:
//         message = tran.login_error_40101;
//         break;
//       case 40102:
//         message = tran.login_error_40102;
//         break;
//       case 40103:
//         message = tran.login_error_40103;
//         break;
//       case 40104:
//         message = tran.login_error_40104;
//         break;
//       case 40105:
//         message = tran.login_error_40105;
//         break;
//       case 40201:
//         message = tran.login_error_40201;
//         break;
//       case 40300:
//         message = tran.login_error_40300;
//         break;
//       case 40301:
//         message = tran.login_error_40301;

//         break;
//       case 40302:
//         message = tran.login_error_40302;
//         break;
//       case 40303:
//         message = tran.login_error_40303;
//         break;
//       case 40304:
//         message = tran.incorrectLoginOrPassword;
//         break;
//       default:
//         message = statusCode == 0 ? '' : tran.login_error_default(statusCode);
//     }
//     return message;
//   }
// }
