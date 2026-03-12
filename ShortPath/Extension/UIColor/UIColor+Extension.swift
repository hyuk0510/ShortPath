//
//  UIColor+Extension.swift
//  ShortPath
//
//  Created by 선상혁 on 3/7/26.
//

import UIKit

extension UIColor {
    
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hex)
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xff0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00ff00) >> 8) / 255.0
        let b = CGFloat((rgb & 0x0000ff)) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
