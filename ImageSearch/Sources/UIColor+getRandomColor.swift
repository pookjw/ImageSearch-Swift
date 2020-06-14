//
//  UIColor+getRandomColor..swift
//  ImageSearch
//
//  Created by pook on 6/11/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit

// 랜덤 색상을 뽑아주는 method 입니다. 랜덤 색상과 그 반전 색상이 나옵니다.
// r, g, b의 값이 0~255에서 중앙값에 근접할 경우 원래 색상과 inverted 색상이 별로 차이가 없는 문제가 있습니다. 이때문에 원래 색상을 배경색으로 설정하고, inverted 색상을 글자색으로 설정하는 곳에서 가독성이 안 좋은 문제가 있습니다.
// 이 부분은 inverted를 white나 black로 고정시키는 방법을 생각하고 있습니다.
extension UIColor {
    static func getRamdomColor() -> (color: UIColor, inverted: UIColor) {
        let r = CGFloat(arc4random_uniform(256)) / 255
        let g = CGFloat(arc4random_uniform(256)) / 255
        let b = CGFloat(arc4random_uniform(256)) / 255
        return (UIColor(red: r, green: g, blue: b, alpha: 1.0), UIColor(red: 1-r, green: 1-g, blue: 1-b, alpha: 1.0))
    }
}
