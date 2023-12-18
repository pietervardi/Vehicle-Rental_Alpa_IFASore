import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/screens/login_screen.dart';
import 'package:vehicle_rental/utils/colors.dart';

class OnboardModel {
  String img;
  String text;
  String desc;

  OnboardModel({
    required this.img,
    required this.text,
    required this.desc,
  });
}

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  int currentIndex = 0;
  late PageController _pageController;
  List<OnboardModel> screens = <OnboardModel>[
    OnboardModel(
      img: "assets/illustration/rent.jpg",
      text: "Rent Your Adventure Today",
      desc: "Experience the thrill of the open road with our user-friendly vehicle rental app, making it easy to find the perfect ride for your next adventure.",
    ),
    OnboardModel(
      img: "assets/illustration/drive.jpg",
      text: "Drive Your Dreams",
      desc: "Turn dreams into reality with our app's wide range of vehicles. Create unforgettable memories as you get behind the wheel.",
    ),
    OnboardModel(
      img: "assets/illustration/journey.jpg",
      text: "Journey with Confidence",
      desc: "Explore the world with peace of mind using our app, known for its unwavering commitment to safety and quality, ensuring worry-free journeys.",
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _storeOnboardInfo() async {
    int isViewed = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: whiteText,
        appBar: AppBar(
          backgroundColor: whiteText,
          elevation: 0,
          actions: [
            Semantics(
              onTapHint: 'semantics/onboard_screen/skip'.i18n(),
              child: TextButton(
                onPressed: () {
                  _storeOnboardInfo();
                  Navigator.pushReplacement(
                    context, MaterialPageRoute(
                      builder: (context) => const LoginScreen()
                    )
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: gray,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PageView.builder(
            itemCount: screens.length,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'semantics/onboard_screen/image'.i18n(),
                    child: Image.asset(screens[index].img)
                  ),
                  Semantics(
                    label: 'semantics/onboard_screen/text'.i18n(),
                    child: Text(
                      screens[index].text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: black,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'semantics/onboard_screen/description'.i18n(),
                    child: Text(
                      screens[index].desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        color: black,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'semantics/onboard_screen/page'.i18n(),
                    child: SizedBox(
                      height: 10,
                      child: ListView.builder(
                        itemCount: screens.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: currentIndex == index ? 25 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentIndex == index
                                    ? brown
                                    : brown2,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ]
                          );
                        },
                      ),
                    ),
                  ),
                  Semantics(
                    onTapHint: 'semantics/onboard_screen/button'.i18n(),
                    child: InkWell(
                      onTap: () async {
                        if (index == screens.length - 1) {
                          await _storeOnboardInfo();
                          if (mounted) {
                            Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => const LoginScreen())
                            );
                          }
                        }
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13
                        ),
                        decoration: BoxDecoration(
                          color: orange,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Text(
                              currentIndex == screens.length - 1 
                                ? 'GET STARTED' 
                                : 'NEXT',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: whiteText,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}