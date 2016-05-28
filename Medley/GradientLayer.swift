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
        let blueTop = UIColor(red: 0/255.0, green: 121/255.0, blue: 202/255.0, alpha: 1.0)
        let blueBottom = UIColor( red: 62.5/255.0, green: 182.5/255.0, blue: 182.5/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [blueTop.CGColor, blueBottom.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    func blackGradient() -> CAGradientLayer {
        let grayBottom = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
        let blackTop = UIColor( red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [blackTop.CGColor, grayBottom.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    func purpleGradient() -> CAGradientLayer {
        let purpleTop = UIColor(red: 67.5/255.0, green: 64.5/255.0, blue: 160.5/255.0, alpha: 1.0)
        let purpleBottom = UIColor( red: 148.5/255.0, green: 102/255.0, blue: 189/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [purpleTop.CGColor, purpleBottom.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}