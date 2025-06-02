import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
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
  List<Widget> topCTFTeams = [];
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
          fontSize: 13,
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 11),
        title: Row(
          spacing: 8,
          children: [
            Icon(icon, size: 15, color: Colors.white70),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.start,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
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
          title: Text("Team Stats"),
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
      // TODO: add bi0sctf rating

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
          title: Text("Top 10 Scores"),
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
              fontSize: 13,
            ),
            titleTextStyle: TextStyle(color: Colors.white70, fontSize: 11),
            iconColor: Colors.white70,
            title: Text(allCTFScores[i]['ctf']),
            trailing: Text(allCTFScores[i]['points'].toString()),
          ),
        );
      }

      // scrape top ctf teams

      if (await webScraper.loadWebPage('/stats/')) {
        List<Map> topCTFTeamsList = [];

        List teamNames = webScraper.getElement(
          'div.container > table.table.table-striped > tbody > tr > td > a',
          [],
        );
        int pos = 1;
        for (int i = 0; i < teamNames.length; i++) {
          if (teamNames[i]['title'] != '') {
            topCTFTeamsList.add({"pos": pos, "name": teamNames[i]['title']});
            pos++;
          }
        }

        // since web_scraper lib doesnt have a way to scrap stuff with
        // inconsistent child tags, we resort to ooga booga methods...
        List<String> countries = [];
        try {
          final response = await http.get(
            Uri.parse('https://ctftime.org/stats/'),
          );

          if (response.statusCode == 200) {
            final document = htmlParser.parse(response.body);
            final countryElements = document.getElementsByClassName('country');
            for (var country in countryElements) {
              countries.add(
                country.children.isNotEmpty
                    ? country.children[0].attributes['href'].toString().split(
                      '/',
                    )[3]
                    : '-',
              );
            }
          } else {
            for (int i = 0; i < 50; i++) {
              countries.add('?');
            }
          }
        } catch (e) {
          for (int i = 0; i < 50; i++) {
            countries.add('?');
          }
        }

        List teamPoints = webScraper.getElement(
          'div.container > table.table.table-striped > tbody > tr > td',
          [],
        );
        pos = 0;
        for (int i = 4; i < teamPoints.length; i += 6) {
          topCTFTeamsList[pos]["points"] = teamPoints[i]['title'];
          pos++;
        }

        topCTFTeams.add(
          ListTile(
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
            title: Text("Top 50 CTF Teams"),
          ),
        );
        topCTFTeams.add(
          const Divider(color: Colors.white, height: 3, thickness: 2),
        );

        // i dont really see the need for a index bar (or im too lazy to make it responsive)
        // but a temp one is here in case...

        // topCTFTeams.add(
        //   Padding(
        //     padding: EdgeInsets.only(left: 8, right: 25),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Flexible(
        //           child: Row(
        //             spacing: 6,
        //             children: [
        //               Text('Pos'),
        //               Flexible(
        //                 child: Text(
        //                   "Name",
        //                   textAlign: TextAlign.start,
        //                   maxLines: 1,
        //                   softWrap: false,
        //                   overflow: TextOverflow.fade,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Flexible(
        //           child: Row(
        //             spacing: 15,
        //             children: [
        //               Flexible(
        //                 child: Text(
        //                   "Country",
        //                   textAlign: TextAlign.start,
        //                   maxLines: 1,
        //                   softWrap: false,
        //                   overflow: TextOverflow.fade,
        //                 ),
        //               ),
        //               Text("Points"),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // );

        for (int i = 0; i < topCTFTeamsList.length; i++) {
          topCTFTeams.add(
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      backgroundColor:
                          (topCTFTeamsList[i]['name'] == 'bi0s')
                              ? Colors.teal
                              : ((countries[i] == 'IN')
                                  ? Colors.lightGreen.shade800
                                  : Colors.teal.shade900),
                      title: Text(
                        topCTFTeamsList[i]['name'].toString(),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Position:'), Text('$i')],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Country:'), Text(countries[i])],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Points:'),
                              Text('${topCTFTeamsList[i]["points"]}'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              leadingAndTrailingTextStyle: TextStyle(fontSize: 12),
              titleTextStyle: TextStyle(fontSize: 12),
              tileColor:
                  (topCTFTeamsList[i]['name'] == 'bi0s')
                      ? Colors.teal
                      : ((countries[i] == 'IN')
                          ? Colors.lightGreen.shade800
                          : Colors.teal.shade900),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 7,
                children: [
                  Flexible(
                    child: Row(
                      spacing: 6,
                      children: [
                        Text(
                          topCTFTeamsList[i]['pos'].toString(),
                          style: TextStyle(color: Colors.white70),
                        ),
                        Flexible(
                          child: Text(
                            topCTFTeamsList[i]['name'].toString(),
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        countries[i],
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(topCTFTeamsList[i]['points'].toString()),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        setState(() {
          isLoading = false;
        });
      } else {
        teamStatListItems.add(const Text('Cannot load URL!'));
        teamTop10ListItems.add(const Text('Cannot load URL!'));
        topCTFTeams.add(const Text('Cannot load URL!'));
        setState(() {
          isLoading = false;
        });
      }
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
                        'Team Stats',
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
                        'Top 10 Scores',
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
            Expanded(
              child: SizedBox.expand(
                child: _buildCard(
                  'Top 50 CTF Teams',
                  ListView.builder(
                    padding: EdgeInsets.all(5),
                    itemCount: topCTFTeams.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: topCTFTeams[index],
                      );
                    },
                  ),
                ),
              ),
            ),
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

  Widget _buildCTFDetailsPage() {
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

  Widget _buildAboutPage() {
    List<ListTile> aboutListItems = [];

    aboutListItems.add(
      ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        tileColor: Colors.teal.shade900,
        leading: Icon(Icons.person, size: 25, color: Colors.white70),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        title: Row(
          children: [
            Flexible(
              child: Text(
                "Developed by Yadhu Krishna K",
                textAlign: TextAlign.start,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                "@sp3p3x",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.start,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );

    aboutListItems.add(
      ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        tileColor: Colors.teal.shade900,
        leading: Icon(Icons.code, size: 25, color: Colors.white70),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        title: Row(
          children: [
            Flexible(
              child: Text(
                "Github",
                textAlign: TextAlign.start,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                "<url>",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.start,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );

    return ListView.builder(
      padding: EdgeInsets.all(5),
      itemCount: aboutListItems.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: aboutListItems[index],
        );
      },
    );
  }

  Scaffold _buildPlatformScaffold() {
    List<Widget> pages = <Widget>[
      _buildHomePage(),
      _buildCTFDetailsPage(),
      _buildCTFPointsCalcPage(),
      _buildAboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("bi0s Stats"),
        actions:
            (_selectedIndex == 0)
                ? [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      teamStatListItems.clear();
                      teamTop10ListItems.clear();
                      topCTFTeams.clear();
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
            icon: Icon(Icons.flag),
            label: 'CTF Events',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculate Points',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            backgroundColor: Colors.teal,
          ),
        ],
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        onTap: _onItemTapped,
      ),
      body: Center(child: pages.elementAt(_selectedIndex)),
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
