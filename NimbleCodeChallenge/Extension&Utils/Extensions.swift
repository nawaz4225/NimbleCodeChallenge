//
//  Extensions.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 04/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import UIKit

// color Extensions "#fffff" to color
extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars = ["F","F"] + chars
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}

/// An extension to `UIImage` for creating images with shapes.
extension UIImage {

    /// Creates a circular outline image.
    class func outlinedEllipse(size: CGSize, color: UIColor, lineWidth: CGFloat = 1.0) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
                return nil
        }

        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        // Inset the rect to account for the fact that strokes are
        // centred on the bounds of the shape.
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        context.addEllipse(in: rect)
        context.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
