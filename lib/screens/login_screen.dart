// ignore_for_file: use_build_context_synchronously

import 'package:assessment/blocs/auth_cubit/auth_cubit.dart';
import 'package:assessment/extentions.dart';
import 'package:assessment/screens/verification_screen.dart';
import 'package:assessment/widgets/app_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:assessment/utility/app_colors.dart';
import 'package:assessment/utility/app_dimens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController textEditingController;
  late AppDimens appDimens;
  late Size size;
  String countryCode = '+91';
  String? errorText;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    appDimens = AppDimens(size);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
                maxHeight: size.height - MediaQuery.of(context).padding.top),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                const FlutterLogo(
                  size: 150,
                ),
                const Spacer(),
                Container(
                  margin: EdgeInsets.only(top: appDimens.paddingw2),
                  alignment: Alignment.center,
                  child: Text(
                    "Login or Register to continue",
                    style: TextStyle(
                      fontSize: appDimens.text20,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
                SizedBox(
                  height: appDimens.paddingw20,
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: appDimens.paddingw16 * 2,
                        right: appDimens.paddingw16 * 2,
                        bottom: appDimens.paddingw16 / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border:
                            Border.all(color: AppColors.blackColor, width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: <Widget>[
                          CountryCodePicker(
                            onChanged: (CountryCode code) {
                              setState(() {
                                countryCode = code.dialCode ?? '';
                              });
                            },
                            initialSelection: 'In',
                            favorite: const ['In'],
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            showFlag: false,
                          ),
                          Expanded(
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize: appDimens.text16,
                                  color: AppColors.greyText),
                              controller: textEditingController,
                              maxLength: 10,
                              decoration: InputDecoration(
                                hintText: "Mobile Number",
                                counterText: "",
                                hintStyle: TextStyle(color: AppColors.greyText),
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              onTap: () {
                                setState(() {
                                  errorText = null;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    if (errorText != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: appDimens.paddingw10,
                ),
                AppButton(
                  text: 'Continue',
                  onTap: onTapContinue,
                ),
                const Spacer(),
                const Spacer(),
                Container(
                  width: size.width,
                  margin: EdgeInsets.only(bottom: appDimens.paddingw16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: appDimens.paddingw18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onTapContinue() async {
    if (textEditingController.text.length == 10) {
      FocusScope.of(context).requestFocus(FocusNode());
      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        context.showConnectivityDialog();
        return;
      }
      context.read<AuthCubit>().verifyPhoneNumber(
          countrycode: "+91", mobileNumber: textEditingController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            mobile: textEditingController.text,
            countrycode: countryCode,
          ),
        ),
      );
    } else {
      setState(() {
        errorText = 'Invaild Mobile Number.';
      });
    }
  }
}
