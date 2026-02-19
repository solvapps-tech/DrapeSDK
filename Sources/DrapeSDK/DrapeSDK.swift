//
//  Drape.swift
//  DrapeSDK
//
//  Created by Mehmet Kılınçkaya on 15.01.2026.
//

import Foundation
import UIKit

// MARK: - Public Enums & Models

public enum DrapeLanguage: String, Sendable {
    case en = "en"
    case tr = "tr"
}

public enum DrapeCategory: String, Sendable {
    case upperBody = "upper_body"
    case lowerBody = "lower_body"
    case dresses = "dresses"
    
    var visibleName: String {
        switch self {
        case .upperBody: return DrapeLanguageManager.getText(for: .upperBodyText)
        case .lowerBody: return DrapeLanguageManager.getText(for: .lowerBodyText)
        case .dresses: return DrapeLanguageManager.getText(for: .dressesText)
        }
    }
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
        case .missingPlistKey: return "DrapeAPIKey can not be found in 'Info.plist'."
        case .invalidApiKey: return "API Key is invalid."
        case .serverError(let msg): return "Server error: \(msg)"
        default: return "Unknown error."
        }
    }
}

// MARK: - Drape Singleton
public final class Drape {
    
    public static let shared = Drape()
    public var selectedLanguage: DrapeLanguage?
    private var apiKey: String?
    private let plistKeyName = "DrapeAPIKey"
    private let baseUrl = "https://us-central1-drape-ff64f.cloudfunctions.net"
    
    private init() {
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: plistKeyName) as? String
        if self.apiKey == nil {
            debugPrint("⚠️ DrapeSDK: \(plistKeyName) can not be found in info.plist.")
        }
    }
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func startDrapeFor(productImageUrl: String?, controller: UIViewController) {
        let drapeVC = DrapeViewController()
        drapeVC.productImageUrl = productImageUrl
        let nvc = UINavigationController(rootViewController: drapeVC)
        controller.present(nvc, animated: true)
    }
    
    public func tryOn(
        humanImage: UIImage,
        productUrl: String
    ) async throws -> DrapeResult {
        
        guard let currentKey = apiKey, !currentKey.isEmpty else {
            throw DrapeError.missingPlistKey
        }
        
        guard let imageData = humanImage.jpegData(compressionQuality: 0.8) else {
            throw DrapeError.imageConversionFailed
        }
        
        let uploadInfo = try await getUploadUrl(apiKey: currentKey)
        try await uploadImageToStorage(url: uploadInfo.uploadUrl, data: imageData, contentType: uploadInfo.requiredContentType)
        let result = try await startTryOnProcess(
            apiKey: currentKey,
            storagePath: uploadInfo.storagePath,
            productUrl: productUrl)
        
        return result
    }
}

// MARK: - Private Networking Helpers
private extension Drape {
    
    struct UploadUrlResponse: Decodable { let result: UploadUrlResult }
    struct UploadUrlResult: Decodable {
        let uploadUrl: String
        let storagePath: String
        let requiredContentType: String
    }
    struct TryOnResponse: Decodable { let result: DrapeResult }
    
    func getUploadUrl(apiKey: String) async throws -> UploadUrlResult {
        let url = URL(string: "\(baseUrl)/getUploadUrl")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = ["data": ["extension": "jpg"]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DrapeError.serverError("Upload URL fail.")
        }
        return try JSONDecoder().decode(UploadUrlResponse.self, from: data).result
    }
    
    func uploadImageToStorage(url: String, data: Data, contentType: String) async throws {
        guard let uploadUrl = URL(string: url) else { throw DrapeError.networkError("URL error") }
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
             throw DrapeError.serverError("Storage Upload Error: \(httpResponse.statusCode)")
        }
    }
    
    func startTryOnProcess(apiKey: String, storagePath: String, productUrl: String) async throws -> DrapeResult {
        let url = URL(string: "\(baseUrl)/startTryOn")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 300
        
        let body: [String: Any] = [
            "data": [
                "storagePath": storagePath,
                "garmentUrl": productUrl
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw DrapeError.networkError("No Response") }
        
        if !(200...299).contains(httpResponse.statusCode) {
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
