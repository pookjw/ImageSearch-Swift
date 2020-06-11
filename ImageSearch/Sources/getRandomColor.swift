//
//  getRandomColor.swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

func getRamdomColor() -> (color: UIColor, inverted: UIColor) {
    let r = CGFloat(arc4random_uniform(256)) / 255
    let g = CGFloat(arc4random_uniform(256)) / 255
    let b = CGFloat(arc4random_uniform(256)) / 255
    return (UIColor(red: r, green: g, blue: b, alpha: 1.0), UIColor(red: 1-r, green: 1-g, blue: 1-b, alpha: 1.0))
}
