# Realtime Voice — Flutter starter

Bu depo Flutter uygulamasının kaynak dosyalarını ve Android/iOS yerel ses köprüsünü içerir. Mevcut depo yalnızca boş bir `index.html` içerdiğinden, platformların oluşturduğu Flutter proje dosyaları (Xcode/Gradle wrapper, ikonlar ve tema kaynakları) burada yoktur.

## Flutter kabuğunu oluşturup çalıştırma

Flutter SDK kurulu olmalı. Android Studio/Xcode araç zincirini de platformunuz için kurun.

```bash
flutter create --platforms=android,ios --org com.example realtime_voice
```

Oluşan projedeki `lib/main.dart`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/example/realtime_voice/MainActivity.kt` ve `ios/Runner/AppDelegate.swift` dosyalarını bu depodaki karşılıklarıyla değiştirin. `VoiceChangerService.kt` dosyasını Android Kotlin paket klasörüne ekleyin. `android/app/build.gradle` içindeki `namespace` ve `applicationId` değerlerini `com.example.realtime_voice` yapın; `compileSdk` en az 35, `minSdk` 23 olsun. Flutter’ın oluşturduğu `LaunchTheme`, `NormalTheme`, `applicationName` ve ikon kaynaklarını koruyun.

```bash
flutter pub get
flutter run
```

## İzin ve arka plan ayarları

Android manifest dosyası mikrofon, foreground service, Android 14 mikrofon foreground service ve bildirim izinlerini; ayrıca `foregroundServiceType="microphone"` servis tipini içerir. Android 13+ bildirim izni istemi için uygulamada ayrıca bildirim izni istemek gerekebilir; servis bildirimi yine de sistem gereksinimlerine tabidir. Android 14+ cihazlarda servisi, uygulama görünürken başlatın (bu örnek bunu yapar). Servis `START_NOT_STICKY` kullanır; kullanıcı uygulamayı durdurduğunda işlem devam etmez.

`ios/Runner/Info.plist` içine aşağıdaki anahtarları ekleyin:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Canlı ses efektlerini uygulamak için mikrofon erişimi gerekir.</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

Xcode’da Runner target → Signing & Capabilities → Background Modes → Audio, AirPlay, and Picture in Picture seçeneğini etkinleştirin. iOS arka plan ses kullanımı yalnızca gerçek, kullanıcıya görünür ses işlevi için uygundur; App Store incelemesine tabidir. Kullanıcı mikrofon iznini reddederse ses başlatılmaz.

## Mimari ve sınırlamalar

- Flutter UI: koyu Material 3 arayüzü, canlı başlat/durdur ve dört efekt seçeneği.
- Android: `AudioRecord`/`AudioTrack` PCM hattı bir foreground service içinde çalışır; bildirim servis açıkken görünür. Efekt seçimi MethodChannel üzerinden anında iletilir.
- iOS: `AVAudioEngine`, `AVAudioUnitTimePitch` ve `AVAudioUnitDistortion` kullanır; ses oturumu `playAndRecord` yapılandırılır.
- Android’deki pitch örneği çok basit, blok tabanlı bir demo DSP’dir; profesyonel pitch-shift/zaman uzatma kalitesi sağlamaz. Düşük gecikme ve kesintisiz gerçek zamanlı kullanım cihaz, yönlendirme ve OS’e göre değişir. Hoparlörle canlı mikrofon izleme geri besleme yapabilir; kulaklık önerilir. Uygulama ses kaydetmez veya ağa göndermez.
- Bluetooth/telefon görüşmesi, ses kesintileri, üretim seviyesinde gürültü azaltma, DSP kalitesi ve mağaza politikaları ayrıca cihazlarda test edilmelidir.
