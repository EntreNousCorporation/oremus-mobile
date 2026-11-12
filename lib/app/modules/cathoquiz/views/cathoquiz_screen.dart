import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Affiche la page CathoQuiz dans un WebView. La page est chargee a chaque
/// ouverture du menu (le controller est (re)cree au build de l'ecran).
class CathoQuizScreen extends StatefulWidget {
  const CathoQuizScreen({Key? key}) : super(key: key);

  @override
  State<CathoQuizScreen> createState() => _CathoQuizScreenState();
}

class _CathoQuizScreenState extends State<CathoQuizScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(colorWhite)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            OremusLogger.error(
                'CathoQuiz WebView error => ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.CATHOQUIZ_URL));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
            // La WebView est embarquee dans le SimpleHiddenDrawer, qui capte
            // les gestes de glissement. Sans ces recognizers, le drag vertical
            // part vers le drawer et la page ne scrolle pas (surtout Android).
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
          ),
          if (_isLoading)
            Container(
              color: colorWhite,
              width: double.infinity,
              height: double.infinity,
              child: Center(child: LottieLoadingView(size: 120)),
            ),
        ],
      ),
    );
  }
}
