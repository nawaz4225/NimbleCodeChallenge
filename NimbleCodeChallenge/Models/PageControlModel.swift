//
//  PageControlModel.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 16/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation

struct PageControlModel: JSONCodable {
    var perPage: Int = 5
    var page: Int
    
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
    }
    
    init(with page: Int) {
        self.page = page
    }
    
}
