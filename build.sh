flutter build apk --release
mv build/app/outputs/flutter-apk/app-release.apk builds/bi0s_stats.apk
echo .apk built! path: builds/bi0s_stats.apk

flutter build aab --release
mv build/app/outputs/bundle/release/app-release.aab builds/bi0s_stats.aab
echo .aab built! path: builds/bi0s_stats.aab
# flutter build linux --release
# mv build/linux/x64/release/bundle/bi0s_stats builds/
