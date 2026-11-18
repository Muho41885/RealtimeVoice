# Realtime Voice — web demo and Android WebView shell

Bu depo, tarayıcıda çalışan ses efekti web sitesini ve Android APK içine gömülebilecek WebView kabuğunu içerir. Web sitesinin sesi cihazda işlenir; mikrofon verisi kaydedilmez veya sunucuya gönderilmez.

## Web sitesini deneme

Site: https://muho41885.github.io/RealtimeVoice/

Mikrofon için siteyi HTTPS üzerinden açın ve **Canlıya al** düğmesine basınca çıkan tarayıcı iznini kabul edin. Canlı ses, mikrofon akışını efektlerle işleyip cihazın ses çıkışına yollar; sesi duymak için medya sesini açın ve kulaklık kullanın. Hoparlör sesi mikrofona geri beslenebilir.

## Android APK / WebView

Android WebView, web sayfası izninden ayrı olarak Android uygulamasının mikrofon iznine ve `WebChromeClient.onPermissionRequest` iznini sayfaya iletmesine ihtiyaç duyar. Bu depodaki `MainActivity.kt` artık yalnızca `https://muho41885.github.io` kaynağından gelen mikrofon isteğini kabul eder, Android'in `RECORD_AUDIO` çalışma zamanı iznini ister ve onaylandıktan sonra sayfaya ses yakalama izni verir. Manifestte internet ve mikrofon izinleri bulunur.

Flutter ile Android proje kabuğunu oluşturup dosyaları yerlerine aldıktan sonra APK üretin:

```bash
flutter create --platforms=android --org com.example realtime_voice
```

Bu depo içindeki `android/app/src/main/AndroidManifest.xml` ve `android/app/src/main/kotlin/com/example/realtime_voice/MainActivity.kt` dosyalarını oluşan projedeki karşılıklarıyla değiştirin. `namespace`/`applicationId` değerlerini `com.example.realtime_voice` ile eşleştirin. Android kaynaklarındaki `LaunchTheme`, `NormalTheme`, `applicationName` ve ikon dosyalarını koruyun. Ardından:

```bash
flutter build apk
```

Kurulu APK'da Android **Ayarlar → Uygulamalar → Realtime Voice → İzinler → Mikrofon → Uygulamayı kullanırken izin ver** seçeneğini etkinleştirin. Uygulamayı açıp **Canlıya al** düğmesine basın ve Android'in izin penceresini de kabul edin. İzin sonradan Ayarlar'dan verildiyse WebView sayfasını yenileyip tekrar deneyin.

## Ses duyulmuyorsa

- Telefonun medya sesini artırın; zil sesi seviyesi ayrı olabilir.
- Kulaklık takın. Hoparlör-mikrofon geri beslemesini ve yankı engelleyicilerin sesi bastırmasını önler.
- Mikrofon izninin hem Android uygulama ayarlarında hem de uygulama içindeki izin penceresinde açık olduğunu kontrol edin.
- Sayfa HTTPS üzerinden açılmalıdır. APK içindeki WebView bu depodaki güvenli GitHub Pages adresini kullanır.
- Bu kabukta ses, uygulama ekrandayken çalışır. Android mikrofon kullanımını sistem politikalarına göre sınırlar; uygulama zorla kapatıldığında ses sürmez.

## Sınırlamalar

Web Audio efektleri filtreleme ve modülasyonla yapılan bir demodur, profesyonel pitch-shifting değildir. WebView/cihaz/Android sürümüne göre gecikme ve ses yönlendirmesi değişebilir. Bu ortamda fiziksel Android cihazda APK derlemesi ve ses testi çalıştırılamadı; hedef cihazda mikrofon izni, kulaklık, hoparlör ve efektler ayrı ayrı doğrulanmalıdır. iOS arka plan mikrofonu/native app bu başlangıç kapsamına dahil değildir.
