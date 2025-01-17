./check.sh

if [[ $(uname) == 'Darwin' ]]; then
    flutter test integration_test -d macos
fi

flutter build apk --release
flutter build appbundle --release

if [[ $(uname) == 'Darwin' ]]; then
    flutter build ios --release

    flutter build web

    flutter config --enable-macos-desktop
    flutter build macos
fi
