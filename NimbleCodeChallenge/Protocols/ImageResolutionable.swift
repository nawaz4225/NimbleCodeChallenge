//
//  ImageResolutionable.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 16/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation


protocol ImageResolutionable {
    var appendingString: String { get }
}

extension ImageResolutionable {
    
    var appendingString: String {
        get {
            //default appendingString
            return "l"
        }
    }

    func highQualityImageURL(imageURL: String) -> String {
        return "\(imageURL)\(self.appendingString)"
    }
}
