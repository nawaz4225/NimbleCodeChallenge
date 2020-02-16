//
//  UserModel.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 16/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation

struct UserModel: JSONCodable {
    var grantType: String
    var userName: String
    var password: String
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case userName = "username"
        case password
    }
}
