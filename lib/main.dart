import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:intl/intl.dart';

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

Future<String> checkForUpdates() async {
  String result = '';
  try {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/sp3p3x/bi0s_stats/refs/heads/main/pubspec.yaml',
      ),
    );

    if (response.statusCode == 200) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      response.body.split('\n').forEach((value) {
        if (value.startsWith('version: ')) {
          final pubspecVersion = value.split(' ')[1];
          if (pubspecVersion != currentVersion) {
            result = 'available';
          } else {
            result = 'unavailable';
          }
        }
      });
    }
  } catch (e) {
    result = 'failed';
  }
  return result;
}

openURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController statsController = TextEditingController();
  Widget mainWidget = Center();
  int _selectedIndex = 0;
  bool isStatsPageLoading = true;
  bool isCTFDetailsPageLoading = true;
  bool isCheckingUpdate = false;
  Map<String, String> monthToInt = {
    "Jan.": "01",
    "Feb.": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "Aug.": "08",
    "Sept.": "09",
    "Oct.": "10",
    "Nov.": "11",
    "Dec.": "12",
  };

  final formKey = GlobalKey<FormState>();
  final pointsRecievedController = TextEditingController();
  final teamRankController = TextEditingController();
  final teamPointsController = TextEditingController();
  final bestPointsController = TextEditingController();
  final weightController = TextEditingController();
  final totalTeamsController = TextEditingController();

  List<Widget> teamStatListItems = [];
  List<Widget> teamTop10ListItems = [];
  List<Widget> topCTFTeams = [];

  List<Widget> nowRunningCTFListItems = [];
  List<Widget> pastCTFListItems = [];
  List<Widget> upcomingCTFListItems = [];

  List<Widget> estimateStatsList = [];
  List<Widget> estimateRankingsList = [];

  Widget calcPointsPageStatsWidget = Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(width: 3, color: Colors.white),
        ),
        shadowColor: Colors.white,
        elevation: 3,
        child: ListView(
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Nothing to Show Here!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: -5,
        left: 13,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            'Estimated Stats',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );

  Widget calcPointsPageRankingsWidget = Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(width: 3, color: Colors.white),
        ),
        shadowColor: Colors.white,
        elevation: 3,
        child: ListView(
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Nothing to Show Here!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: -5,
        left: 13,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            'Estimated Rankings',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );

  _addListTile(
    List<Widget> list,
    IconData icon,
    String title,
    String subtitle,
  ) {
    list.add(
      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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

  String convertUtcToIst(String utcTimeString) {
    DateTime utcDateTime = DateTime.parse(utcTimeString).toUtc();
    DateTime istDateTime = utcDateTime.add(Duration(hours: 5, minutes: 30));
    String istTimeString = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(istDateTime);

    return istTimeString;
  }

  List<String> getStartEndTimeIST(String ctftimeDateTimeDetails) {
    List splitDateTime = ctftimeDateTimeDetails.split('—');
    String year = splitDateTime[1].substring(
      splitDateTime[1].length - 15,
      splitDateTime[1].length - 11,
    );
    List splitStartDateTime = splitDateTime[0].split(' ');
    List splitEndDateTime = splitDateTime[1].split(' ');
    String utcStartTime =
        "$year-${monthToInt[splitStartDateTime[1].replaceAll(',', '')]}-${splitStartDateTime[0]}T${splitStartDateTime[2]}:00Z";
    String utcEndTime =
        "$year-${monthToInt[splitEndDateTime[2]]}-${splitEndDateTime[1]}T${splitEndDateTime[4]}:00Z";
    String startTimeIST = convertUtcToIst(utcStartTime);
    String endTimeIST = convertUtcToIst(utcEndTime);
    String startDay = DateFormat.EEEE()
        .format(DateTime.parse(startTimeIST))
        .substring(0, 3);
    String endDay = DateFormat.EEEE()
        .format(DateTime.parse(endTimeIST))
        .substring(0, 3);
    startTimeIST =
        "${startTimeIST.substring(8, 10)} ${monthToInt.keys.toList()[int.parse(startTimeIST.substring(5, 7)) - 1]}, $startDay, ${startTimeIST.substring(11, 16)} IST";
    endTimeIST =
        "${endTimeIST.substring(8, 10)} ${monthToInt.keys.toList()[int.parse(endTimeIST.substring(5, 7)) - 1]}, $endDay, ${endTimeIST.substring(11, 16)} IST";

    return [startTimeIST, endTimeIST];
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

      // teamStatListItems.add(
      //   ListTile(
      //     titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      //     title: Text("Team Stats"),
      //   ),
      // );
      teamStatListItems.add(
        const Divider(color: Colors.transparent, height: 5, thickness: 0),
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

      if (await webScraper.loadWebPage('/ctf/31')) {
        final ctfRating = webScraper.getElement(
          'div.container > table.table.table-striped > tbody > tr > td',
          [],
        );

        String bi0sCTFRating =
            ctfRating.isNotEmpty ? ctfRating[1]['title'].toString() : "N/A";

        _addListTile(
          teamStatListItems,
          Icons.star,
          "bi0sCTF Points",
          bi0sCTFRating,
        );
      } else {
        _addListTile(
          teamStatListItems,
          Icons.star,
          "bi0sCTF Rating",
          "Failed to fetch",
        );
      }

      await webScraper.loadWebPage(
        '/team/662',
      ); // HOTFIX, PLS FIX LATER (TODO) - br34d
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

      List tempRatingPoints = webScraper.getElement(
        'div.container > div.tab-content > div.active > table.table.table-striped > tbody > tr > td',
        [],
      );
      List<double> ratingPoints = [];
      for (int i = 4; i < tempRatingPoints.length; i += 5) {
        try {
          ratingPoints.add(double.parse(tempRatingPoints[i]['title']));
        } catch (e) {}
      }
      for (int i = 0; i < allCTFScores.length; i++) {
        allCTFScores[i]["points"] = ratingPoints[i];
      }
      allCTFScores.sort((b, a) {
        return a['points'].compareTo(b['points']);
      });

      // teamTop10ListItems.add(
      //   ListTile(
      //     titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
      //     title: Text("Top 10 Scores"),
      //   ),
      // );
      teamTop10ListItems.add(
        const Divider(color: Colors.transparent, height: 5, thickness: 0),
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

        // topCTFTeams.add(
        //   ListTile(
        //     titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
        //     title: Text("Top 50 Teams"),
        //   ),
        // );
        topCTFTeams.add(
          const Divider(color: Colors.transparent, height: 5, thickness: 0),
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
                            children: [Text('Position:'), Text('${i + 1}')],
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
          isStatsPageLoading = false;
        });
      } else {
        teamStatListItems.add(const Text('Cannot load URL!'));
        teamTop10ListItems.add(const Text('Cannot load URL!'));
        topCTFTeams.add(const Text('Cannot load URL!'));
        setState(() {
          isStatsPageLoading = false;
        });
      }
    }
  }

  _getCTFDetails() async {
    String year = DateTime.now().year.toString();

    final webScraper = WebScraper('https://ctftime.org');
    if (await webScraper.loadWebPage(
      '/event/list/?year=$year&online=-1&format=0&restrictions=-1&now=true',
    )) {
      // scrape now running ctfs
      List<Map> activeCTFList = [];
      for (var element in webScraper.getElement(
        'div.container > table.table.table-striped > tbody > tr > td > a',
        ['href'],
      )) {
        if (element['title'] != "*" &&
            (element['attributes']['href'].toString().contains('/event'))) {
          activeCTFList.add({
            "name": element['title'],
            'link': element['attributes']['href'],
          });
        }
      }

      final ctfDetails = webScraper.getElement(
        'div.container > table.table.table-striped > tbody > tr > td',
        [],
      );

      int pos = 0;
      for (int i = 1; i < ctfDetails.length; i += 7) {
        List startEndTimeIST = getStartEndTimeIST(ctfDetails[i]['title']);
        activeCTFList[pos]['startDateTime'] = startEndTimeIST[0];
        activeCTFList[pos]['endDateTime'] = startEndTimeIST[1];
        activeCTFList[pos]['format'] = ctfDetails[i + 1]['title'];
        activeCTFList[pos]['location'] = ctfDetails[i + 2]['title']
            .toString()
            .replaceAll('\n', '');
        activeCTFList[pos]['ctfRating'] = ctfDetails[i + 3]['title'];
        pos++;
      }

      nowRunningCTFListItems.add(
        const Divider(color: Colors.transparent, height: 5, thickness: 0),
      );
      for (var element in activeCTFList) {
        nowRunningCTFListItems.add(
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    backgroundColor: Colors.teal.shade900,
                    title: Text(
                      element['name'].toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Started:"),
                            Flexible(
                              child: Text(
                                element['startDateTime'],
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ends:'),
                            Flexible(
                              child: Text(
                                element['endDateTime'],
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Format:'), Text(element["format"])],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Location:'),
                            Text('${element["location"]}'),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rating:'),
                            Text('${element["ctfRating"]} pts'),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CTFtime:'),
                            ElevatedButton(
                              onPressed: () {
                                openURL(
                                  "https://ctftime.org${element['link']}",
                                );
                              },
                              child: Text("Click here!"),
                            ),
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
            tileColor: Colors.teal.shade900,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 14),
            title: Row(
              spacing: 8,
              children: [
                Flexible(
                  child: Text(
                    element['name'],
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${element["ctfRating"]} pts',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                // Text(
                //   'Click to Show more!',
                //   style: TextStyle(color: Colors.white70, fontSize: 10),
                // ),
              ],
            ),
          ),
        );
      }

      // scrape for bi0s's past ctfs
      List<Map> pastCTFList = [];
      try {
        final response = await http.get(
          Uri.parse('https://ctftime.org/team/662'),
        );

        if (response.statusCode == 200) {
          final document = htmlParser.parse(response.body);
          final pageElements = document.getElementsByClassName(
            'tab-pane.active',
          );
          for (var element in pageElements) {
            if (element.attributes['id'] == 'rating_$year') {
              if (element.children.length == 3) {
                final pastCTFTableElement = element.children[2].children[0];
                for (var ctf in pastCTFTableElement.children.skip(1)) {
                  Map tempCtfDetails = {};
                  tempCtfDetails["position"] = ctf.children[1].text;
                  tempCtfDetails["name"] = ctf.children[2].children[0].text;
                  tempCtfDetails["link"] =
                      ctf.children[2].children[0].attributes['href'];
                  tempCtfDetails["points"] = ctf.children[4].text;
                  pastCTFList.add(tempCtfDetails);
                }
              }
            }
          }
        } else {
          for (int i = 0; i < 50; i++) {
            pastCTFList.add({"Could not fetch data :/": ""});
          }
        }
      } catch (e) {
        for (int i = 0; i < 50; i++) {
          pastCTFList.add({"Could not fetch data :/": ""});
        }
      }

      pastCTFListItems.add(
        const Divider(color: Colors.transparent, height: 5, thickness: 0),
      );
      for (var element in pastCTFList) {
        pastCTFListItems.add(
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    backgroundColor: Colors.teal.shade900,
                    title: Text(
                      element['name'].toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Position:'),
                            Text('${element["position"]}'),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Points:'),
                            Text('${element["points"]} pts'),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CTFtime:'),
                            ElevatedButton(
                              onPressed: () {
                                openURL(
                                  "https://ctftime.org${element['link']}",
                                );
                              },
                              child: Text("Click here!"),
                            ),
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
            titleTextStyle: TextStyle(color: Colors.white70, fontSize: 12),
            tileColor: Colors.teal.shade900,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 7,
              children: [
                Flexible(
                  child: Row(
                    spacing: 6,
                    children: [
                      // Text(
                      //   element["position"],
                      //   style: TextStyle(color: Colors.white70, fontSize: 12),
                      // ),
                      Flexible(
                        child: Text(
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          element['name'],
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          softWrap: false,
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
                      '${element["points"]} pts',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      // scrape upcoming ctf events
      if (await webScraper.loadWebPage(
        '/event/list/?year=$year&online=-1&format=0&restrictions=-1&upcoming=true',
      )) {
        List<Map> upcomingCTFList = [];

        for (var element in webScraper.getElement(
          'div.container > table.table.table-striped > tbody > tr > td > a',
          ['href'],
        )) {
          if (element['title'] != "*" &&
              (element['attributes']['href'].toString().contains('/event'))) {
            upcomingCTFList.add({
              "name": element['title'],
              'link': element['attributes']['href'],
            });
          }
        }

        final upcomingCTFDetails = webScraper.getElement(
          'div.container > table.table.table-striped > tbody > tr > td',
          [],
        );

        pos = 0;
        for (int i = 1; i < upcomingCTFDetails.length; i += 7) {
          List startEndTimeIST = getStartEndTimeIST(
            upcomingCTFDetails[i]['title'],
          );
          upcomingCTFList[pos]['startDateTime'] = startEndTimeIST[0];
          upcomingCTFList[pos]['endDateTime'] = startEndTimeIST[1];
          upcomingCTFList[pos]['format'] = upcomingCTFDetails[i + 1]['title'];
          upcomingCTFList[pos]['location'] = upcomingCTFDetails[i + 2]['title']
              .toString()
              .replaceAll('\n', '');
          upcomingCTFList[pos]['ctfRating'] =
              upcomingCTFDetails[i + 3]['title'];
          pos++;
        }

        upcomingCTFListItems.add(
          const Divider(color: Colors.transparent, height: 5, thickness: 0),
        );
        for (var element in upcomingCTFList) {
          upcomingCTFListItems.add(
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      backgroundColor: Colors.teal.shade900,
                      title: Text(
                        element['name'].toString(),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Starts:"),
                              Flexible(
                                child: Text(
                                  element['startDateTime'],
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ends:'),
                              Flexible(
                                child: Text(
                                  element['endDateTime'],
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Format:'),
                              Text(element["format"]),
                            ],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Location:'),
                              Text('${element["location"]}'),
                            ],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rating:'),
                              Text('${element["ctfRating"]} pts'),
                            ],
                          ),
                        ),
                        SimpleDialogOption(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('CTFtime:'),
                              ElevatedButton(
                                onPressed: () {
                                  openURL(
                                    "https://ctftime.org${element['link']}",
                                  );
                                },
                                child: Text("Click here!"),
                              ),
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
              tileColor: Colors.teal.shade900,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              title: Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Text(
                      element['name'],
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${element["ctfRating"]} pts',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${element["startDateTime"].split(",")[0]}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  // Text(
                  //   '${element["ctfRating"]} pts\n${element["startDateTime"]}',
                  //   style: TextStyle(color: Colors.white, fontSize: 10),
                  // ),
                  // Text(
                  //   'Click to Show more!',
                  //   style: TextStyle(color: Colors.white70, fontSize: 10),
                  // ),
                ],
              ),
            ),
          );
        }
      }

      setState(() {
        isCTFDetailsPageLoading = false;
      });
    } else {
      nowRunningCTFListItems.add(const Text('Cannot load URL!'));
      pastCTFListItems.add(const Text('Cannot load URL!'));
      upcomingCTFListItems.add(const Text('Cannot load URL!'));
      setState(() {
        isCTFDetailsPageLoading = false;
      });
    }
  }

  Future<String> _getEstimatedData(String recievedPoints) async {
    String isTop10Score = "";

    final webScraper = WebScraper('https://ctftime.org');

    if (await webScraper.loadWebPage('/team/662')) {
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

      List tempRatingPoints = webScraper.getElement(
        'div.container > div.tab-content > div.active > table.table.table-striped > tbody > tr > td',
        [],
      );
      List<double> ratingPoints = [];
      for (int i = 4; i < tempRatingPoints.length; i += 5) {
        try {
          ratingPoints.add(double.parse(tempRatingPoints[i]['title']));
        } catch (e) {}
      }
      for (int i = 0; i < allCTFScores.length; i++) {
        allCTFScores[i]["points"] = ratingPoints[i];
      }
      allCTFScores.sort((b, a) {
        return a['points'].compareTo(b['points']);
      });

      if (double.parse(recievedPoints) > allCTFScores[9]['points']) {
        if (await webScraper.loadWebPage('/team/662')) {
          // scrape team stats
          final ratingAndCountryPosition = webScraper.getElement(
            'div.container > div.tab-content > div.active > p',
            [],
          );

          String overallPosAndTeamRating = ratingAndCountryPosition[0]['title']
              .toString()
              .replaceAll('\n', '');
          final teamPoints = double.parse(
            overallPosAndTeamRating.split(' ')[13],
          );

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
                topCTFTeamsList.add({
                  "pos": pos,
                  "name": teamNames[i]['title'],
                });
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
                final countryElements = document.getElementsByClassName(
                  'country',
                );
                for (var country in countryElements) {
                  countries.add(
                    country.children.isNotEmpty
                        ? country.children[0].attributes['href']
                            .toString()
                            .split('/')[3]
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

            List teamPointsList = webScraper.getElement(
              'div.container > table.table.table-striped > tbody > tr > td',
              [],
            );
            pos = 0;
            for (int i = 4; i < teamPointsList.length; i += 6) {
              topCTFTeamsList[pos]["points"] = teamPointsList[i]['title'];
              pos++;
            }

            for (int i = 0; i < topCTFTeamsList.length; i++) {
              if (topCTFTeamsList[i]['name'] == 'bi0s') {
                topCTFTeamsList[i]['points'] = (teamPoints +
                        double.parse(recievedPoints) -
                        allCTFScores[9]['points'])
                    .toStringAsFixed(3);
              }
            }

            for (int i = 0; i < topCTFTeamsList.length; i++) {
              topCTFTeamsList[i]['country'] = countries[i];
            }

            topCTFTeamsList.sort((b, a) {
              return a['points'].compareTo(b['points']);
            });

            for (int i = 0; i < topCTFTeamsList.length; i++) {
              topCTFTeamsList[i]['pos'] = i + 1;
              if (topCTFTeamsList[i]['name'] == 'bi0s') {
                _addListTile(
                  estimateStatsList,
                  Icons.public,
                  "World Position",
                  '${i + 1}',
                );
              }
            }

            int countryPosition = 0;
            for (int i = 0; i < topCTFTeamsList.length; i++) {
              if (topCTFTeamsList[i]['country'] == 'IN') {
                countryPosition++;
              }
              if (topCTFTeamsList[i]['name'] == 'bi0s') {
                break;
              }
            }

            _addListTile(
              estimateStatsList,
              Icons.flag,
              "Country Position",
              countryPosition.toString(),
            );

            _addListTile(
              estimateStatsList,
              Icons.star,
              "Estimated Points",
              (teamPoints +
                      double.parse(recievedPoints) -
                      allCTFScores[9]['points'])
                  .toStringAsFixed(3),
            );

            for (int i = 0; i < topCTFTeamsList.length; i++) {
              estimateRankingsList.add(
                ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          backgroundColor:
                              (topCTFTeamsList[i]['name'] == 'bi0s')
                                  ? Colors.teal
                                  : ((topCTFTeamsList[i]['country'] == 'IN')
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Position:'), Text('$i')],
                              ),
                            ),
                            SimpleDialogOption(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Country:'),
                                  Text(topCTFTeamsList[i]['country']),
                                ],
                              ),
                            ),
                            SimpleDialogOption(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                          : ((topCTFTeamsList[i]['country'] == 'IN')
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
                            topCTFTeamsList[i]['country'],
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
          } else {
            estimateRankingsList.add(const Text('Cannot load URL!'));
            estimateStatsList.add(const Text('Cannot load URL!'));
          }
        }
        isTop10Score = 'cooking';
      } else {
        isTop10Score = 'skillissue';
      }
    }

    return isTop10Score;
  }

  Widget _buildCard(String title, Widget child, bool loadingCheck) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              width: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          shadowColor: Colors.white,
          elevation: 3,
          child:
              loadingCheck
                  ? ListView(
                    children: [
                      const Divider(
                        color: Colors.transparent,
                        height: 40,
                        thickness: 0,
                      ),
                      Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ],
                  )
                  : child,
        ),
        Positioned(
          top: -5,
          left: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
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
                        isStatsPageLoading,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox.expand(
                      child: _buildCard(
                        'Our Top 10 Scores',
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
                        isStatsPageLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox.expand(
                child: _buildCard(
                  'Top 50 Teams',
                  ListView.builder(
                    padding: EdgeInsets.all(1),
                    itemCount: topCTFTeams.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: topCTFTeams[index],
                      );
                    },
                  ),
                  isStatsPageLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTFDetailsPage() {
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
                    child: SizedBox.expand(
                      child: _buildCard(
                        'Now Running',
                        ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: nowRunningCTFListItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: nowRunningCTFListItems[index],
                            );
                          },
                        ),
                        isCTFDetailsPageLoading,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox.expand(
                      child: _buildCard(
                        'CTFs We Played',
                        ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: pastCTFListItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: pastCTFListItems[index],
                            );
                          },
                        ),
                        isCTFDetailsPageLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox.expand(
                child: _buildCard(
                  'Upcoming CTFs',
                  ListView.builder(
                    padding: EdgeInsets.all(5),
                    itemCount: upcomingCTFListItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: upcomingCTFListItems[index],
                      );
                    },
                  ),
                  isCTFDetailsPageLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTFPointsCalcPage() {
    calcctftimerating(teamRank, teamPoints, bestPoints, weight, totalTeams) {
      try {
        final pointsCoef = teamPoints / bestPoints;
        final placeCoef = 1 / teamRank;
        if (pointsCoef > 0) {
          final rating =
              ((pointsCoef + placeCoef) * weight) /
              (1 / (1 + teamRank / totalTeams));
          return rating;
        }
      } catch (e) {
        return 'Invalid Values Provided!';
      }
    }

    // void submitPointsCalcForm() {
    //   if (formKey.currentState!.validate()) {
    //     final pointsRecieved = calcctftimerating(
    //       double.parse(teamRankController.text),
    //       double.parse(teamPointsController.text),
    //       double.parse(bestPointsController.text),
    //       double.parse(weightController.text),
    //       double.parse(totalTeamsController.text),
    //     );
    //     if (pointsRecieved == 'Invalid Values Provided!') {
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(SnackBar(content: Text('$pointsRecieved')));
    //       return;
    //     }
    //     pointsRecievedController.text =
    //         "${pointsRecieved.toStringAsFixed(3)} pts";
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Team will recieve: ${pointsRecieved.toStringAsFixed(3)} pts!',
    //         ),
    //       ),
    //     );
    //   }
    // }

    void estimateRankingsAndStats() async {
      if (formKey.currentState!.validate()) {
        final pointsRecieved = calcctftimerating(
          double.parse(teamRankController.text),
          double.parse(teamPointsController.text),
          double.parse(bestPointsController.text),
          double.parse(weightController.text),
          double.parse(totalTeamsController.text),
        );
        if (pointsRecieved == 'Invalid Values Provided!') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$pointsRecieved')));
          return;
        }

        pointsRecievedController.text =
            "${pointsRecieved.toStringAsFixed(3)} pts";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Team will recieve: ${pointsRecieved.toStringAsFixed(3)} pts!',
            ),
          ),
        );

        estimateRankingsList.clear();
        estimateStatsList.clear();

        setState(() {
          calcPointsPageStatsWidget = _buildCard(
            "Estimated Stats",
            Text(''),
            true,
          );

          calcPointsPageRankingsWidget = _buildCard(
            "Estimated Rankings",
            Text(''),
            true,
          );
        });

        String stats = await _getEstimatedData(pointsRecieved.toString());
        if (stats == 'skillissue') {
          setState(() {
            calcPointsPageStatsWidget = _buildCard(
              "Estimated Stats",
              ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 80),
                      Flexible(
                        child: Text(
                          'Score is not in Top 10! :/',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              false,
            );

            calcPointsPageRankingsWidget = _buildCard(
              "Estimated Rankings",
              ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 80),
                      Flexible(
                        child: Text(
                          'Score is not in Top 10! :/',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              false,
            );
          });
        } else if (stats == 'cooking') {
          setState(() {
            calcPointsPageStatsWidget = _buildCard(
              'Estimated Stats',
              ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: estimateStatsList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: estimateStatsList[index],
                  );
                },
              ),
              false,
            );

            calcPointsPageRankingsWidget = _buildCard(
              'Estimated Rankings',
              ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: estimateRankingsList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: estimateRankingsList[index],
                  );
                },
              ),
              false,
            );
          });
        }
      }
    }

    Form calcForm = Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          spacing: 7,
          children: [
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: pointsRecievedController,
                    decoration: InputDecoration(
                      labelText: 'Points Recieved',
                      labelStyle: TextStyle(color: Colors.white60),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    enabled: false,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: teamRankController,
                    // textInputAction: TextInputAction.next,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                      labelText: 'Team Rank',
                      labelStyle: TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (double.tryParse(value) == null) ||
                          (double.tryParse(value) == null)) {
                        return 'Please enter a number!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: totalTeamsController,
                    // textInputAction: TextInputAction.next,
                    // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                      labelText: 'Total Teams',
                      labelStyle: TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (double.tryParse(value) == null)) {
                        return 'Please enter a number!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: teamPointsController,
                    // textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Team Points',
                      labelStyle: TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (double.tryParse(value) == null)) {
                        return 'Please enter a number!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: bestPointsController,
                    // textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Best Points',
                      labelStyle: TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (double.tryParse(value) == null)) {
                        return 'Please enter a number!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              spacing: 6,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: weightController,
                    // textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      labelStyle: TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFCF6679)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (double.tryParse(value) == null)) {
                        return 'Please enter a number!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.teal.shade900,
            //         ),
            //         onPressed: submitPointsCalcForm,
            //         child: Text('Check Points'),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade900,
                    ),
                    onPressed: estimateRankingsAndStats,
                    child: Text('Estimate Stats'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade900,
                    ),
                    onPressed: () {
                      pointsRecievedController.clear();
                      teamRankController.clear();
                      teamPointsController.clear();
                      bestPointsController.clear();
                      weightController.clear();
                      totalTeamsController.clear();
                    },
                    child: Text('Clear Inputs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    List<Widget> calcPointItems = [const SizedBox(), calcForm];

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
                    flex: 2,
                    child: SizedBox.expand(
                      child: _buildCard(
                        'Calculate Points',
                        ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: calcPointItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: calcPointItems[index],
                            );
                          },
                        ),
                        false,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox.expand(child: calcPointsPageStatsWidget),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox.expand(child: calcPointsPageRankingsWidget),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutPage() {
    List<ListTile> aboutListItems = [];
    int eastereggCountdown1 = 0;
    int eastereggCountdown2 = 0;

    aboutListItems.add(
      ListTile(
        onTap: () {
          openURL('https://bi0s.in');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        tileColor: Colors.teal.shade900,
        leading: Icon(Icons.flag, size: 25, color: Colors.white70),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        title: Row(
          children: [
            Flexible(
              child: Text(
                "Team bi0s",
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
                "bi0s.in",
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
        onTap: () async {
          eastereggCountdown1++;
          if (eastereggCountdown1 == 7) {
            openURL('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
            eastereggCountdown1 = 0;
          }
        },
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
        onTap: () async {
          eastereggCountdown2++;
          if (eastereggCountdown2 == 7) {
            openURL(
              'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRcKwYU7J96QuZNKxtcl0TbCHm-fkdT5wXwj-1i4l0XFMlhDpux',
            );
            eastereggCountdown2 = 0;
          }
        },
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
                "Contributor: Anikait Panigrahi",
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
                "@br34dcrumb",
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
        onTap: () {
          openURL('https://github.com/sp3p3x/bi0s_stats');
        },
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
                "github.com/sp3p3x/bi0s_stats",
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
        onTap: () async {
          openURL('https://ctftime.org/');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        tileColor: Colors.teal.shade900,
        leading: Icon(Icons.public, size: 25, color: Colors.white70),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        title: Row(
          children: [
            Flexible(
              child: Text(
                "CTFtime",
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
                "Click to open CTFtime",
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

    // have to fix the part where playstore needs diff format of versioning for pubspec
    // and it doesn't match the apps version we check from the inside of the app itself with.
    // aboutListItems.add(
    //   ListTile(
    //     onTap: () async {
    //       setState(() {
    //         isCheckingUpdate = true;
    //       });
    //       String updateCheckResult = await checkForUpdates();
    //       setState(() {
    //         isCheckingUpdate = false;
    //       });
    //       SnackBar snackbar = SnackBar(content: Text(''));
    //       if (updateCheckResult == 'available') {
    //         snackbar = SnackBar(
    //           content: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text('Update Available!'),
    //               TextButton(
    //                 style: TextButton.styleFrom(
    //                   foregroundColor: Colors.white,
    //                   backgroundColor: Colors.black,
    //                 ),
    //                 onPressed: () {
    //                   openURL('https://github.com/sp3p3x/bi0s_stats/releases');
    //                 },
    //                 child: Text('Check it out!'),
    //               ),
    //             ],
    //           ),
    //         );
    //       } else if (updateCheckResult == 'unavailable') {
    //         snackbar = SnackBar(
    //           content: Text('You already have the latest version!'),
    //         );
    //       } else if (updateCheckResult == "failed") {
    //         snackbar = SnackBar(content: Text('Failed to fetch update!'));
    //       }
    //       ScaffoldMessenger.of(context).showSnackBar(snackbar);
    //     },
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(14.0),
    //     ),
    //     tileColor: Colors.teal.shade900,
    //     leading:
    //         isCheckingUpdate
    //             ? CircularProgressIndicator(color: Colors.white)
    //             : Icon(Icons.update, size: 25, color: Colors.white70),
    //     titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Flexible(
    //           child: Text(
    //             "Check for updates",
    //             textAlign: TextAlign.start,
    //             maxLines: 2,
    //             softWrap: true,
    //             overflow: TextOverflow.fade,
    //           ),
    //         ),
    //       ],
    //     ),
    //     subtitle: Row(
    //       children: [
    //         Flexible(
    //           child: Text(
    //             "Click here to check for updates!",
    //             style: TextStyle(color: Colors.white70),
    //             textAlign: TextAlign.start,
    //             maxLines: 2,
    //             softWrap: true,
    //             overflow: TextOverflow.fade,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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
        surfaceTintColor: Colors.black,
        actions:
            (_selectedIndex == 0)
                ? [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isStatsPageLoading = true;
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
                : (_selectedIndex == 1)
                ? [
                  IconButton(
                    onPressed: () async {
                      openURL(
                        'https://calendar.google.com/calendar/u/0/embed?showTitle=0&showNav=0&showPrint=0&showCalendars=0&height=600&wkst=2&src=ctftime@gmail.com&ctz=Asia/Kolkata&bgcolor=%23212121&color=%23a5d6a7',
                      );
                    },
                    iconSize: 30,
                    icon: Icon(Icons.calendar_month),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isCTFDetailsPageLoading = true;
                      });

                      nowRunningCTFListItems.clear();
                      pastCTFListItems.clear();
                      upcomingCTFListItems.clear();
                      _getCTFDetails();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _getStats();
    _getCTFDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlatformScaffold();
  }
}
