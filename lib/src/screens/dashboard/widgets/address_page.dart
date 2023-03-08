import 'package:cake_wallet/entities/receive_page_option.dart';
import 'package:cake_wallet/src/screens/base_page.dart';
import 'package:cake_wallet/src/screens/dashboard/widgets/present_fee_picker.dart';
import 'package:cake_wallet/src/widgets/alert_with_two_actions.dart';
import 'package:cake_wallet/src/widgets/keyboard_done_button.dart';
import 'package:cake_wallet/themes/theme_base.dart';
import 'package:cake_wallet/utils/share_util.dart';
import 'package:cake_wallet/utils/show_pop_up.dart';
import 'package:cake_wallet/view_model/dashboard/address_page_view_model.dart';
import 'package:cake_wallet/view_model/dashboard/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cake_wallet/view_model/wallet_address_list/wallet_address_list_view_model.dart';
import 'package:cake_wallet/src/screens/receive/widgets/qr_widget.dart';
import 'package:cake_wallet/routes.dart';
import 'package:cake_wallet/generated/i18n.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:mobx/mobx.dart';

class AddressPage extends BasePage {
  AddressPage({
    required this.addressListViewModel,
    required this.walletViewModel,
    required this.addressPageViewModel,
  }) : _cryptoAmountFocus = FocusNode();

  final WalletAddressListViewModel addressListViewModel;
  final DashboardViewModel walletViewModel;
  final AddressPageViewModel addressPageViewModel;

  final FocusNode _cryptoAmountFocus;

  @override
  Color get backgroundLightColor =>
      currentTheme.type == ThemeType.bright ? Colors.transparent : Colors.white;

  @override
  Color get backgroundDarkColor => Colors.transparent;

  @override
  bool get resizeToAvoidBottomInset => false;

  bool effectsInstalled = false;

  @override
  Widget leading(BuildContext context) {
    final _backButton = Icon(
      Icons.arrow_back_ios,
      color: Theme.of(context).accentTextTheme.headline2!.backgroundColor!,
      size: 16,
    );

    return SizedBox(
      height: 37,
      width: 37,
      child: ButtonTheme(
        minWidth: double.minPositive,
        child: TextButton(
            // FIX-ME: Style
            //highlightColor: Colors.transparent,
            //splashColor: Colors.transparent,
            //padding: EdgeInsets.all(0),
            onPressed: () => onClose(context),
            child: _backButton),
      ),
    );
  }

  @override
  Widget middle(BuildContext context) =>
      PresentFeePicker(addressPageViewModel: addressPageViewModel);

  @override
  Widget Function(BuildContext, Widget) get rootWrapper =>
      (BuildContext context, Widget scaffold) => Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).primaryColor,
          ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          child: scaffold);

  @override
  Widget? trailing(BuildContext context) {
    final shareImage =
    Image.asset('assets/images/share.png',
        color: Theme.of(context).accentTextTheme!.headline2!.backgroundColor!);

    return !addressListViewModel.hasAddressList ? Material(
      color: Colors.transparent,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        iconSize: 25,
        onPressed: () {
          ShareUtil.share(
            text: addressListViewModel.address.address,
            context: context,
          );
        },
        icon: shareImage,
      ),
    ) : null;
  }

  @override
  Widget body(BuildContext context) {
    _setEffects(context);

    autorun((_) async {
      if (!walletViewModel.isOutdatedElectrumWallet ||
          !walletViewModel.settingsStore.shouldShowReceiveWarning) {
        return;
      }

      await Future<void>.delayed(Duration(seconds: 1));
      if (context.mounted) {
        await showPopUp<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertWithTwoActions(
                alertTitle: S.of(context).pre_seed_title,
                alertContent: S.of(context).outdated_electrum_wallet_receive_warning,
                leftButtonText: S.of(context).understand,
                actionLeftButton: () => Navigator.of(context).pop(),
                rightButtonText: S.of(context).do_not_show_me,
                actionRightButton: () {
                  walletViewModel.settingsStore.setShouldShowReceiveWarning(false);
                  Navigator.of(context).pop();
                });
          });
      }
    });

    return KeyboardActions(
        autoScroll: false,
        disableScroll: true,
        tapOutsideToDismiss: true,
        config: KeyboardActionsConfig(
            keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
            keyboardBarColor: Theme.of(context).accentTextTheme.bodyText1!.backgroundColor!,
            nextFocus: false,
            actions: [
              KeyboardActionsItem(
                focusNode: _cryptoAmountFocus,
                toolbarButtons: [(_) => KeyboardDoneButton()],
              )
            ]),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Observer(
                      builder: (_) => QRWidget(
                          addressListViewModel: addressListViewModel,
                          amountTextFieldFocusNode: _cryptoAmountFocus,
                          isAmountFieldShow: !addressListViewModel.hasAccounts,
                          isLight:
                              walletViewModel.settingsStore.currentTheme.type == ThemeType.light))),
              Observer(builder: (_) {
                return addressListViewModel.hasAddressList
                    ? GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(Routes.receive),
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 24, right: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                              border: Border.all(
                                  color: Theme.of(context).textTheme.subtitle1!.color!, width: 1),
                              color: Theme.of(context).buttonColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Observer(
                                  builder: (_) => Text(
                                        addressListViewModel.hasAccounts
                                            ? S.of(context).accounts_subaddresses
                                            : S.of(context).addresses,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .accentTextTheme
                                                .headline2!
                                                .backgroundColor!),
                                      )),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color:
                                    Theme.of(context).accentTextTheme.headline2!.backgroundColor!,
                              )
                            ],
                          ),
                        ),
                      )
                    : Text(S.of(context).electrum_address_disclaimer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).accentTextTheme.headline3!.backgroundColor!));
              })
            ],
          ),
        ));
  }

  void _setEffects(BuildContext context) {
    if (effectsInstalled) {
      return;
    }

    reaction((_) => addressPageViewModel.selectedReceiveOption, (ReceivePageOption option) {
      switch (option) {
        case ReceivePageOption.mainnet:
          Navigator.pop(context);
          break;
        case ReceivePageOption.anonPayInvoice:
          Navigator.pop(context);

          Navigator.pushReplacementNamed(
            context,
            Routes.anonPayInvoicePage,
            arguments: addressListViewModel.address.address,
          );
          break;
        default:
      }
    });

    effectsInstalled = true;
  }
}
