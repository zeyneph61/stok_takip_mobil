# Stock Movements - Flutter/iOS Uygulama Özeti

## ✅ Tamamlanan İşlemler

### 1. **Model Sınıfı** ✓
- **Dosya:** `lib/models/stock_movement.dart`
- StockMovement model sınıfı oluşturuldu
- Product ile ilişkilendirildi
- JSON serialization eklendi
- `isIn` ve `isOut` helper property'leri eklendi

### 2. **API Service** ✓
- **Dosya:** `lib/services/stock_movement_service.dart`
- `getStockMovements()` - Tüm hareketleri getirir
- `createStockMovement()` - Yeni hareket ekler (manuel)
- `getMovementsByProduct()` - Ürüne göre hareketler
- Hata yönetimi ve timeout kontrolü eklendi

### 3. **UI Ekranı** ✓
- **Dosya:** `lib/screens/stock_movements_screen.dart`
- Modern card tasarımlı liste
- Pull-to-refresh özelliği
- Loading ve error state'leri
- Tarih formatı: "dd.MM.yyyy HH:mm"
- Renk kodları web ile uyumlu:
  - In (Giriş): #10A760 (Yeşil)
  - Out (Çıkış): #DA3E33 (Kırmızı)

### 4. **Navigation & Routing** ✓
- **Dosya:** `lib/main.dart`
- Route sistemi eklendi:
  - `/dashboard` - Ana sayfa
  - `/inventory` - Stok sayfası
  - `/stock-movements` - Stok hareketleri
- Named routes ile navigation

### 5. **Drawer/Sidebar Menu** ✓
- **Dosya:** `lib/widgets/common/app_drawer.dart`
- Yeniden kullanılabilir AppDrawer widget'ı
- Stock Movements menüsü eklendi
- Aktif sayfa vurgulama
- Modern tasarım

### 6. **Dependencies** ✓
- **Dosya:** `pubspec.yaml`
- `intl: ^0.18.1` paketi eklendi (tarih formatı için)
- `flutter pub get` başarıyla çalıştırıldı

## 📱 Ekran Görüntüsü Tasarımı

```
┌─────────────────────────────────┐
│ ☰  Stock Movements              │ <- AppBar (Mavi)
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────────┐  │
│  │ [↓] Çubuk Kraker          │  │
│  │     Abur Cubur            │  │
│  │     🕐 25.12.2025 17:13   │  │
│  │                      50   │  │ <- Yeşil (In)
│  │                      In   │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ [↑] Long Grain Rice       │  │
│  │     Grains & Pulses       │  │
│  │     🕐 23.12.2025 17:13   │  │
│  │                      10   │  │ <- Kırmızı (Out)
│  │                      Out  │  │
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
         [🔄] <- Refresh Button
```

## 🧪 Test Senaryoları

### Test 1: Sayfa Navigasyonu
1. Uygulamayı başlat
2. Sol üstteki hamburger menüye tıkla
3. "Stock Movements" seç
4. **Beklenen:** Stock Movements sayfası açılır

