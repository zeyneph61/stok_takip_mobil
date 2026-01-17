# 📱 Stok Takip Mobil

Flutter & ASP.NET Core Web API tabanlı cross-platform mobil stok takip uygulaması.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-8.0-512BD4?logo=.net)](https://dotnet.microsoft.com)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-CC2927?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)

## 📋 Proje Hakkında

Modern ve kullanıcı dostu bir mobil stok takip sistemi. iOS ve Android platformlarında çalışan bu uygulama, ürün yönetimi, stok takibi, otomatik uyarılar ve detaylı raporlama özellikleri sunar.

**Backend:** ASP.NET Core 8.0 Web API + Entity Framework Core + SQL Server  
**Frontend:** Flutter 3.9.2 (iOS & Android)  
**Mimari:** Clean Architecture + RESTful API

---

## ✨ Özellikler

### 📦 Ürün Yönetimi
- ✅ Ürün ekleme, güncelleme, silme (CRUD)
- ✅ Kategori bazlı ürün sınıflandırma
- ✅ Ürün arama ve filtreleme
- ✅ Sayfalama sistemi (5 ürün/sayfa)
- ✅ Bottom sheet ile hızlı düzenleme

### 📊 Dashboard
- ✅ Özet istatistikler (toplam stok, ürün sayısı, kategori sayısı)
- ✅ En çok kâr getiren kategoriler
- ✅ En çok satan ürünler (ilk 3)
- ✅ Düşük stok, stokta yok ve son kullanma uyarıları
- ✅ Grid layout ile modern kart tasarımı

### 📈 Stok Hareketleri
- ✅ Giriş/çıkış hareketlerinin kaydı ve görüntülenmesi
- ✅ Otomatik stok hareketi oluşturma (ürün güncellemelerinde)
- ✅ 5 farklı filtreleme özelliği:
  - Tarih aralığı (başlangıç/bitiş)
  - Hareket tipi (In/Out/All)
  - Kategori
  - Ürün adı
  - Tümünü temizle
- ✅ Sayfalama (10 hareket/sayfa)
- ✅ Pull-to-refresh

### 🔔 Otomatik Uyarı Sistemi
- ⚠️ **Düşük Stok Uyarısı:** Miktar eşik değerinin altına düştüğünde
- ⚠️ **Son Kullanma Tarihi Uyarısı:** 30 gün içinde dolacak ürünler
- ⚠️ **Stokta Yok Uyarısı:** Miktar sıfır olan ürünler

### 💰 Fiyat Geçmişi
- ✅ Otomatik fiyat değişikliği kaydı (Backend)
- ✅ Alış ve satış fiyatı geçmişi

### 📱 Mobil Uygulama Özellikleri
- ✅ Material Design UI/UX
- ✅ Responsive layout
- ✅ Loading & error states
- ✅ Pull-to-refresh
- ✅ Drawer menu navigasyonu
- ✅ Bottom navigation bar

---

## 🏗️ Teknoloji Stack

### Backend
- **Framework:** ASP.NET Core 8.0 Web API
- **ORM:** Entity Framework Core
- **Veritabanı:** SQL Server (LocalDB/Express)
- **API Dokümantasyonu:** Swagger UI
- **Özellikler:**
  - RESTful API mimarisi
  - CORS desteği
  - JSON serileştirme (ReferenceHandler.IgnoreCycles)
  - Otomatik ilişki yükleme (Include)

### Frontend (Mobile)
- **Framework:** Flutter 3.9.2
- **Dil:** Dart
- **Paketler:**
  - `http: ^0.13.6` - API istekleri
  - `intl: ^0.18.1` - Tarih formatları
  - `cupertino_icons: ^1.0.8` - iOS iconları
- **State Management:** StatefulWidget
- **Mimari:** Clean Architecture (models, services, screens, widgets)

---

## 📂 Proje Yapısı

```
stok_takip_mobil/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── models/                      # Veri modelleri
│   │   ├── product.dart
│   │   ├── stock_movement.dart
│   │   ├── category.dart
│   │   ├── sales_report.dart
│   │   ├── low_stock_alert.dart
│   │   └── expiry_alert.dart
│   ├── services/                    # API servisleri
│   │   ├── product_service.dart
│   │   ├── stock_movement_service.dart
│   │   ├── category_service.dart
│   │   ├── dashboard_service.dart
│   │   └── ...
│   ├── screens/                     # Ekranlar
│   │   ├── dashboard_screen.dart
│   │   ├── stock_movements_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_tab.dart
│   │   └── inventory/
│   │       └── inventory_tab.dart
│   └── widgets/                     # Yeniden kullanılabilir bileşenler
│       ├── common/
│       │   ├── app_drawer.dart
│       │   └── custom_card.dart
│       └── product_edit_bottom_sheet.dart
├── android/                         # Android yapılandırması
├── ios/                            # iOS yapılandırması
├── pubspec.yaml                    # Bağımlılıklar
└── README.md                       # Bu dosya
```

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler

**Backend:**
- .NET 8 SDK veya üzeri
- SQL Server (LocalDB veya Express)
- Visual Studio 2022 / VS Code

**Frontend:**
- Flutter SDK 3.9.2 veya üzeri
- Android Studio / Xcode (iOS için macOS gerekli)
- Android Emulator veya fiziksel cihaz

### Backend Kurulumu

1. **Veritabanı bağlantısını ayarlayın:**
   ```bash
   # appsettings.json dosyasındaki ConnectionString'i güncelleyin
   ```

2. **Veritabanını oluşturun:**
   ```bash
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

3. **Backend'i çalıştırın:**
   ```bash
   dotnet run
   # Backend: http://localhost:5000
   # Swagger: http://localhost:5000/swagger
   ```

### Flutter Kurulumu

1. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

2. **API URL'lerini ayarlayın:**
   
   **Android Emulator için:** Servis dosyalarında `http://10.0.2.2:5000` zaten ayarlı.
   
   **Fiziksel cihaz için:** Bilgisayarınızın IP adresini bulun:
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig
   ```
   
   Tüm `lib/services/*_service.dart` dosyalarındaki `baseUrl`'leri güncelleyin:
   ```dart
   static const String baseUrl = 'http://192.168.1.XXX:5000/api/...';
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   # Tüm cihazları listele
   flutter devices
   
   # Uygulamayı çalıştır
   flutter run
   
   # Belirli cihazda çalıştır
   flutter run -d <device_id>
   ```

---

## 🌐 API Endpoints

### Product
- `GET /api/Product` - Tüm ürünleri listele
- `GET /api/Product/{id}` - Ürün detayı
- `POST /api/Product` - Yeni ürün ekle
- `PUT /api/Product/{id}` - Ürün güncelle
- `DELETE /api/Product/{id}` - Ürün sil

### Stock Movement
- `GET /api/StockMovement` - Tüm hareketleri listele
- `GET /api/StockMovement/product/{productId}` - Ürüne göre hareketler

### Category
- `GET /api/Category` - Tüm kategorileri listele

### Sales Report
- `GET /api/SalesReport` - Satış raporları
- `GET /api/SalesReport/top-selling?count={n}` - En çok satan ürünler

### Alerts
- `GET /api/LowStockAlert` - Düşük stok uyarıları
- `GET /api/ExpiryAlert` - Son kullanma uyarıları

---

## 📸 Ekran Görüntüleri

### Dashboard
- Özet istatistikler
- En çok kâr getiren kategoriler
- En çok satan ürünler
- Uyarı sayıları

### Inventory
- Ürün listesi (5 ürün/sayfa)
- Arama ve filtreleme
- Bottom sheet ile düzenleme

### Stock Movements
- Giriş/çıkış hareketleri
- 5 farklı filtreleme
- Tarih, kategori, tip bazlı arama

---

## 🛠️ Geliştirme

### Hot Reload
```bash
# Terminal'de 'r' tuşuna basın
r
```

### Hot Restart
```bash
# Terminal'de 'R' tuşuna basın
R
```

### Build (Release)
```bash
# Android APK
flutter build apk --release

# iOS (macOS gerekli)
flutter build ios --release
```

---

## 🎨 Renk Paleti

```dart
Primary: #1366D9      // Mavi
Success: #10A760      // Yeşil
Danger: #DA3E33       // Kırmızı
Background: #F0F1F3   // Açık Gri
Text Primary: #383E49
Text Secondary: #5D6679
```

---

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

---

## 👤 Geliştirici

**Zeynep Hacısalihoğlu**
- Okul No: 22290449
- Platform: Flutter (iOS & Android)
- Backend: ASP.NET Core Web API

---

## 📚 Ek Dokümantasyon

- [Frontend Yapısı](FRONTEND_YAPISI_OZET.md)
- [Proje Çalışma Mantığı](PROJE_CALISMA_MANTIGI.md)
- [Kurulum ve Çalıştırma](KURULUM_VE_CALISTIRMA.md)
- [API Endpoints](API_ENDPOINTS.md)

---

**Son Güncelleme:** 17.01.2026
