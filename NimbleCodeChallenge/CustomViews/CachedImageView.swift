//
//  CachedImageView.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 05/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

class CachedImageView: UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    private var urlStringForChecking: String?
    
    
    func loadImage(urlString: String, bgColor: UIColor? = UIColor.gray) {
        self.image = nil
        self.backgroundColor = bgColor
        self.urlStringForChecking = urlString
        let urlKey = urlString as NSString
        
        if let cachedItem = CachedImageView.imageCache.object(forKey: urlKey) {
            self.image = cachedItem
            return
        }
        
        guard let url = URL(string: urlString) else {
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
                    CachedImageView.imageCache.setObject(image, forKey: urlKey)
                    if urlString == strongSelf.urlStringForChecking {
                        strongSelf.image = image
                    }
                }
            }
            
        }).resume()
    }
    
    public static func clearImageCache(){
        self.imageCache.removeAllObjects()
    }
    
}
