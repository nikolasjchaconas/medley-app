//
//  GradientLayer.swift
//  Medley
//
//  Created by Joe Song on 4/21/16.
//  Copyright © 2016 Medley Team. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    func blueGradient() -> CAGradientLayer {
        let blueTop = UIColor(red: 30/255.0, green: 120/255.0, blue: 239/255.0, alpha: 1.0)
        let blueBottom = UIColor( red: 74/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [blueTop.CGColor, blueBottom.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    func purpleGradient() -> CAGradientLayer {
        let purpleTop = UIColor(red: 89/255.0, green: 86/255.0, blue: 214/255.0, alpha: 1.0)
        let purpleBottom = UIColor( red:198/255.0, green: 68/255.0, blue: 252/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [purpleTop.CGColor, purpleBottom.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}