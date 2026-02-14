//
//  DrapeLanguageManager.swift
//  DrapeSDK
//
//  Created by Mehmet Kılınçkaya on 14.02.2026.
//

import Foundation

enum AppTextKey {
    case upperBodyText
    case lowerBodyText
    case dressesText
    case choseFromGalery
    case openCamera
    case cancel
    case options
    case toAddPhoto
    case choseCategory
    case categorySelectText
    case choseProductPhoto
    case chosePhoto
    case error
    case done
    case success
    case photoSaved
    case chosenProduct
    case yourPhoto
    case productCategory
    case resultSeenHere
    case tryNow
    case save
    case share
}

class DrapeLanguageManager {
    
    private static let translations: [String: [AppTextKey: String]] = [
        "en": [
            .upperBodyText: "Upper Body",
            .lowerBodyText: "Lower Body",
            .dressesText: "Dresses or Suits",
            .choseFromGalery: "Choose from Photos",
            .openCamera: "Open Camera",
            .cancel: "Cancel",
            .options: "Options",
            .toAddPhoto: "To add a photo",
            .choseCategory: "Select Category",
            .categorySelectText: "Please select the product category for better results.",
            .choseProductPhoto: "Please select a product photo first.",
            .chosePhoto: "Please select a photo first.",
            .error: "Error",
            .done: "OK",
            .success: "Success",
            .photoSaved: "Photo saved to gallery.",
            .chosenProduct: "SELECTED PRODUCT",
            .yourPhoto: "YOUR PHOTO",
            .productCategory: "PRODUCT CATEGORY",
            .resultSeenHere: "RESULT WILL APPEAR HERE...",
            .tryNow: "Try Now",
            .save: "Save",
            .share: "Share"
        ],
        "tr": [
            .upperBodyText: "Üst Giyim",
            .lowerBodyText: "Alt Giyim",
            .dressesText: "Elbise veya Takım",
            .choseFromGalery: "Fotoğraflardan Seç",
            .openCamera: "Kamerayı Aç",
            .cancel: "Vazgeç",
            .options: "Seçenekler",
            .toAddPhoto: "Fotoğraf eklemek için",
            .choseCategory: "Kategori Seç",
            .categorySelectText: "Drape'in daha iyi sonuçlar üretmesi için seçili ürünün kategorisini seçiniz.",
            .choseProductPhoto: "Önce bir ürün fotoğraf seçmelisin.",
            .chosePhoto: "Önce bir fotoğraf seçmelisin.",
            .error: "Hata",
            .done: "Tamam",
            .success: "Başarılı",
            .photoSaved: "Fotoğraf galeriye kaydedildi.",
            .chosenProduct: "SEÇİLEN ÜRÜN",
            .yourPhoto: "SENİN FOTOĞRAFIN",
            .productCategory: "ÜRÜN KATEGORİSİ",
            .resultSeenHere: "SONUÇ BURADA GÖRÜNECEK...",
            .tryNow: "Hemen Dene",
            .save: "Kaydet",
            .share: "Paylaş"
        ]
    ]
    
    private static var currentLanguageCode: String {
        if let selectedLanguage = Drape.shared.selectedLanguage?.rawValue {
            return selectedLanguage
        } else {
            let language = Locale.current.identifier
            let code = String(language.prefix(2))
            return translations.keys.contains(code) ? code : "en"
        }
    }
    
    static func getText(for key: AppTextKey) -> String {
        let languageCode = currentLanguageCode
        
        if let dict = translations[languageCode], let text = dict[key] {
            return text
        }

        return translations["en"]?[key] ?? ""
    }
}

