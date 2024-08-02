import 'package:flutter/material.dart';

//package
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trackapp/config/config.dart';

//pages
import 'cardBanner.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _Banner();
}

class _Banner extends State<BannerPage> {
  final PageController _pageController = PageController();
  final List<Map<String, String>> _slides = [
    {
      'imagePath': 'json/route.json',
      'text': 'Instant Tracking',
      'text2':
          'Monitor dan lacak telepon genggam\nAnda tanpa instalasi perangkat GPS.'
    },
    {
      'imagePath': 'json/clock.json',
      'text': 'Live Tracking',
      'text2': 'Secara langsung dapat dilacak\ndari perangkat lain.'
    },
    {
      'imagePath': 'json/custom.json',
      'text': 'Customize Setting',
      'text2': 'Pengaturan dapat dikonfigurasi sesuai\nkebutuhan dan keinginan.'
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_pageController.page == _slides.length - 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return Slide(
                        imagePath: _slides[index]['imagePath']!,
                        text: _slides[index]['text']!,
                        text2: _slides[index]['text2']!,
                      );
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: _slides.length,
                  effect: const WormEffect(
                    dotHeight: 12.0,
                    dotWidth: 12.0,
                    activeDotColor: Color(0xffDC3545),
                  ), // your preferred effect
                ),
                SizedBox(height: SizeConfig.blockVertical * 5),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: SizeConfig.blockVertical * 2),
                    width: SizeConfig.blockHorizontal * 90,
                    height: SizeConfig.blockVertical * 6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffDC3545)),
                      onPressed: _onContinue,
                      child: Text(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        _pageController.hasClients &&
                                _pageController.page == _slides.length - 1
                            ? "Mengerti"
                            : "Lanjut",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 20.0,
              right: 20.0,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color.fromARGB(255, 10, 10, 10),
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
