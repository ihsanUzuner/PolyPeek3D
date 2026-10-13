# PolyPeek3D

![PolyPeek3D](docs/screenshots/camera.gif)

[English](README.md) | [Türkçe](README-TR.md)

Windows için küçük ve hızlı bir 3D model görüntüleyici. Sunucu, tarayıcı ya da hesap gerekmez.

**Desteklenen biçimler:** FBX · GLB/GLTF · OBJ · STL · PLY · DAE · 3DS · 3MF · AMF · STEP/STP

## Özellikler
- Dört görünüm modu: Materyal, Rastgele renk, Solid ve Hologram. Her birinin üstüne wireframe açılabilir.
- Parça listesi: parçaları seç, gizle, tek başına göster ya da kamerayla üstüne odaklan.
- STEP/STP desteği: CAD modelleri renkleri ve parçalarıyla birlikte açılır, detay seviyesi ayarlanabilir.
- Animasyon oynatma: hız ayarı, döngü seçenekleri ve zaman çubuğu.
- Işık, gölge, zemin ve kamera ayarları.

## Animasyon
![PolyPeek3D](docs/screenshots/runner.gif)

## Kurulum
**Releases** sayfasından indir:
- **`PolyPeek3D-Setup-x.y.z.exe`:** Kurulum dosyası. Yönetici izni istemez, dosya ilişkilendirmelerini kendisi yapar.
- **`PolyPeek3D-x.y.z-portable.zip`:** Kurulumsuz sürüm. İstediğin klasöre aç. Çift tıklamayla açılsın istersen `Associate-Files.bat`'ı çalıştır.

**Gereksinimler:** Windows 10/11 (64 bit) ve Microsoft Edge WebView2 Runtime. WebView2 Windows 11'de hazır gelir, yoksa [buradan](https://go.microsoft.com/fwlink/p/?LinkId=2124703) indirebilirsin.

> Kurulum dosyası dijital olarak imzalı olmadığı için Windows SmartScreen uyarı verebilir. "Ek bilgi" > "Yine de çalıştır" ile devam edebilirsin.

## Kullanım
- Modele çift tıkla, pencereye sürükle-bırak yap ya da sol üstteki klasör düğmesini kullan.
- Sol tık döndürür, sağ tık kaydırır, tekerlek yakınlaştırır. Boş alana çift tık modeli ekrana sığdırır.
- Sağ alt köşesinde ◢ işareti olan düğmelerin kendi ayar paneli var. Panel o köşeye tıklayınca ya da sağ tıkla açılır.
- Dokular ve `.mtl` / `.bin` dosyaları modelin klasöründen otomatik okunur. Sadece model dosyasını sürükleyip bıraktığında da böyledir.

| Kısayol | İşlev |
|---|---|
| `H` | Seçili parçaları gizle |
| `Shift + H` | Sadece seçili parçaları göster |
| `Alt + H` | Hepsini göster |
| `F` | Seçili parçalara odaklan |
| `Ctrl + sol-tık` | Birden fazla parça seç |

## Kaldırma
Windows Ayarlar > Uygulamalar'dan kaldır. Ayarlar dahil her şey silinir.
Kurulumsuz sürümde `Remove-Associations.bat`'ı çalıştırıp klasörü silmen yeterli.

## Kaynaktan derleme
```
winget install Microsoft.DotNet.SDK.8
winget install JRSoftware.InnoSetup
build-release.bat
```
Çıktılar `release\` klasörüne gider. Sürüm numarası `VERSION` dosyasında tutulur.

## Lisans
MIT, bkz. [LICENSE](LICENSE). Üçüncü taraf bileşenler: [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).
