

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/dialogs/hb_prompt_dialog.dart';
import 'package:unified_checkout_sdk/core_ui/dialogs/hb_rounded_dialog.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';

extension WidgetExtension on StatefulWidget{

  showPromptDialog({
    required BuildContext context,
    required String title,
    required String buttonTitle,
    required String subtitle,
    required VoidCallback buttonAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => HBPromptDialog(
        title: title,
        subtitle: subtitle,
        buttonTitle: buttonTitle,
        buttonAction: buttonAction,
      ),
    );
  }

  showErrorDialog({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => HBRoundedDialog(
        padding: const EdgeInsets.all(Dimens.paddingDefault),
        borderRadius: Dimens.defaultBorderRadius,
        widget: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Error",
                style: AppTextStyle.headline3(),
              ),
              const SizedBox(
                height: Dimens.paddingNano,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  message,
                  style: AppTextStyle.body2().copyWith(
                    color: HubtelColors.errorColor,
                  ),
                ),
              ),
              const SizedBox(
                height: Dimens.paddingNano,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    CheckoutStrings.okay.toUpperCase(),
                    style: AppTextStyle.body2().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
