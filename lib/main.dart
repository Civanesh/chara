import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chara/fileuploadscreen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(223, 71, 71, 1), // Start color
                    Color.fromARGB(255, 229, 185, 124), // End color
                  ],
                  begin: Alignment.topLeft, // Gradient start position
                  end: Alignment.bottomRight, // Gradient end position
                ),
              ),
            ),
            // Main content with header and footer
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: const Text(
                    'Chara Technologies',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Expanded content (FileUploadScreen)
                const Expanded(
                  child: FileUploadScreen(),
                ),
                // Footer (Logo with link)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse('https://www.chara.co.in/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/images/Chara-Green_Logo.png',
                          fit: BoxFit.cover,
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
