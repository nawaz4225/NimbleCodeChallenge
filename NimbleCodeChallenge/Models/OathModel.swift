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
}
