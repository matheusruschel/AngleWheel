//
//  Circle.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-16.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit

@IBDesignable class CircularView: UIView {

    @IBInspectable let lineWidth: CGFloat = 8
    @IBInspectable let lineColor: UIColor = .lightGray
    var radius: Float
    var path: UIBezierPath!
    
    init(radius: Float) {
        self.radius = radius
        super.init(frame: CGRect(x:0, y:0, width: 100, height: 100))
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.radius = 125
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        path = UIBezierPath(arcCenter: CGPoint(x: rect.midX,y: rect.midY),
                                radius: CGFloat(radius),
                                startAngle: CGFloat(0),
                                endAngle:CGFloat(Double.pi * 2),
                                clockwise: true)
        lineColor.withAlphaComponent(0.6).setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }


}
