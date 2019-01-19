//
//  AngleWheelViewController.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-16.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit

protocol AngleWheelDelegate: class {
    func didChangeAngleValue(value: Int)
}

class AngleWheelViewController: UIViewController {
    static let identifier = "AngleWheelViewController"
    var circularView: CircularView!
    var buttonAngle: UIButton!
    var buttonAngleLocation: CGPoint = CGPoint.zero
    var radius: Double = 125.0
    var min: Int = 0
    var max: Int = 360
    var buttonAnglePosition: Int = 0
    var timer: Timer!
    var timerCount = 0
    var updatedAngle = 0
    weak var angleWheelDelegate: AngleWheelDelegate?
    
    class func initialize(radius: Double, min: Int, max: Int, initialValue: Int) -> AngleWheelViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let angleWheelViewController = storyBoard.instantiateViewController(withIdentifier: identifier) as?
            AngleWheelViewController ?? AngleWheelViewController()
        angleWheelViewController.radius = radius
        angleWheelViewController.min = min
        angleWheelViewController.max = max
        angleWheelViewController.buttonAnglePosition = initialValue
        return angleWheelViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    func setupViews() {
        setupCircularView()
        setupAngleButton()
    }
    
    func setupCircularView() {
        circularView = CircularView(radius: radius)
        circularView.frame = CGRect(x: 0,
                                    y: 0 ,
                                    width: view.bounds.width ,
                                    height: view.bounds.width)
        
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
        
        buttonAngle.center = degreesAngleToPoint(angle: Float(buttonAnglePosition))
        buttonAngle.setTitle("\(buttonAnglePosition)", for: .normal)
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
        let angle2 = Int(pointToDegreesAngle(point: buttonAngleLocation))
        buttonAnglePosition = angle2
        buttonAngle.setTitle("\(angle2)", for: .normal)
        recognizer.setTranslation(.zero, in: buttonAngle)
        angleWheelDelegate?.didChangeAngleValue(value: angle2)
    }
    
    @objc func buttonAnglePressed() {
        let circlePath = UIBezierPath(arcCenter: circularView.center,
                                      radius: CGFloat(radius),
                                      startAngle: CGFloat(Double(buttonAnglePosition).degreesToRadians()),
                                      endAngle: Math().percentToRadians(startAngle: CGFloat(Double(buttonAnglePosition).degreesToRadians()),percentComplete: 100),
                                      clockwise: true)
    
        updatedAngle = buttonAnglePosition
        //CATransaction.begin()
        let repeatCount = Int.random(in: 1...5)
        let animationRandomLoops = CAKeyframeAnimation(keyPath: "position")
        animationRandomLoops.delegate = self
        animationRandomLoops.duration = 3
        animationRandomLoops.repeatCount = 3
        animationRandomLoops.path = circlePath.cgPath
        buttonAngle.layer.add(animationRandomLoops, forKey: nil)
        self.timerCount = 0
        buttonAngle.center = degreesAngleToPoint(angle: Float(buttonAnglePosition))
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
            
            self.timerCount += 1
            
            if self.timerCount >= 90 {
                self.timer.invalidate()
                return
            }
            self.updatedAngle += 12
            
            if self.updatedAngle >= 360 {
                self.updatedAngle = 0
            }
            
            self.buttonAngle.setTitle("\(self.updatedAngle)", for: .normal)
        })
        //let randomAngle = Int.random(in: 0...360)
        //buttonAngle.setTitle(String("\(Int(randomAngle))".prefix(3)), for: .normal)
        //CATransaction.commit()
        
//        CATransaction.begin()
//        let semiCirclePath = UIBezierPath(arcCenter: circularView.center,
//                                          radius: CGFloat(radius),
//                                          startAngle: CGFloat(Double(buttonAnglePosition).degreesToRadians()),
//                                          endAngle: CGFloat(Double(randomAngle).degreesToRadians()),
//                                          clockwise: true)
//        let animation = CAKeyframeAnimation(keyPath: "position")
//        animation.duration = 1
//        animation.repeatCount = 1
//        animation.path = semiCirclePath.cgPath
//        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//        animation.fillMode = .forwards
//        animation.isRemovedOnCompletion = false
//        buttonAngle.layer.add(animation, forKey: nil)
//        buttonAngle.center = degreesAngleToPoint(angle: Float(randomAngle))
//        buttonAnglePosition = randomAngle
//        CATransaction.commit()
    }
    
    func degreesAngleToPoint(angle: Float) -> CGPoint {
        
        var finalAngle = angle
        if angle < 0 {
            finalAngle = 0
        } else if angle > 360 {
            finalAngle = 360
        }
            
        let radians = Double(finalAngle).degreesToRadians()
        let midViewXDouble = circularView.frame.midX
        let midViewYDouble = circularView.frame.midY
        let x: CGFloat = midViewXDouble + CGFloat(radius) * CGFloat(cos(radians))
        let y: CGFloat = midViewYDouble + CGFloat(radius) * CGFloat(sin(radians))
        return CGPoint(x: x,y: y)
    }
    
    func pointToDegreesAngle(point: CGPoint) -> Float {
        let x = self.circularView.center.x
        let y = self.circularView.center.y
        
        let dx = point.x - x
        let dy = point.y - y
        
        let radians = atan2f(Float(dy), Float(dx))
        let degrees = Double(radians).radiansToDegrees()
        
        if degrees < 0 {
            return fabsf(Float(degrees))
        } else {
            return 360 - Float(degrees)
        }
    }
}
extension AngleWheelViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.buttonAngle.setTitle("\(self.buttonAnglePosition)", for: .normal)
    }
}
extension Double {
    func degreesToRadians() -> Double { return self * .pi / 180 - (.pi/2) }
    func radiansToDegrees() -> Double { return self * 180 / -Double.pi - 90 }
}
class Math {
    func percentToRadians(startAngle: CGFloat, percentComplete: CGFloat) -> CGFloat {
        let degrees = (percentComplete/100) * 360
        return startAngle + (degrees * (.pi/180))
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
