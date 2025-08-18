//
//  SupabaseClient.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/13/25.
//

import Foundation

// Model that matches your 'physio_records' table
struct PhysioRecord: Codable {
    let user_id: String
    let task_id: String
    let prompt: String
    let choice: String?
    let start_time: String      // ISO8601
    let end_time: String
    let hr_samples: [Int]
    let reward: Double
    let meta: [String: String]?
}

final class SupabaseClient {
    static let shared = SupabaseClient()
    private init() {}

    // PostgREST endpoint for your table
    private var endpoint: URL {
        AppConfig.supabaseURL.appendingPathComponent("/rest/v1/physio_records")
    }

    // Minimal REST insert using URLSession (no SDK needed)
    func upload(_ record: PhysioRecord) async throws {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(AppConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")

        // PostgREST expects an array of rows
        req.httpBody = try JSONEncoder().encode([record])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "unknown error"
            throw NSError(domain: "upload", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        print("✅ Upload ok:", String(data: data, encoding: .utf8) ?? "")
    }
}

// Anonymous user id persisted locally
enum AppIdentity {
    static var userID: String {
        let key = "anon_user_id"
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        let v = UUID().uuidString
        UserDefaults.standard.set(v, forKey: key)
        return v
    }
}

// Helpers
extension Date {
    var iso8601String: String { ISO8601DateFormatter().string(from: self) }
}