### Test 2: Veri Yükleme
1. Stock Movements sayfasına git
2. API sunucusunun çalıştığından emin ol (http://10.0.2.2:5000)
3. **Beklenen:** Hareketler listesi görünür, en yeni tarih üstte

### Test 3: Pull to Refresh
1. Stock Movements sayfasında
2. Ekranı aşağı çek (pull down)
3. **Beklenen:** Liste yenilenir, yeni hareketler görünür

### Test 4: Refresh Button
1. Sağ alttaki mavi yuvarlak butona tıkla
2. **Beklenen:** Veriler yeniden yüklenir

### Test 5: Ürün Güncelleme Sonrası Hareket
1. Inventory sayfasına git
2. Bir ürün düzenle, miktarını değiştir (örn: 100 → 50)
3. Kaydet
4. Stock Movements'a git
5. **Beklenen:** En üstte "Out" tipi 50 adetlik hareket görünür

### Test 6: Hata Durumu
1. API sunucusunu kapat
2. Stock Movements'a git
3. **Beklenen:** Hata mesajı ve "Retry" butonu görünür
4. "Retry" butonuna tıkla
5. API'yi aç ve tekrar dene

## 🔧 API Konfigürasyonu

### Android Emülatör
```dart
// lib/services/stock_movement_service.dart
static const String baseUrl = 'http://10.0.2.2:5000/api/StockMovement';
```

### Fiziksel Cihaz (iPhone/iPad)
```dart
// Bilgisayarınızın IP adresini kullanın
static const String baseUrl = 'http://192.168.1.XXX:5000/api/StockMovement';
```

IP adresinizi öğrenmek için:
- Windows: `ipconfig` komutu
- Mac: `ifconfig` komutu
- Network ayarlarından bakın

## 🎨 Renk Paleti

```dart
// Primary Colors
Color primaryBlue = Color(0xFF1366D9);
Color linkBlue = Color(0xFF0F50AA);

// Status Colors
Color inStock = Color(0xFF10A760);   // Yeşil
Color outOfStock = Color(0xFFDA3E33); // Kırmızı

// Text Colors
Color primaryText = Color(0xFF383E49);
Color secondaryText = Color(0xFF5D6679);

// Background
Color mainBg = Color(0xFFF0F1F3);
```

## 📝 Önemli Notlar

### 1. Otomatik Hareket Kaydı
- Ürün stoğu değiştirildiğinde backend otomatik olarak StockMovement kaydı oluşturur
- Flutter'da ekstra işlem gerekmez
- Tarih sunucu tarafında otomatik atanır

### 2. Tarih Formatı
- Backend: `2025-12-25T17:13:14.510` (ISO 8601)
- Flutter: `dd.MM.yyyy HH:mm` formatında gösterir
- `intl` paketi kullanılır: `DateFormat('dd.MM.yyyy HH:mm').format(date)`

### 3. Circular Reference
- Backend'de `ReferenceHandler.IgnoreCycles` ayarlandı
- Product ve StockMovement arasında döngüsel referans önlendi
- Flutter'da sorunsuz JSON parse edilir

### 4. Sayfalama
- Web'de: 10 satır/sayfa ile pagination
- Flutter'da: ListView.builder otomatik scroll
- İleride infinite scroll eklenebilir

## 🚀 Çalıştırma Adımları

1. **Backend API'yi başlat:**
```bash
cd Stok_Takip
dotnet run
```

2. **Flutter uygulamasını çalıştır:**
```bash
cd stok_takip_mobil
flutter run
```

3. **Android Emülatör veya fiziksel cihazı seç**

4. **Stock Movements menüsüne git**

## 🔍 Debug İpuçları

### API Bağlantı Sorunu
```dart
// Terminal'de şunu göreceksiniz:
[log] Fetching stock movements from: http://10.0.2.2:5000/api/StockMovement
[log] Response status: 200
[log] Stock movements loaded: 12
```

### Boş Liste
- Backend'de en az bir hareket var mı kontrol edin
- SQL: `SELECT * FROM StockMovements`
- Swagger: `http://localhost:5000/swagger`

### JSON Parse Hatası
- Backend'de Product include edildiğinden emin olun
- Circular reference ayarları yapıldı mı kontrol edin

## 📦 Dosya Yapısı

```
lib/
├── models/
│   ├── product.dart
│   └── stock_movement.dart         ← YENİ
├── services/
│   ├── product_service.dart
│   └── stock_movement_service.dart ← YENİ
├── screens/
│   ├── dashboard_screen.dart       ← GÜNCELLENDİ
│   └── stock_movements_screen.dart ← YENİ
├── widgets/
│   └── common/
│       └── app_drawer.dart         ← YENİ
└── main.dart                       ← GÜNCELLENDİ
```

## ✅ Checklist

- [x] Model oluşturuldu
- [x] Service oluşturuldu
- [x] UI ekranı tasarlandı
- [x] Navigation eklendi
- [x] Drawer menüsü güncellendi
- [x] Dependencies yüklendi
- [x] Hata kontrolü yapıldı
- [ ] Emülatörde test edildi (sırada)
- [ ] Fiziksel cihazda test edildi (sırada)

## 🎯 Sonraki Adımlar (Opsiyonel)

1. **Filtering/Arama:**
   - Ürün adına göre arama
   - Tarih aralığına göre filtreleme
   - Tip'e göre filtreleme (In/Out)

2. **Detay Sayfası:**
   - Harekete tıklayınca detay göster
   - Total price bilgisi
   - İlgili ürünü göster

3. **Infinite Scroll:**
   - Sayfalama API'si ekle (backend)
   - Flutter'da infinite scroll implementasyonu

4. **İstatistikler:**
   - Günlük/haftalık/aylık özet
   - Grafik gösterimi
   - En çok hareket gören ürünler

## 🌐 Backend Endpoint'leri

```
GET  /api/StockMovement
POST /api/StockMovement
```

**Response Example:**
```json
[
  {
    "id": 12,
    "productId": 1,
    "movementType": "Out",
    "quantity": 50,
    "totalPrice": 500.00,
    "date": "2025-12-25T17:13:19.977",
    "product": {
      "id": 1,
      "name": "Çubuk Kraker",
      "category": "Abur Cubur"
    }
  }
]
```

---

**Son Güncelleme:** 25.12.2025
**Versiyon:** 1.0
**Platform:** Flutter (iOS/Android)
