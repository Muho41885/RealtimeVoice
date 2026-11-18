# Realtime Voice — Flutter starter

Bu depo Flutter uygulamasının kaynak dosyalarını ve Android/iOS yerel ses köprüsünü içerir. Platformların oluşturduğu Flutter proje dosyaları (Gradle/Xcode kabuğu, ikonlar ve tema kaynakları) ayrıca oluşturulmalıdır.

## Flutter kabuğunu oluşturup çalıştırma

Flutter SDK ile Android Studio ve/veya Xcode araç zincirini kurun. Bu depoyu klonladıktan sonra proje kökünde çalıştırın:

```bash
flutter create --platforms=android,ios --org com.example realtime_voice
```

Oluşan projedeki `lib/main.dart`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/example/realtime_voice/MainActivity.kt` ve `ios/Runner/AppDelegate.swift` dosyalarını depodaki karşılıklarıyla değiştirin. `VoiceChangerService.kt` dosyasını Android Kotlin paket klasörüne ekleyin. `android/app/build.gradle` içindeki `namespace` ve `applicationId` değerlerini `com.example.realtime_voice` yapın; `compileSdk` en az 35, `minSdk` 23 olsun. Flutter’ın oluşturduğu `LaunchTheme`, `NormalTheme`, `applicationName` ve ikon kaynaklarını koruyun.

```bash
flutter pub get
flutter run
```

## İzinler ve arka planda çalışma

Android manifest dosyasında mikrofon, foreground service, Android 14 mikrofon foreground service ve bildirim izinleri tanımlıdır. Servis `foregroundServiceType="microphone"` olarak bildirilir; canlı mod uygulama görünürken başlatıldığında sürekli bildirimle ses servisi çalışır. Ana ekran düğmesine basıp uygulamayı arka plana almak veya etkinliği kapatmak servisi durdurmaz. Servis `START_NOT_STICKY` kullanır; kullanıcı uygulamayı zorla durdurursa veya işletim sistemi süreci sonlandırırsa otomatik yeniden başlaması garanti edilmez. Android 14+ kısıtları nedeniyle mikrofon foreground service uygulama arka plandayken ilk kez başlatılamaz. Bildirim iznini Android 13+ sürümlerde kullanıcıdan istemek gerekir.

iOS'ta canlı sesin arka planda sürdürülebilmesi için `ios/Runner/Info.plist` dosyasına şu değerleri ekleyin:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Canlı ses efektlerini uygulamak için mikrofon erişimi gerekir.</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

Xcode’da Runner target → Signing & Capabilities → Background Modes → Audio, AirPlay, and Picture in Picture seçeneğini etkinleştirin. iOS arka plan ses kullanımı yalnızca gerçek, kullanıcıya görünür ses işlevi için uygundur ve App Store incelemesine tabidir. Arka plan sesinin çalışması için bu plist/capability ayarlarının ikisi de gereklidir. Uygulama mikrofon izni verilmeden ses başlatmaz.

## Mimari ve sınırlamalar

- Flutter UI: koyu Material 3 arayüzü, canlı başlat/durdur ve dört efekt seçeneği.
- Android: `AudioRecord`/`AudioTrack` PCM hattı foreground service içinde çalışır; bildirim servis açıkken görünür. Efekt seçimi MethodChannel üzerinden anında iletilir.
- iOS: `AVAudioEngine`, `AVAudioUnitTimePitch` ve `AVAudioUnitDistortion` kullanır; ses oturumu `playAndRecord` yapılandırılır.
- Android pitch örneği basit, blok tabanlı bir demo DSP'sidir; profesyonel pitch-shift/zaman uzatma kalitesi sağlamaz. Düşük gecikme ve kesintisiz kullanım cihaza, ses yönlendirmesine ve işletim sistemi sürümüne göre değişir. Hoparlörle canlı mikrofon izleme geri besleme yapabilir; kulaklık kullanılması önerilir. Uygulama ses kaydetmez veya ağa göndermez.
- Bluetooth/telefon görüşmesi, ses kesintileri, üretim seviyesinde gürültü azaltma, DSP kalitesi ve mağaza politikaları gerçek cihazlarda ayrıca test edilmelidir.
