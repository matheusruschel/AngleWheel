//
//  AngleWheelViewController.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-16.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit

class AngleWheelViewController: UIViewController {
    
    var circularView: CircularView!
    var buttonAngle: UIButton!
    var buttonAngleLocation: CGPoint = CGPoint.zero
    let radius: Double = 125.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        setupCircularView()
        setupAngleButton()
    }
    
    func setupCircularView() {
        circularView = CircularView(frame: CGRect(x: 0,
                                                  y: view.bounds.height * 0.1,
                                                  width: view.bounds.width * 0.7,
                                                  height: view.bounds.width * 0.7))
        
        circularView.center.x = view.center.x
        circularView.backgroundColor = .clear
        view.addSubview(circularView)
        let holdDownGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAngleButton))
        circularView.addGestureRecognizer(holdDownGestureRecognizer)
    }
    
    func setupAngleButton() {
        buttonAngle = UIButton(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 40,
                                             height: 40))
        
        buttonAngle.center = angleToPoint(angle: 0)
        buttonAngle.setTitle("0", for: .normal)
        buttonAngle.addTarget(self, action: #selector(buttonAnglePressed), for: .touchUpInside)
        buttonAngle.setTitleColor(.black, for: .normal)
        buttonAngle.backgroundColor = .red
        buttonAngle.layer.cornerRadius = 0.5 * buttonAngle.bounds.size.width
        buttonAngle.clipsToBounds = true
        view.addSubview(buttonAngle)
        let holdDownGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAngleButton))
        holdDownGestureRecognizer.cancelsTouchesInView = true
        buttonAngle.addGestureRecognizer(holdDownGestureRecognizer)
    }
    
    @objc func dragAngleButton(recognizer: UIPanGestureRecognizer) {
        buttonAngleLocation = recognizer.location(in: self.view);
        let x = Double(buttonAngleLocation.x)
        let y = Double(buttonAngleLocation.y)
        let midViewXDouble = Double(circularView.frame.midX)
        let midViewYDouble = Double(circularView.frame.midY)
        let angleX = (x - midViewXDouble)
        let angleY = (y - midViewYDouble)
        let angle = atan2(angleY, angleX)
        let x2 = midViewXDouble + cos(angle)*radius
        let y2 = midViewYDouble + sin(angle)*radius
        buttonAngle.center = CGPoint(x: x2,y: y2)
        let angle2 = pointToAngle(point: buttonAngleLocation)
        buttonAngle.setTitle(String("\(angle2)".prefix(3)), for: .normal)
        recognizer.setTranslation(.zero, in: buttonAngle)
    }
    
    @objc func buttonAnglePressed() {
        let randomAngle = Int.random(in: 0...360)
        buttonAngle.setTitle(String("\(randomAngle)".prefix(3)), for: .normal)
        let point = angleToPoint(angle: Float(randomAngle))
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.buttonAngle.center = point
        }, completion: nil)
        
    }
    
    func angleToPoint(angle: Float) -> CGPoint {
        
        var finalAngle = angle
        if angle < 0 {
            finalAngle = 0
        } else if angle > 360 {
            finalAngle = 360
        }
            
        let radians = finalAngle * .pi / 180 - 1.57
        let midViewXDouble = circularView.frame.midX
        let midViewYDouble = circularView.frame.midY
        let x: CGFloat = midViewXDouble + CGFloat(radius) * CGFloat(cos(radians))
        let y: CGFloat = midViewYDouble + CGFloat(radius) * CGFloat(sin(radians))
        return CGPoint(x: x,y: y)
    }
    
    func pointToAngle(point: CGPoint) -> Float {
        let x = self.circularView.center.x
        let y = self.circularView.center.y
        
        let dx = point.x - x
        let dy = point.y - y
        
        let radians = atan2f(Float(dy), Float(dx))
        let degrees = Double(radians) * 180 / -Double.pi - 90
        
        if degrees < 0 {
            return fabsf(Float(degrees))
        } else {
            return 360 - Float(degrees)
        }
    }
}

//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint tapPoint = [touch locationInView:self.view];
//    CGFloat angle = [self angleToPoint:tapPoint];
//
//    int area = [self sectionForAngle:angle];
//    }
//    - (int)sectionForAngle:(float)angle
//{
//    if (angle >= 0 && angle < 60) {
//        return 1;
//    } else if (angle >= 60 && angle < 120) {
//        return 2;
//    } else if (angle >= 120 && angle < 180) {
//        return 3;
//    } else if (angle >= 180 && angle < 240) {
//        return 4;
//    } else if (angle >= 240 && angle < 300) {
//        return 5;
//    } else {
//        return 6;
//    }
//}
