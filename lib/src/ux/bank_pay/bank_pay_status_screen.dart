

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hubtel_merchant_checkout_sdk/src/platform/models/checkout_completion_status.dart';
import '/src/core_ui/core_ui.dart';

import '../../platform/models/models.dart';
import '../../resources/checkout_drawables.dart';
import '../../resources/checkout_strings.dart';

class BankPayStatusScreen extends StatelessWidget {
  const BankPayStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Confirm Process',
      hideBackNavigation: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            CheckoutStrings.cancel,
            style: AppTextStyle.body2().copyWith(
              color: HubtelColors.crimson,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
      bottomNavigation: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          title: CheckoutStrings.okay.toUpperCase(),
          isEnabled: true,
          buttonAction: () => onOkayButtonClicked(context),
          isDisabledBgColor: HubtelColors.lighterGrey,
          disabledTitleColor: HubtelColors.grey,
          style: HubtelButtonStyle.solid,
          isEnabledBgColor: ThemeConfig.themeColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(CheckoutDrawables.transactionSuccessful),
              const SizedBox(height: Dimens.paddingSmall),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: CheckoutStrings.payAtBankBranch,
                  style: AppTextStyle.body2(),
                  children: <TextSpan>[
                    TextSpan(
                      text: CheckoutStrings.ghanaGov,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.themeColor,
                      ),
                    ),
                    TextSpan(
                      text: CheckoutStrings.paymentPlatform,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimens.paddingSmall),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: CheckoutStrings.bankPayStatusSteps1,
                  style: AppTextStyle.body2(),
                  children: <TextSpan>[
                    TextSpan(text: CheckoutStrings.bankPayStatusSteps2),
                    TextSpan(text: CheckoutStrings.bankPayStatusSteps3),
                    TextSpan(
                      text: CheckoutStrings.bankPayShortCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onOkayButtonClicked(BuildContext context) async {
    print(CheckoutRequirements.routeName);
    Navigator.pop(context);
    Navigator.pop(context);
    final checkoutStatus = CheckoutCompletionStatus(status: UnifiedCheckoutPaymentStatus.pending, transactionId: "");
    Navigator.pop(context, checkoutStatus);

  }
}
