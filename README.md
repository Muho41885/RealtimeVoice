# Realtime Voice — web demo

Bu depo, masaüstü ve mobil tarayıcılarda çalışan tek sayfalık canlı ses efekti demosudur. `index.html` Web Audio API kullanır; sunucu, derleme aracı veya harici JavaScript paketi gerekmez.

## Çalıştırma

Mikrofon erişimi güvenlik nedeniyle HTTPS veya `localhost` gerektirir. Dosyayı doğrudan `file://` ile açmak yerine GitHub Pages'e yayınlayın ya da yerel sunucu çalıştırın:

```bash
python3 -m http.server 8000
```

Ardından `http://localhost:8000` adresini açın. Tarayıcıda mikrofon izni verip efekt seçin ve **Canlıya al** düğmesine basın. Kulaklık kullanılması önerilir; hoparlörden mikrofonu dinlemek ses geri beslemesine neden olabilir.

## Tarayıcı ve arka plan sınırlamaları

- Ses işleme tarayıcıda, cihaz üzerinde yapılır; kayıt veya sunucuya ses aktarımı yoktur.
- Tarayıcı sekmesi kapatılırsa veya kullanıcı canlı modu durdurursa mikrofon akışı sonlandırılır.
- Mobil tarayıcılar arka plana alınan sekmelerin sesini askıya alabilir veya sınırlayabilir. Web uygulaması arka planda sürekli mikrofon/ses çalışmasını garanti edemez; bu, Flutter/native foreground service özelliği değildir.
- Web Audio efektleri filtreleme ve modülasyonla oluşturulan demodur; profesyonel pitch-shifting değildir. Efekt ve gecikme tarayıcıya/cihaza göre değişir.
- Mikrofon için kullanıcı izni ve güvenli bağlam (HTTPS/localhost) gerekir.

## Yayınlama

`index.html` depo kökünde olduğundan GitHub Pages için `main` dalındaki `/ (root)` klasörünü seçin. İsterseniz aynı dosyayı HTTPS destekleyen başka bir statik hosta da yükleyebilirsiniz.
