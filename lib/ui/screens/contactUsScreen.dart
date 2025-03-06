import 'dart:math';

import 'package:eschool_saas_staff/cubits/settingCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const ContactUsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String? cachedData;

  @override
  void initState() {
    context.read<SettingsCubit>().getSettings("contact_us");
    _loadCachedData;
    super.initState();
  }

  String generateRandomString(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String parseCustomHtml(String input) {
  String placeholderBold = generateRandomString(10);
  String placeholderItalic = generateRandomString(10);

  while (placeholderItalic == placeholderBold) {
    placeholderItalic = generateRandomString(10);
    placeholderBold = generateRandomString(10);
  }

  input = input
               .replaceAll('\\*', placeholderBold)
               .replaceAll('\\/', placeholderItalic);

  bool isBold = false;
  bool isItalic = false;
  String output = '';

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '*') {
      isBold = !isBold;
      output += isBold ? '<b>' : '</b>';
    } else if (input[i] == '/') {
      isItalic = !isItalic;
      output += isItalic ? '<i>' : '</i>';
    } else {
      output += input[i];
    }
  }

  output = output.replaceAll(placeholderBold, '*')
                 .replaceAll(placeholderItalic, '/')
                 .replaceAll("\n", "<br/>");

  return output;
}


  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedData = prefs.getString("contact_us");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<SettingsCubit, SettingsState>(
            listener: (context, state) {
      if (state is SettingsFailure) {
        Utils.showSnackBar(message: state.errorMessage, context: context);
      }
    }, builder: (context, state) {
      return PopScope(
        canPop: state is! SettingsProgress,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context) +
                        25),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    child: state is SettingsSuccess
                        ? HtmlWidget(
                            parseCustomHtml(state.data),
                          )
                        : const CustomCircularProgressIndicator()),
              ),
            ),
            Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(
                  titleKey: contactUsKey,
                  onBackButtonTap: () {
                    if (state is SettingsProgress) {
                      return;
                    }
                    Get.back();
                  },
                )),
          ],
        ),
      );
    }));
  }
}
