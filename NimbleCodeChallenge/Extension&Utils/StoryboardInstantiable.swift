//
//  StoryboardInstantiable.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 14/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit


enum StoryboardType: String{
    case Main = "Main"
    case Launch = "LaunchScreen"
}


protocol StoryboardInstantiable : class {}

extension StoryboardInstantiable where Self : UIViewController {
    
    static func instantiate(from storyboard: StoryboardType,  bundle: Bundle? = nil) -> Self {
        let dynamicMetatype = Self.self
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: bundle)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "\(dynamicMetatype)") as? Self else {
            fatalError("Couldn’t instantiate view controller with identifier \(dynamicMetatype)")
        }
        
        return viewController
    }
}

extension UIViewController : StoryboardInstantiable {}
