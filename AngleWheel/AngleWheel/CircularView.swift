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
    let radius: CGFloat = 125
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX,y: rect.midY),
                                radius: radius,
                                startAngle: CGFloat(0),
                                endAngle:CGFloat(Double.pi * 2),
                                clockwise: true)
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
        backgroundColor = .clear
    }


}
