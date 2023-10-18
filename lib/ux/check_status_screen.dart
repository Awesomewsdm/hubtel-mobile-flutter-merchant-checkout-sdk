import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:unified_checkout_sdk/core_ui/app_page.dart';
import 'package:unified_checkout_sdk/core_ui/custom_button.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_payment_status_response.dart';
import 'package:unified_checkout_sdk/platform/models/checkout_requirements.dart';
import 'package:unified_checkout_sdk/platform/models/momo_response.dart';
import 'package:unified_checkout_sdk/platform/models/payment_status.dart';
import 'package:unified_checkout_sdk/unified_checkout_sdk.dart';
import 'package:unified_checkout_sdk/ux/viewModel/checkout_view_model.dart';
import '../core_ui/loading_indicator.dart';
import '../resources/checkout_drawables.dart';
import '../resources/checkout_strings.dart';
import 'package:async/async.dart';



class CheckStatusScreen extends StatefulWidget {

  final MomoResponse checkoutResponse;

  final viewModel = CheckoutViewModel();

  Function(PaymentStatus) checkoutCompleted;

  CheckStatusScreen({
    super.key, required this.checkoutResponse,
    required this.checkoutCompleted
  });

  @override
  State<CheckStatusScreen> createState() => _CheckStatusScreenState();
}

class _CheckStatusScreenState extends State<CheckStatusScreen> {
  // late PaymentStatusViewModel paymentStatusViewModel;
  PaymentStatus paymentStatus = PaymentStatus.unspecified;
  String paymentStatusErrorMessage = 'Transaction Failed';
  late CheckoutOrderStatus checkoutOrderStatus;
  bool showPendingTimer = false;
  int timeLeft = 5;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // paymentStatusViewModel = context.read<PaymentStatusViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: CheckoutStrings.processingPayment,
      hideBackNavigation: true,
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: Text(
            CheckoutStrings.cancel,
            style: AppTextStyle.body2().copyWith(
              color: HubtelColors.crimson,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      ],
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: isLoading
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  SizedBox(height: 24.0),
                  Text('Checking status...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
                  : switch (paymentStatus) {
                PaymentStatus.unspecified => paymentStatusContent(
                  assetPath: CheckoutDrawables.processingPayment,
                  description: CheckoutStrings.yourPaymentIsBeingProcessed,
                ),
                PaymentStatus.unpaid => paymentStatusContent(
                  assetPath: CheckoutDrawables.transactionError,
                  description: paymentStatusErrorMessage,
                ),
                PaymentStatus.paid => paymentStatusContent(
                  assetPath: CheckoutDrawables.transactionSuccessful,
                  description: CheckoutStrings.transactionSuccessful,
                ),
                PaymentStatus.pending => paymentStatusContent(
                  assetPath: CheckoutDrawables.transactionPending,
                  description: CheckoutStrings.yourPaymentIsBeingProcessedCheckAgain,
                ),
                PaymentStatus.expired => paymentStatusContent(
                  assetPath: CheckoutDrawables.transactionError,
                  description: paymentStatusErrorMessage,
                ),
                PaymentStatus.failed => paymentStatusContent(
                  assetPath: CheckoutDrawables.transactionError,
                  description: paymentStatusErrorMessage,
                )

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: Dimens.paddingSmall,
              left: Dimens.paddingDefault,
              right: Dimens.paddingDefault,
              bottom: 13.0,
            ),
            child: CustomButton(
                width: double.infinity,
                title: switch (paymentStatus) {
                  PaymentStatus.unspecified => CheckoutStrings.iHavePaid,
                  PaymentStatus.paid => CheckoutStrings.done.toUpperCase(),
                  PaymentStatus.unpaid => CheckoutStrings.done.toUpperCase(),
                  PaymentStatus.expired => CheckoutStrings.done.toUpperCase(),
                  PaymentStatus.failed => CheckoutStrings.done.toUpperCase(),
                  PaymentStatus.pending => showPendingTimer
                      ? CheckoutStrings.checkAgainTimeLeft(timeLeft: timeLeft).toUpperCase()
                      : CheckoutStrings.checkAgain.toUpperCase(),
                },
                buttonAction: onButtonClick,
                isDisabledBgColor: const Color(0xFFF8F9FB),
                disabledTitleColor: const Color(0xFF9CABB8),
                style: HubtelButtonStyle.solid,
                isEnabledBgColor: HubtelColors.teal[500],
                isEnabled: !showPendingTimer || paymentStatus == PaymentStatus.paid),
          )
        ],
      ),
    );
  }

  void startTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (timeLeft > 0) setState(() => timeLeft--);
        if (timeLeft == 0) {
          timer.cancel();
          showPendingTimer = false;
          setState(() => timeLeft = 5);
        }
      },
    );
  }

  Widget paymentStatusContent({
    required String assetPath,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(assetPath),
        const SizedBox(height: 24.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 53.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyle.body2(),
          ),
        )
      ],
    );
  }

  onButtonClick() async {
    final isPaymentStatusPaidOrFailed =
        paymentStatus == PaymentStatus.paid || paymentStatus == PaymentStatus.failed;

    if (paymentStatus == PaymentStatus.paid) {
      Navigator.popUntil(context,  ModalRoute.withName(CheckoutRequirements.routeName));
      widget.checkoutCompleted.call(PaymentStatus.paid);
      return;
    }

    if (paymentStatus == PaymentStatus.failed) {
      Navigator.popUntil(context,  ModalRoute.withName(CheckoutRequirements.routeName));
      widget.checkoutCompleted.call(paymentStatus);
      return;
    }

    if (paymentStatus == PaymentStatus.pending || paymentStatus == PaymentStatus.unpaid) {
      startTimer();
      setState(() => showPendingTimer = true);
    }

    final clientReference = widget.checkoutResponse.clientReference ?? "";
    setState(() => isLoading = true);
    final status = await widget.viewModel.checkStatus(clientReference: clientReference);
    setState(() {
      paymentStatus = status.data?.paymentStatus ?? PaymentStatus.pending;
      paymentStatusErrorMessage = paymentStatus == PaymentStatus.failed
          ? status.data?.providerDescription ?? ''
          : CheckoutStrings.somethigWentWrong;
      checkoutOrderStatus = status.data ?? CheckoutOrderStatus();
      isLoading = false;
    });
  }
}
