# 🚀 Anliyo - Akıllı YKS & LGS Hazırlık Asistanı

![App Logo](assets/icon/icon.png) [![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![State Management](https://img.shields.io/badge/State-Riverpod-purple)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**Anliyo**, öğrencilerin sınav hazırlık süreçlerini (YKS, TYT, AYT, LGS) verimli bir şekilde yönetmelerini sağlayan, deneme analizleri ve grafiksel gelişim takibi sunan kapsamlı bir mobil uygulamadır.

---

## 📱 Ekran Görüntüleri

| Giriş Ekranı | Ana Sayfa | Deneme Ekleme | Grafik Analizi |
|:---:|:---:|:---:|:---:|
| <img src="assets/screenshots/login.png" width="200"/> | <img src="assets/screenshots/home.png" width="200"/> | <img src="assets/screenshots/add_exam.png" width="200"/> | <img src="assets/screenshots/analysis.png" width="200"/> | <img src="assets/screenshots/question_add.png" width="200"/> | <img src="assets/screenshots/questions.png" width="200"/> |

---

## ✨ Özellikler

### 🔐 Güvenli Giriş & Kayıt
* **Çoklu Giriş Yöntemi:** E-posta/Şifre, **Google ile Giriş** ve **Apple ile Giriş (Sign in with Apple)** desteği.
* **Onboarding (Karşılama):** Kullanıcıyı tanıyan anketler (Alan seçimi, hedef belirleme).

### 📊 Deneme Takibi ve Analiz
* **Detaylı Kayıt:** TYT ve AYT denemelerini ders bazında (Doğru/Yanlış) kaydetme.
* **Net Hesaplama:** ÖSYM katsayılarına uygun otomatik net hesaplama.
* **Grafiksel Gelişim:** `fl_chart` ile ders bazlı net değişim grafikleri.
    * *Genel Bakış, Matematik, Fen, Türkçe/Sosyal ayrı grafikler.*
    * *Maksimum Net ve Ortalama Net göstergeleri.*

### 🎯 Kişiselleştirilmiş Deneyim
* **Alan Bazlı Filtreleme:** Sayısal, Eşit Ağırlık, Sözel ve Dil öğrencileri için sadece ilgili derslerin gösterimi.
* **Hedef Takibi:** Öğrencinin hedeflediği üniversite/bölüm odaklı ilerleme.

### 🛠 Diğer Özellikler
* **Bilgi Notları:** Derslere özel pratik notlar ekleme ve kaydetme.
* **Geri Sayım:** Sınava kalan süreyi gösteren sayaç.
* **Karanlık Mod (Dark Mode):** Göz yormayan tema desteği.

---

## 🛠 Kullanılan Teknolojiler

Bu proje **Flutter** ile geliştirilmiş olup, aşağıdaki kütüphane ve mimarileri kullanmaktadır:

* **State Management:** `flutter_riverpod` (Modern ve güvenli durum yönetimi).
* **Backend & Auth:** `firebase_auth`, `cloud_firestore` (Veri saklama ve kimlik doğrulama).
* **Routing:** `go_router` (Sayfalar arası gezinme).
* **UI/UX:** `google_fonts`, `gap`, `cupertino_icons`.
* **Grafikler:** `fl_chart` (Deneme analizleri için).
* **Yerel Depolama:** `shared_preferences` (Basit ayarlar ve onboarding durumu için).
* **Tarih İşlemleri:** `intl`, `timeago`.

---

## 📩 İletişim

Geliştirici: **[Kaan GÜL]**
E-posta: [kaan.gul.developer@gmail.com]
LinkedIn: [[Profil Linkiniz](https://www.linkedin.com/in/gkaan/)]

---
© 2024 Anliyo. Tüm hakları saklıdır.