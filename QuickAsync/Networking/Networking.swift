//
//  Networking.swift
//  QuickAsync
//
//  Created by Donny Wals on 08/06/2021.
//

import Foundation

class Networking {
    func load(_ url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8)!
    }
    
    func load<T: Decodable>(_ url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func load<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func data(for url: URL) async throws -> Data {
        return try await URLSession.shared.data(from: url).0
    }
}
