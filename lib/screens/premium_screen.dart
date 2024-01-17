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
              const Text(
                'RentALPHA features only for Premium user',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 50,
              ),
              const ListTile(
                leading: Icon(Icons.location_on),
                title: Text(
                  'ALL LOCATIONS',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "Connect through any of our locations all over the world for unparalleled anonymity.",
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const ListTile(
                leading: Icon(Icons.speed),
                title: Text(
                  'TOP SPEED',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "Don't let safety in the way of enjoying app content at the highest level of quality.",
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const ListTile(
                leading: Icon(Icons.ads_click),
                title: Text(
                  'NO ADS',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(
                  "Get rid of all those banners and videos when you open the app.",
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
                        showConfirmationDialog(context, 'Purchase Premium', () async {
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
                      child: const Text(
                        'Rp.240.000,00 / month',
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
                        showConfirmationDialog(context, 'Cancel Subscription', () async {
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
                      child: const Text(
                        'Cancel Subscription',
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