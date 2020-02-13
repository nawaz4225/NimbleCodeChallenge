//
//  OathModel.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation

struct OathModel: Codable {
    let accessToken, tokenType: String
    let expiresIn, createdAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case createdAt = "created_at"
    }
    
    /// check if accessToken is valid still
    func isValidAccessToken() -> Bool {
        // expire token before 5 second to secure next API calls
        let expiresTime = self.createdAt + (self.expiresIn - 500)
        
        print(self.getCurrentMillis(), expiresTime)
        if self.getCurrentMillis() > expiresTime {
            return false
        }
        
        return true
        
    }
    
    /// Get current time in seconds since 1970
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
}
