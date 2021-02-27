//
//  UIImage+Extensions.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 27/02/21.
//

import Foundation
import UIKit


extension UIImage {

    // Source: https://stackoverflow.com/q/62547523/2304697
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}
