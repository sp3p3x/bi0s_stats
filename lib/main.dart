import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

void main() {
  runApp(const Bi0sStatsApp());
}

class Bi0sStatsApp extends StatelessWidget {
  const Bi0sStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bi0s Stats',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _updateLabel(Map data) {
    String labelText = "";
    data.forEach((key, value) => labelText += '$key: $value\n');
    setState(() {
      statsController.text = labelText;
    });
  }

  _getStats() async {
    Map<String, String> data = {};
    final webScraper = WebScraper('https://ctftime.org');
    if (await webScraper.loadWebPage('/team/662')) {
      final ratingAndCountryPosition = webScraper.getElement(
        'div.container > div.tab-content > div.active > p',
        [],
      );

      String overallPosAndTeamRating = ratingAndCountryPosition[0]['title']
          .toString()
          .replaceAll('\n', '');
      String worldPosition = overallPosAndTeamRating.split(' ')[7];
      data['World Position'] = worldPosition;
      String teamPoints = overallPosAndTeamRating.split(' ')[13];
      data['Team Points'] = teamPoints;
      String countryPosition =
          ratingAndCountryPosition[1]['title'].toString().split(' ')[2];
      data['Country Position'] = countryPosition;

      _updateLabel(data);
      setState(() {
        isLoading = false;
      });
    } else {
      print('Cannot load url');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLoading = false;
  TextEditingController statsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("bi0s Stats"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _getStats();
              },
              child: Text('Check Stats'),
            ),
            Container(
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : TextField(
                        maxLines: null,
                        enabled: false,
                        textAlign: TextAlign.center,
                        controller: statsController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
