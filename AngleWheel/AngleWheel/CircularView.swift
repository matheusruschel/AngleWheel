//
//  Circle.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-16.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit

@IBDesignable class CircularView: UIView {

    @IBInspectable let lineWidth: CGFloat = 5
    @IBInspectable let lineColor: UIColor = .blue
    let offset: CGFloat = 10
    
    override func draw(_ rect: CGRect) {
        let newRect = CGRect(
            x: rect.minX + offset/2,
            y: rect.minY + offset/2,
            width: rect.width - offset,
            height: rect.height - offset
        )
        let path = UIBezierPath(ovalIn: newRect)
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

}
