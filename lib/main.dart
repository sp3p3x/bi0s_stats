import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';
import 'dart:io';

void main() {
  runApp(const Bi0sStatsApp());
}

class Bi0sStatsApp extends StatelessWidget {
  const Bi0sStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bi0s Stats',
      theme: ThemeData.from(
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
        ),
      ),
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
  bool isLoading = true;
  TextEditingController statsController = TextEditingController();
  List<Widget> teamStatListItems = [];
  List<Widget> teamTop10ListItems = [];
  Widget mainWidget = Center();
  int _selectedIndex = 0;

  _addListTile(
    List<Widget> list,
    IconData icon,
    String title,
    String subtitle,
  ) {
    list.add(
      ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        tileColor: Colors.teal.shade900,
        leadingAndTrailingTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        titleTextStyle: TextStyle(color: Colors.white60, fontSize: 13),
        iconColor: Colors.white70,
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(subtitle),
      ),
    );
  }

  _getStats() async {
    final webScraper = WebScraper('https://ctftime.org');
    if (await webScraper.loadWebPage('/team/662')) {
      // scrapte team stats
      final ratingAndCountryPosition = webScraper.getElement(
        'div.container > div.tab-content > div.active > p',
        [],
      );

      String overallPosAndTeamRating = ratingAndCountryPosition[0]['title']
          .toString()
          .replaceAll('\n', '');
      String worldPosition = overallPosAndTeamRating.split(' ')[7];
      String teamPoints = overallPosAndTeamRating.split(' ')[13];
      String countryPosition =
          ratingAndCountryPosition[1]['title'].toString().split(' ')[2];

      teamStatListItems.add(
        ListTile(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
          title: Text("Current Team Stats"),
        ),
      );
      teamStatListItems.add(
        const Divider(color: Colors.white, height: 3, thickness: 2),
      );
      _addListTile(
        teamStatListItems,
        Icons.public,
        "World Position",
        worldPosition,
      );
      _addListTile(
        teamStatListItems,
        Icons.flag,
        "Country Position",
        countryPosition,
      );
      _addListTile(teamStatListItems, Icons.star, "Team Points", teamPoints);

      // scrape top 10 scores
      List<Map> allCTFScores = [];

      webScraper
          .getElement(
            'div.container > div.tab-content > div.active > table.table.table-striped > tbody > tr > td.place',
            [],
          )
          .forEach((item) {
            allCTFScores.add({"pos": item['title']});
          });

      List ctfNameData = webScraper.getElement(
        'div.container > div.tab-content > div.active > table.table.table-striped > tbody > tr > td > a',
        [],
      );
      for (int i = 0; i < allCTFScores.length; i++) {
        allCTFScores[i]["ctf"] = ctfNameData[i]['title'];
      }

      List _tempRatingPoints = webScraper.getElement(
        'div.container > div.tab-content > div.active > table.table.table-striped > tbody > tr > td',
        [],
      );
      List<double> ratingPoints = [];
      for (int i = 4; i < _tempRatingPoints.length; i += 5) {
        try {
          ratingPoints.add(double.parse(_tempRatingPoints[i]['title']));
        } catch (e) {}
      }
      for (int i = 0; i < allCTFScores.length; i++) {
        allCTFScores[i]["points"] = ratingPoints[i];
      }
      allCTFScores.sort((b, a) {
        return a['points'].compareTo(b['points']);
      });

      teamTop10ListItems.add(
        ListTile(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
          title: Text("Top 10 Scorings"),
        ),
      );
      teamTop10ListItems.add(
        const Divider(color: Colors.white, height: 3, thickness: 2),
      );
      for (int i = 0; i < 10; i++) {
        teamTop10ListItems.add(
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            tileColor: Colors.teal.shade900,
            leadingAndTrailingTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            titleTextStyle: TextStyle(color: Colors.white60, fontSize: 13),
            iconColor: Colors.white70,
            title: Text(allCTFScores[i]['ctf']),
            trailing: Text(allCTFScores[i]['points'].toString()),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } else {
      teamStatListItems.add(const Text('Cannot load URL!'));
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildCard(String title, Widget child) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(
          width: 3,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      shadowColor: Colors.white,
      elevation: 3,
      child:
          isLoading
              ? ListView(
                children: [
                  ListTile(
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                    title: Text(title),
                  ),
                  const Divider(color: Colors.white, height: 3, thickness: 2),
                  const Divider(
                    color: Colors.transparent,
                    height: 10,
                    thickness: 0,
                  ),
                  Center(child: CircularProgressIndicator(color: Colors.white)),
                ],
              )
              : child,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Expanded(
              child: Column(
                spacing: 6,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox.expand(
                      child: _buildCard(
                        'Current Team Stats',
                        ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: teamStatListItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: teamStatListItems[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox.expand(
                      child: _buildCard(
                        'Top 10 Scorings',
                        ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: teamTop10ListItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: teamTop10ListItems[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildCard('Todo', Text('Todo'))),
          ],
        ),
      ),
    );
  }

  Widget _buildCTFPointsCalcPage() {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.expand(child: Center(child: Text('To Do'))),
          ),
        ],
      ),
    );
  }

  Scaffold _buildPlatformScaffold() {
    List<Widget> pages = <Widget>[_buildHomePage(), _buildCTFPointsCalcPage()];

    return Scaffold(
      appBar: AppBar(
        title: Text("bi0s Stats"),
        actions:
            !(Platform.isAndroid || Platform.isIOS) && (_selectedIndex == 0)
                ? [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      teamStatListItems.clear();
                      _getStats();
                    },
                    iconSize: 30,
                    icon: Icon(Icons.replay_outlined),
                  ),
                ]
                : [],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculate Points',
            backgroundColor: Colors.teal,
          ),
        ],
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        onTap: _onItemTapped,
      ),
      body:
          (Platform.isAndroid || Platform.isIOS)
              ? RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    isLoading = true;
                  });
                  teamStatListItems.clear();
                  _getStats();
                },
                child: Center(child: pages.elementAt(_selectedIndex)),
              )
              : Center(child: pages.elementAt(_selectedIndex)),
    );
  }

  @override
  void initState() {
    _getStats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlatformScaffold();
  }
}
