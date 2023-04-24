// ignore_for_file: use_build_context_synchronously

import 'package:assessment/blocs/auth_cubit/auth_cubit.dart';
import 'package:assessment/extentions.dart';
import 'package:assessment/screens/home_screen.dart';
import 'package:assessment/widgets/app_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assessment/utility/app_colors.dart';
import 'package:assessment/utility/app_dimens.dart';
import 'package:assessment/utility/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:loader_overlay/loader_overlay.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen(
      {super.key, required this.mobile, required this.countrycode});

  final String countrycode;
  final String mobile;

  @override
  State<VerificationScreen> createState() => _VerificationScreenPageState();
}

class _VerificationScreenPageState extends State<VerificationScreen> {
  String otp = "";
  late AppDimens appDimens;

  @override
  Widget build(BuildContext context) {
    appDimens = AppDimens(MediaQuery.of(context).size);

    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthVerificationLoading) {
            context.loaderOverlay.show();
          } else {
            context.loaderOverlay.hide();
          }

          if (state is AuthVerificationError) {
            Utility.showSnackbar(
              text: state.error,
              context: context,
              color: Colors.red,
            );
          } else if (state is AuthVerificationFBError) {
            Utility.showSnackbar(
              text: state.error.message ?? state.error.code,
              context: context,
              color: Colors.red,
            );
          } else if (state is AuthVerificationCodeSent) {
            Utility.showSnackbar(text: 'Code Sent', context: context);
          }
          if (state is AuthVerificationSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  user: state.user,
                ),
              ),
            );
          }
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: AppColors.blackColor,
              ),
              automaticallyImplyLeading: true,
              elevation: 0,
              backgroundColor: AppColors.whiteColor,
            ),
            body: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(appDimens.paddingw16),
                      child: Center(
                        child: Text(
                          "An SMS with the verification code has been sent to your registered mobile number",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: appDimens.text16,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: appDimens.paddingw16),
                      child: Visibility(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${widget.countrycode} ${widget.mobile}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.greyText,
                                fontSize: appDimens.text20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.edit),
                              color: AppColors.greyText,
                              iconSize: appDimens.iconsize,
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: appDimens.paddingw16),
                      child: Center(
                        child: Text(
                          "Enter 6 digits code",
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: appDimens.text12,
                          ),
                        ),
                      ),
                    ),
                    OtpTextField(
                      numberOfFields: 6,
                      focusedBorderColor: Colors.black,
                      cursorColor: Colors.black,
                      showFieldAsBox: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmit: (String code) {
                        setState(() {
                          otp = code;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Continue',
                      onTap: () async {
                        final result = await Connectivity().checkConnectivity();
                        if (result == ConnectivityResult.none) {
                          context.showConnectivityDialog();
                          return;
                        }
                        final authState = context.read<AuthCubit>().state;
                        if (authState is AuthVerificationCodeSent) {
                          context.read<AuthCubit>().signInWithPhoneNumber(
                              verificationId: authState.verificationId,
                              otp: otp);
                        }
                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: appDimens.paddingw6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Didn't receive SMS? ",
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: appDimens.text16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result =
                                  await Connectivity().checkConnectivity();
                              if (result == ConnectivityResult.none) {
                                context.showConnectivityDialog();
                                return;
                              }
                              context.read<AuthCubit>().verifyPhoneNumber(
                                  countrycode: widget.countrycode,
                                  mobileNumber: widget.mobile);
                            },
                            child: Text(
                              "Resend",
                              style: TextStyle(
                                color: AppColors.greyText,
                                fontSize: appDimens.text16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
