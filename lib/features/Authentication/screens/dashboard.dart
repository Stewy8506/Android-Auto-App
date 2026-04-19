import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rider_app/common/sizes.dart';
import 'package:weather_icons/weather_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isDarkMode = true;

  Color get primaryText => isDarkMode ? Colors.white : Colors.black;
  Color get secondaryText => isDarkMode ? Colors.grey : Colors.black54;
  Color get cardColor =>
      isDarkMode ? const Color(0xFF1A1A1C) : Colors.grey[200]!;
  Color get surfaceColor => isDarkMode ? Colors.black : Colors.white;

  Color getRideColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0E0E10) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    color: primaryText,
                    onPressed: () {},
                  ),

                  const SizedBox(width: TSizes.md),

                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "MotoCircle",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bitcountPropSingle(
                          color: primaryText,
                          letterSpacing: 2,
                          fontSize: TSizes.fontXl,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: primaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: TSizes.md,
                    right: TSizes.md,
                  ),
                  child: Column(
                    children: [
                      //Weather Card
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(WeatherIcons.day_sunny),
                            ),

                            const SizedBox(width: TSizes.md),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Howrah, WB",
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w500,
                                      fontSize: TSizes.fontSm,
                                      color: primaryText,
                                    ),
                                  ),

                                  const SizedBox(height: TSizes.sm),
                                  // Rain + Visibility Row
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.thermostat,
                                        size: TSizes.md,
                                        color: secondaryText,
                                      ),

                                      const SizedBox(width: TSizes.xs),

                                      Text(
                                        "36°C",
                                        style: GoogleFonts.montserrat(
                                          color: secondaryText,
                                        ),
                                      ),

                                      const SizedBox(width: TSizes.md),

                                      Icon(
                                        WeatherIcons.raindrop,
                                        size: TSizes.md,
                                        color: secondaryText,
                                      ),
                                      const SizedBox(width: TSizes.xs),
                                      Text(
                                        "10%",
                                        style: TextStyle(color: secondaryText),
                                      ),
                                      const SizedBox(width: TSizes.md),
                                      Icon(
                                        Icons.remove_red_eye,
                                        size: TSizes.md,
                                        color: secondaryText,
                                      ),
                                      const SizedBox(width: TSizes.xs + 2),
                                      Text(
                                        "8 km",
                                        style: TextStyle(color: secondaryText),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: TSizes.sm),
                                ],
                              ),
                            ),

                            // Ride score circle
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? Color(0xFF0E0E10)
                                    : Colors.white,
                                border: Border.all(
                                  color: getRideColor(8),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "8/10",
                                      style: TextStyle(
                                        color: primaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Ride Score",
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: TSizes.fontXs,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Music Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: surfaceColor,
                              ),
                              child: const Icon(Icons.play_arrow),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Get Lucky",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: primaryText,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    "Daft Punk",
                                    style: TextStyle(color: secondaryText),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: 0.7,
                                    color: primaryText,
                                    backgroundColor: secondaryText.withAlpha(
                                      60,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.skip_previous),
                                      Icon(Icons.pause_circle_outline),
                                      Icon(Icons.skip_next),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Group Session
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "GROUP SESSION",
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                        color: secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Midnight Run [4/6]",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(40),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text("ACTIVE COMM"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                
                            _userTile("Kenji_88", "0.4 KM ahead"),
                    
                            _userTile("Sarah_Moto", "Trailing 1.2 KM"),                           

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "MUTE COMMS",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
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

            // Bottom Nav
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: cardColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.map, color: primaryText),
                  ),
                  Icon(Icons.group, color: secondaryText),
                  Icon(Icons.play_circle, color: secondaryText),
                  Icon(Icons.bar_chart, color: secondaryText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userTile(String name, String status) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: primaryText, fontWeight: FontWeight.w500),
            ),
          ),
          Text(status, style: TextStyle(color: secondaryText)),
        ],
      ),
    );
  }
}
