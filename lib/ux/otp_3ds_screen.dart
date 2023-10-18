
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/extensions/widget_extensions.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebCheckoutPageData {
  String jwt, orderId, reference;
  String? customData;

  WebCheckoutPageData({
    required this.jwt,
    required this.orderId,
    required this.reference,
    this.customData,
  });
}

class CheckoutWebViewWidget extends StatefulWidget {
  // CheckoutPurchase checkoutPurchase;
  WebCheckoutPageData pageData;

  CheckoutWebViewWidget({
    Key? key,
    required this.pageData,
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


    controller = WebViewController()
      ..loadHtmlString(
        CheckoutStrings.continueCheckout(
          widget.pageData.orderId,
          widget.pageData.reference,
          widget.pageData.jwt,
          widget.pageData.customData,
        ),
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