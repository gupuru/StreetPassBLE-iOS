//
//  CustomTextFeild.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/03/01.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextFeild: UITextField {
    
    // 角丸の半径(0で四角形)
    @IBInspectable var cornerRadius: CGFloat = 0.0
    
    // 枠
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    override func drawRect(rect: CGRect) {
        // 角丸
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)
        // 枠線
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = borderWidth
        
        super.drawRect(rect)
    }
    
}