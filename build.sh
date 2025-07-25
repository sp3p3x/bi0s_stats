flutter build apk --release
mv build/app/outputs/flutter-apk/app-release.apk builds/bi0s_stats.apk
echo .apk built! path: builds/bi0s_stats.apk

flutter build aab --release
mv build/app/outputs/bundle/release/app-release.aab builds/bi0s_stats.aab
echo .aab built! path: builds/bi0s_stats.aab

flutter_distributor release --name=dev --jobs=release-dev-linux-deb
# injecting 512x512 icons manually
dpkg-deb -R dist/*/*.deb extracted_deb
mkdir -p extracted_deb/usr/share/icons/hicolor/512x512/apps
cp misc/logo/bi0s_stats_logo.png extracted_deb/usr/share/icons/hicolor/512x512/apps/bi0s_stats.png
dpkg-deb -b extracted_deb builds/bi0s_stats.deb
rm -rf extracted_deb
echo ".rpm & .deb built! path: builds/bi0s_stats.deb"

flutter_distributor release --name=dev --jobs=release-dev-linux-rpm
mv dist/*/*.rpm builds/bi0s_stats.rpm
echo ".rpm & .deb built! path: builds/bi0s_stats.rpm"