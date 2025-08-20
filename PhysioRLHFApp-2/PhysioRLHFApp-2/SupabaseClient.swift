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
        let jsonData = try JSONEncoder().encode([record])
        req.httpBody = jsonData
        
        print("🌐 Sending request to: \(endpoint)")
        print("📦 Request body: \(String(data: jsonData, encoding: .utf8) ?? "invalid json")")
        print("🔑 Using API key: \(AppConfig.supabaseAnonKey.prefix(20))...")

        let (data, resp) = try await URLSession.shared.data(for: req)
        
        if let http = resp as? HTTPURLResponse {
            print("📡 Response status: \(http.statusCode)")
            print("📡 Response headers: \(http.allHeaderFields)")
        }
        
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "unknown error"
            print("❌ Upload failed with status: \((resp as? HTTPURLResponse)?.statusCode ?? -1)")
            print("❌ Error message: \(msg)")
            print("❌ Response data: \(String(data: data, encoding: .utf8) ?? "no data")")
            throw NSError(domain: "upload", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        print("✅ Upload successful:", String(data: data, encoding: .utf8) ?? "")
    }
    
    // Fetch task history from Supabase
    func fetchTaskHistory() async throws -> [TaskHistoryRecord] {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "GET"
        req.setValue("Bearer \(AppConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        
        // Add query parameters for ordering and limiting
        let queryURL = endpoint.appending(queryItems: [
            URLQueryItem(name: "order", value: "created_at.desc"),
            URLQueryItem(name: "limit", value: "50")
        ])
        req.url = queryURL

        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "unknown error"
            throw NSError(domain: "fetch", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        
        // Parse the response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let records = try decoder.decode([PhysioRecord].self, from: data)
        
        // Convert to TaskHistoryRecord
        return records.compactMap { record in
            // Parse option A and B heart rate data from meta
            let optionAHR = record.meta?["option_a_hr"]?.components(separatedBy: ",").compactMap { Int($0) } ?? []
            let optionBHR = record.meta?["option_b_hr"]?.components(separatedBy: ",").compactMap { Int($0) } ?? []
            
            // Parse dates
            let dateFormatter = ISO8601DateFormatter()
            let startDate = dateFormatter.date(from: record.start_time) ?? Date()
            let endDate = dateFormatter.date(from: record.end_time) ?? Date()
            
            return TaskHistoryRecord(
                taskId: record.task_id,
                category: record.meta?["category"] ?? "Unknown",
                question: record.prompt.replacingOccurrences(of: "[EN] ", with: ""),
                userChoice: record.choice ?? "Unknown",
                startTime: startDate,
                endTime: endDate,
                optionAHeartRate: optionAHR,
                optionBHeartRate: optionBHR,
                reward: record.reward,
                meta: record.meta ?? [:]
            )
        }
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
