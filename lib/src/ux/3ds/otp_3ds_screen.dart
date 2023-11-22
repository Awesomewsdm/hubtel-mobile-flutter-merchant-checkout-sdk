import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hubtel_merchant_checkout_sdk/src/extensions/widget_extensions.dart';
import 'package:hubtel_merchant_checkout_sdk/src/platform/models/enroll_3ds_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core_ui/core_ui.dart';
import '../../resources/resources.dart';
import '../view_model/checkout_view_model.dart';

class WebCheckoutPageData {
  String jwt, orderId, reference;
  String? customData;
  String? html;

  WebCheckoutPageData({
    required this.jwt,
    required this.orderId,
    required this.reference,
    this.customData,
    this.html
  });
}

class CheckoutWebViewWidget extends StatefulWidget {
  // CheckoutPurchase checkoutPurchase;
  WebCheckoutPageData pageData;




  CheckoutWebViewWidget({
    Key? key,
    required this.pageData
  }) : super(key: key);

  @override
  State<CheckoutWebViewWidget> createState() => _CheckoutWebViewWidgetState();
}

class _CheckoutWebViewWidgetState extends State<CheckoutWebViewWidget> {
  late final WebViewController controller;


  late CheckoutViewModel viewModel;

  @override
  void initState() {
    super.initState();

    log('html:> ${widget.pageData.html}', name: '$runtimeType');

    controller = WebViewController()
      ..loadHtmlString(
        widget.pageData.html ?? "<h1>Please wait ...</h1>",
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DeviceCollectionComplete',
        onMessageReceived: (message) {
          if (message.message == CheckoutHtmlState.success.toString()) {
            // TODO : Go back and go to the check status screen
            Navigator.pop(context, true);

          } else if (message.message == CheckoutHtmlState.htmlLoadingFailed) {
            if (!mounted) return;
           Navigator.pop(context);

            widget.showErrorDialog(
              context: context,
              message: "Something unexpected happened",
            );
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      pageDecoration: PageDecoration(backgroundColor: Colors.transparent),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
