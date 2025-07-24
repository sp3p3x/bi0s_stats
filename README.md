<img src="misc/logo/bi0s_stats_logo.png" alt="logo" width="300" height="300">

# bi0s Stats

App to check live stats for [team bi0s](bi0s.in).

Huge thanks to [Anikait](https://github.com/br34dcrumb) for helping out with his contributions.

## Features

Displays:

-  The current stats of the team such as team points, country and world position etc.
-  Top 10 scores of the team which is used to calculate team points in ctftime.
-  Top 50 teams from ctftime.
-  Currently running CTFs, upcoming CTFs, past CTFs the team has played.
-  Calculate the amount of points team will recieve from a CTF.
-  Estimate stats and rankings with points recieved from a CTF.

## Install

You can get the stable builds from the [Releases page](https://github.com/sp3p3x/bi0s_stats/releases).

Alternatively, upon every push, a ["Nightly builds" workflow](https://github.com/sp3p3x/bi0s_stats/actions) runs which builds an apk. You can download those from the action's artifacts.

## Run the flutter app

Instructions to run the app from the repo:

```
git clone https://github.com/sp3p3x/bi0s_stats.git
cd bi0s_stats
flutter run
```

## Contributing

Any suggestions, improvements, optimisations are welcome!

```
1) Fork this repo
2) Make the changes
3) Send a PR
```

## TODO
 - Show bi0sctf rating in team stats (currently the bi0sctf weight is hardcoded url)
 	- current and future weights
 	- points recieved from bi0sctf
 - Show previous year ranking in the "CTFs we played" section.
 - Create builds for other platforms like web, mac, ios etc.

*PS. The codebase is kinda wack and heavily unoptimised since it was cooked over a few overnights*