//
//  Double+Extension.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-19.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import Foundation
import UIKit

extension Float {
    func degreesToRadians() -> Float { return self * Float(Double.pi) / 180 - (Float(Double.pi)/2) }
    func radiansToDegrees() -> Float { return self * 180 / -Float(Double.pi) - 90 }
    func degreesAngleToPoint(withRadius radius: Float, inRect rect: CGRect) -> CGPoint {
        var finalAngle = self
        if self < 0 {
            finalAngle = 0
        } else if self > 360 {
            finalAngle = 360
        }
        
        let radians = finalAngle.degreesToRadians()
        let midViewXDouble = rect.midX
        let midViewYDouble = rect.midY
        let x: CGFloat = midViewXDouble + CGFloat(radius) * CGFloat(cos(radians))
        let y: CGFloat = midViewYDouble + CGFloat(radius) * CGFloat(sin(radians))
        return CGPoint(x: x,y: y)
    }
}
extension CGPoint {
    func pointToDegreesAngle(inRect rect: CGRect) -> Float {
        let x = rect.midX
        let y = rect.midY
        
        let dx = self.x - x
        let dy = self.y - y
        
        let radians = atan2f(Float(dy), Float(dx))
        let degrees = radians.radiansToDegrees()
        
        if degrees < 0 {
            return fabsf(Float(degrees))
        } else {
            return 360 - Float(degrees)
        }
    }
}
