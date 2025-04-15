// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../model/data_controller.dart';

// const List<String> _images = <String>[
//   'lib/assets/images/sv1.svg',
//   'lib/assets/images/sv2.svg',
//   'lib/assets/images/sv3.svg',
//   'lib/assets/images/sv4.svg',
//   'lib/assets/images/logo.svg'
// ];

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>

      ///
      _fadein,
      _translate,
      _opacity,
      _scale,
      _scale2,
      _scale3,
      _scale4,
      _translate3,
      _opacity5,
      _fadein1,
      _fadein2,
      _fadein3,
      _fadein4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kDebugMode ? 5000 : 5000),
    );

    _fadein = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _translate = Tween(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.5, curve: Curves.easeInOut),
      ),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 95),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 5)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0))));

    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.2, curve: Curves.easeInOut),
      ),
    );

    _scale2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _scale3 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 20),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -1.0, end: 1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5))));

    _translate3 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -1.0, end: 0.0).chain(CurveTween(curve: Curves.bounceInOut)),
          weight: 10)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _scale4 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.linear)),
          weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)),
          weight: 10)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _opacity5 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.35, curve: Curves.easeInOut),
      ),
    );

    _fadein2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.45, curve: Curves.easeInOut),
      ),
    );

    _fadein4 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.3, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        var controller = Get.find<DataController>();
        controller.splashAnimationFinished();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DataController>();
    double size;
    double textWidth;
    double getHeight = MediaQuery.of(context).size.height;
    double getWidth = MediaQuery.of(context).size.width;
    if (getWidth < getHeight) {
      size = getWidth - 60;
      textWidth = getWidth;
    } else {
      size = getHeight - 150;
      textWidth = getHeight;
    }
    // if (size > 500) {
    //   size = 500;
    // }

    BoxDecoration decorGreenGradient = BoxDecoration(
        gradient: LinearGradient(
      stops: const [0.0, 1.0],
      colors: [const Color.fromRGBO(129, 198, 56, 1), darken(darken(const Color.fromRGBO(129, 198, 56, 1)))],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
    ));

    BoxDecoration decorYellow = const BoxDecoration(
      color: Color.fromRGBO(129, 198, 56, 1),
      shape: BoxShape.circle,
    );
    BoxDecoration decorDarkGradient = BoxDecoration(
        gradient: LinearGradient(
          stops: const [0.0, 0.7],
          colors: [const Color.fromRGBO(129, 198, 56, 1), darken(const Color.fromRGBO(129, 198, 56, 1))],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3000));
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadein,
        builder: (ctx, ch) => Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(129, 198, 56, 1)),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                                alignment: Alignment.topCenter, scaleY: _scale2.value, child: Container(height: Get.height, decoration: decorGreenGradient)),
                            Transform.scale(
                              alignment: Alignment.center,
                              scale: _scale4.value,
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: decorDarkGradient,
                                  child: Container(width: size, height: size, decoration: decorYellow)),
                            ),
                            //  Transform.scale(scaleX: _scale3.value, child: Container(width: size - 20, height: size - 20, decoration: decorGreen)),
                            Transform.scale(
                              scale: _opacity5.value,
                              child: Opacity(
                                opacity: _opacity5.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.translate(
                                        offset: Offset(10, -size / 10),
                                        child: Container(
                                            width: size / 3,
                                            height: size / 3,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  stops: const [0.0, 1.0],
                                                  colors: [
                                                    lighten(const Color.fromRGBO(129, 198, 56, 1)),
                                                    darken(darken(const Color.fromRGBO(129, 198, 56, 1)))
                                                  ],
                                                  begin: FractionalOffset.topCenter,
                                                  end: FractionalOffset.bottomCenter,
                                                )))),
                                    SvgPicture.asset(
                                      'lib/assets/svg/logo1.svg',
                                      width: size / 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, size / 2 + 40),
                              child: Transform.scale(
                                scale: _opacity5.value,
                                child: SizedBox(
                                  width: textWidth - 40,
                                  height: size / 4,
                                  child: FittedBox(
                                    child: Text(
                                      'Когнитивные Тренировки'.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(height: 1.2, fontWeight: FontWeight.w900, fontSize: nsgtheme.sizeH1, color: nsgtheme.colorBase.c100),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              controller.obx(
                (state) => const SizedBox(),
                onLoading: FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      'Подключение к серверу...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onError: (s) => FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: ControlOptions.instance.colorWarning),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            'Проверьте интернет соединение',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
