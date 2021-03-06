//
//  CachedImageView.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 05/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

enum ImageQualityFactory: String {
    case low = ""
    case high = "l"
    
}

class CachedImageView: UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    private var urlStringForChecking: String?
    
    
    func loadImage(urlString: String, quality: ImageQualityFactory, bgColor: UIColor? = UIColor.gray) {
        self.image = nil
        self.backgroundColor = bgColor
        let finalString = "\(urlString)\(quality.rawValue)"
        self.urlStringForChecking = finalString
        let urlKey = finalString as NSString
        if let cachedItem = CachedImageView.self.imageCache.object(forKey: urlKey) {
            self.image = cachedItem
            return
        }
        
        guard let url = URL(string: finalString) else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            
            guard let strongSelf = self else {
                return
            }
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                if let imageData = data,  let image = UIImage(data: imageData) {
                    CachedImageView.self.imageCache.setObject(image, forKey: urlKey)
                    if finalString == strongSelf.urlStringForChecking {
                        strongSelf.image = image
                    }
                }
            }
            
        }).resume()
    }
    
    public static func clearImageCache(){
        CachedImageView.imageCache.removeAllObjects()
    }
    
}
