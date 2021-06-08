//
//  Authorizer.swift
//  QuickAsync
//
//  Created by Donny Wals on 08/06/2021.
//

import Foundation

struct Token {
    var validUntil: Date
    let id: UUID
    
    var isValid: Bool {
        return validUntil > Date()
    }
}

actor Authorizer {
    private var currentToken: Token?
    private var refreshTask: Task.Handle<Token, Error>?
    private let endpoint = URL(string: "https://www.uuidgenerator.net/api/version4")!
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func accessToken() async throws -> Token {
        if let handle = refreshTask {
            return try await handle.get()
        }
        
        if let token = currentToken, token.isValid {
            return currentToken!
        } else {
            refreshTask = async {
                defer { refreshTask = nil }
                currentToken = try await refreshToken(currentToken)
                return currentToken!
            }
            
            return try await refreshTask!.get()
        }
    }
    
    func refreshToken(_ token: Token?) async throws -> Token {
        let tokenId: UUID = UUID(uuidString: try await networking.load(endpoint))!
        // tokens are valid for 10 seconds
        let tokenExpiresAt = Date().addingTimeInterval(10)
        return Token(validUntil: tokenExpiresAt, id: tokenId)
    }
    
    func authorize(_ request: URLRequest) async throws -> URLRequest {
        var mutRequest = request
        let token = try await accessToken()
        mutRequest.addValue("Bearer \(token.id)", forHTTPHeaderField: "Authorization")
        return mutRequest
    }
}
