//by default language of the app
import 'package:eschool_saas_staff/data/models/appLanguage.dart';

const String defaultLanguageCode = "en";

//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
const List<AppLanguage> appLanguages = [
  // AppLanguage(languageCode: "en", languageName: "English"),
  AppLanguage(languageCode: "id", languageName: "Bahasa Indonesia"),
];
