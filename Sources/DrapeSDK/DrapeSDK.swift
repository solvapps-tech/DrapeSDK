import Foundation
import UIKit

// MARK: - Public Enums & Models

public enum DrapeCategory: String, Sendable {
    case upperBody = "upper_body"
    case lowerBody = "lower_body"
    case dresses = "dresses"
}

public struct DrapeResult: Decodable, Sendable {
    public let success: Bool
    public let sessionId: String
    public let imageUrl: String
}

public enum DrapeError: Error {
    case missingPlistKey
    case invalidApiKey
    case imageConversionFailed
    case networkError(String)
    case invalidResponse
    case serverError(String)
    
    public var localizedDescription: String {
        switch self {
        case .missingPlistKey: return "DrapeAPIKey 'Info.plist' dosyasında bulunamadı."
        case .invalidApiKey: return "API Anahtarı geçersiz."
        case .serverError(let msg): return "Sunucu Hatası: \(msg)"
        default: return "Bilinmeyen hata."
        }
    }
}

// MARK: - Drape Singleton

// DÜZELTME 1: Availability Check (Derleyici hatasını çözer)
// DÜZELTME 2: MainActor (Concurrency hatasını çözer)
@available(iOS 15.0, *)
@MainActor
public final class Drape {
    
    public static let shared = Drape()
    
    private var apiKey: String?
    private let plistKeyName = "DrapeAPIKey"
    // URL'yi kendi proje ID'n ile değiştirmeyi unutma!
    private let baseUrl = "https://us-central1-drape-ff64f.cloudfunctions.net"
    
    private init() {
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: plistKeyName) as? String
        if self.apiKey == nil {
            print("⚠️ DrapeSDK: Info.plist içinde \(plistKeyName) bulunamadı.")
        }
    }
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func tryOn(
        humanImage: UIImage,
        productUrl: String,
        description: String = "clothing",
        category: DrapeCategory = .upperBody
    ) async throws -> DrapeResult {
        
        guard let currentKey = apiKey, !currentKey.isEmpty else {
            throw DrapeError.missingPlistKey
        }
        
        guard let imageData = humanImage.jpegData(compressionQuality: 0.8) else {
            throw DrapeError.imageConversionFailed
        }
        
        // Network işlemleri
        let uploadInfo = try await getUploadUrl(apiKey: currentKey)
        try await uploadImageToStorage(url: uploadInfo.uploadUrl, data: imageData, contentType: uploadInfo.requiredContentType)
        let result = try await startTryOnProcess(
            apiKey: currentKey,
            storagePath: uploadInfo.storagePath,
            productUrl: productUrl,
            description: description,
            category: category
        )
        
        return result
    }
}

// MARK: - Private Networking Helpers

// Extension'a da available eklememiz gerekebilir, çünkü async kullanıyorlar.
@available(iOS 15.0, *)
private extension Drape {
    
    struct UploadUrlResponse: Decodable { let result: UploadUrlResult }
    struct UploadUrlResult: Decodable {
        let uploadUrl: String
        let storagePath: String
        let requiredContentType: String
    }
    struct TryOnResponse: Decodable { let result: DrapeResult }
    
    nonisolated func getUploadUrl(apiKey: String) async throws -> UploadUrlResult {
        let url = URL(string: "\(baseUrl)/getUploadUrl")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = ["data": ["extension": "jpg"]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DrapeError.serverError("Upload URL başarısız.")
        }
        return try JSONDecoder().decode(UploadUrlResponse.self, from: data).result
    }
    
    nonisolated func uploadImageToStorage(url: String, data: Data, contentType: String) async throws {
        guard let uploadUrl = URL(string: url) else { throw DrapeError.networkError("URL Hatası") }
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
             throw DrapeError.serverError("Storage Upload Hatası: \(httpResponse.statusCode)")
        }
    }
    
    nonisolated func startTryOnProcess(apiKey: String, storagePath: String, productUrl: String, description: String, category: DrapeCategory) async throws -> DrapeResult {
        let url = URL(string: "\(baseUrl)/startTryOn")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 300
        
        let body: [String: Any] = [
            "data": [
                "storagePath": storagePath,
                "garmentUrl": productUrl,
                "garmentDesc": description,
                "category": category.rawValue
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw DrapeError.networkError("No Response") }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Hata ayıklama
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let msg = error["message"] as? String {
                throw DrapeError.serverError(msg)
            }
            throw DrapeError.serverError("Status: \(httpResponse.statusCode)")
        }
        return try JSONDecoder().decode(TryOnResponse.self, from: data).result
    }
}
