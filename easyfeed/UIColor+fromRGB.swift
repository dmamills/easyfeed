//
//  UIColor+fromRGB.swift
//  easyfeed
//
//  Created by Daniel Mills on 2017-02-17.
//  Copyright © 2017 Daniel Mills. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {

    static func fromRGB(_ r: Int, _ g : Int, _ b: Int, _ a : Float = 1.0) -> UIColor {
        return UIColor(colorLiteralRed: (Float(r) / 255.0), green: (Float(g) / 255.0), blue: (Float(b) / 255.0), alpha: a)
    }
}
