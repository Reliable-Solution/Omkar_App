import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constant/app_constant.dart';

class WebViewControllerX extends GetxController {
  var isLoading = true.obs;
  late WebViewController webViewController;
  final String url;

  WebViewControllerX(this.url);

  @override
  void onInit() {
    super.onInit();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
            getFlutterToast('Failed to load page: ${error.description}', Colors.red);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<void> reload() async {
    await webViewController.reload();
  }
  // void reload() {
  //   webViewController.reload();
  // }
}
