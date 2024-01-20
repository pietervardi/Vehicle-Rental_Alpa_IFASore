import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/message.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    checkPremiumStatus();
  }

  // Check Premium Status
  Future<void> checkPremiumStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool premiumStatus = prefs.getBool('subscriptionStatus') ?? false;
    setState(() {
      isPremium = premiumStatus;
    });
  }

  Future<void> saveSubscriptionStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('subscriptionStatus', status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            final isDarkMode = provider.currentTheme == 'dark';

            return Semantics(
              onTapHint: 'semantics/global/back-button'.i18n(),
              child: Tooltip(
                message: 'screen_layout/tooltip/back'.i18n(),
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      NoAnimationPageRoute(
                        builder: (context) => const ScreenLayout(),
                      )
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            children: [
              Text(
                'premium_screen/title'.i18n(),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 50,
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text(
                  'premium_screen/location'.i18n(),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "premium_screen/location-subtitle".i18n(),
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: Icon(Icons.speed),
                title: Text(
                  'premium_screen/speed'.i18n(),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "premium_screen/speed-subtitle".i18n(),
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: Icon(Icons.ads_click),
                title: Text(
                  'premium_screen/ads'.i18n(),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "premium_screen/ads-subtitle".i18n(),
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              isPremium == false
                ?
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        showConfirmationDialog(context, 'premium_screen/purchase'.i18n(), () async {
                          await saveSubscriptionStatus(true);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              NoAnimationPageRoute(
                                builder: (context) => const ScreenLayout(),
                              ),
                            );
                          }
                        });
                      },
                      child: Text(
                        'premium_screen/purchase-button'.i18n(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      )
                    ),
                  )
                :
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        showConfirmationDialog(context, 'premium_screen/cancel'.i18n(), () async {
                          await saveSubscriptionStatus(false);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              NoAnimationPageRoute(
                                builder: (context) => const ScreenLayout(),
                              ),
                            );
                          }
                        });
                      },
                      child: Text(
                        'premium_screen/cancel'.i18n(),
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w900
                        ),
                      )
                    ),
                  ),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}