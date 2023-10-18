import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unified_checkout_sdk/core_ui/app_image_widget.dart';
import 'package:unified_checkout_sdk/custom_components/mobile_money_tile_field.dart';
import 'package:unified_checkout_sdk/utils/custom_expansion_widget.dart'
    as customExpansion;
import 'package:flutter/scheduler.dart';
import 'package:unified_checkout_sdk/core_ui/dimensions.dart';
import 'package:unified_checkout_sdk/core_ui/hubtel_colors.dart';
import 'package:unified_checkout_sdk/core_ui/text_style.dart';
import 'package:unified_checkout_sdk/custom_components/custom_indicator.dart';
import 'package:unified_checkout_sdk/platform/models/momo_provider.dart';
import 'package:unified_checkout_sdk/platform/models/wallet.dart';
import 'package:unified_checkout_sdk/resources/checkout_strings.dart';

import '../resources/checkout_drawables.dart';

class MobileMoneyExpansionTile extends StatefulWidget {
  static bool fetchFees = true;

  const MobileMoneyExpansionTile({
    super.key,
    required this.wallets,
    required this.providers,
    required this.mobileNumberController,
    required this.providerController,
    required this.onWalletSelected,
    required this.onProviderSelected,
    required this.controller,
    required this.onExpansionChanged,
    required this.isSelected,
    required this.selectedProviderMessage,
  });

  final List<Wallet> wallets;
  final List<MomoProvider> providers;
  final TextEditingController mobileNumberController;
  final TextEditingController providerController;
  final void Function(Wallet) onWalletSelected;
  final void Function(MomoProvider) onProviderSelected;
  final customExpansion.ExpansionTileController controller;
  final void Function(bool)? onExpansionChanged;
  final bool isSelected;
  final Widget selectedProviderMessage;

  @override
  State<MobileMoneyExpansionTile> createState() =>
      _MobileMoneyExpansionTileState();
}

class _MobileMoneyExpansionTileState extends State<MobileMoneyExpansionTile> {
  bool expandOptions = false;

  @override
  Widget build(BuildContext context) {
    // if(MobileMoneyExpansionTile.fetchFees == true) {
    //   if (widget.isSelected) {
    //     autoSelectFirstWallet();
    //   }
    // MobileMoneyExpansionTile.fetchFees = false;
    // }
    log("hereeeeee ${widget.wallets.length}",
        time: DateTime.now(), name: runtimeType.toString());
    return Column(
      children: [
        if (widget.isSelected) const SizedBox(height: Dimens.paddingDefault),

        //
        customExpansion.ExpansionTile(
          // tilePadding: EdgeInsets.symmetric(vertical: -10, horizontal: 16)
          controller: widget.controller,
          headerBackgroundColor: widget.isSelected
              // ? HubtelColors.teal.shade100
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.transparent,
          onExpansionChanged: widget.onExpansionChanged,
          title: Text(
            CheckoutStrings.mobileMoney,
            style: AppTextStyle.body2(),
          ),
          expandedAlignment: Alignment.topLeft,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: Dimens.paddingDefault,
            vertical: Dimens.paddingDefault,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImageWidget.local(
                image: const AssetImage(CheckoutDrawables.mtnMomoLogo),
                width: Dimens.iconMedium,
                height: Dimens.iconSmall,
                boxFit: BoxFit.contain,
                borderRadius: 0,
              ),
              const SizedBox(width: Dimens.paddingDefaultSmall),
              AppImageWidget.local(
                image: const AssetImage(CheckoutDrawables.vodafoneCashLogo),
                width: Dimens.iconSmall,
                height: Dimens.iconSmall,
                boxFit: BoxFit.contain,
                borderRadius: 0,
              ),
              const SizedBox(width: Dimens.paddingDefaultSmall),
              AppImageWidget.local(
                image: const AssetImage(CheckoutDrawables.airtelTigoLogo),
                width: Dimens.iconSmall,
                height: Dimens.iconSmall,
                boxFit: BoxFit.contain,
                borderRadius: 0,
              ),
            ],
          ),
          leading: CustomRadioIndicator(
            isSelected: widget.isSelected,
          ),
          leadingWidth: Dimens.iconMedium,
          titleAlignment: ListTileTitleAlignment.center,
          children: [
            Container(
              child: MobileMoneyTileField(
                fieldController: widget.mobileNumberController,
                onWalletSelected: widget.onWalletSelected,
                onProviderSelected: widget.onProviderSelected,
                wallets: widget.wallets,
                hintText: CheckoutStrings.mobileNumber,
              ),
            ),
            const SizedBox(height: Dimens.paddingDefault),
            Container(
              child: MobileMoneyTileField(
                fieldController: widget.providerController,
                onWalletSelected: widget.onWalletSelected,
                onProviderSelected: widget.onProviderSelected,
                providers: widget.providers,
                hintText: CheckoutStrings.mobileNetwork,
              ),
            ),
            const SizedBox(height: Dimens.paddingDefault),
            widget.selectedProviderMessage,
            // const SizedBox(height: AppDimens.paddingDefault),
          ],
        ),
      ],
    );
  }

  void autoSelectFirstWallet() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      var firstWallet = widget.wallets.firstOrNull;

      if (firstWallet != null) {
        widget.onWalletSelected.call(firstWallet);
        widget.mobileNumberController.text = firstWallet.accountNo ?? "";
        var provider = widget.providers
            .where((p) =>
                p.alias?.toLowerCase() == firstWallet.provider?.toLowerCase())
            .toList()
            .firstOrNull;
        if (provider != null) {
          widget.onProviderSelected.call(provider);
          widget.providerController.text = provider.name ?? "";
        }
      }
    });
  }
}
