//
//  Serializable.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 16/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation


protocol JSONCodable: Codable {
    typealias JSON = [String : Any]
    func toDictionary() -> JSON?
}
 
extension JSONCodable {
    
    func toDictionary() -> JSON? {
        // Encode the data
        if let jsonData = try? JSONEncoder().encode(self),
            // Create a dictionary from the data
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
            return dict
        }
        return nil
    }
    
}
