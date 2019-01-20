//
//  AngleWheelViewController.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-16.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit

protocol AngleWheelDelegate: class {
    func didChangeAngleValue(value: Float)
}

class AngleWheelViewController: UIViewController {
    static let identifier = "AngleWheelViewController"
    var circularView: CircularView!
    var buttonAngle: UIButton!
    var buttonAngleLocation: CGPoint = CGPoint.zero
    var radius: Float = 125.0
    var min: Int = 0
    var max: Int = 360
    var buttonAngleDegreesPosition: Float = 0
    var timer: Timer!
    var wheelStoppedSpinningAnimation = false
    var randomAngle: Float = 0
    weak var angleWheelDelegate: AngleWheelDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    // MARK: - Setup views
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
        
        buttonAngle.center = buttonAngleDegreesPosition.degreesAngleToPoint(withRadius: radius, inRect: circularView.frame)
        buttonAngle.setTitle("\(Int(buttonAngleDegreesPosition))", for: .normal)
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
        let x = Float(buttonAngleLocation.x)
        let y = Float(buttonAngleLocation.y)
        let midViewXDouble = Float(circularView.frame.midX)
        let midViewYDouble = Float(circularView.frame.midY)
        let diffX = (x - midViewXDouble)
        let diffY = (y - midViewYDouble)
        let angle = atan2(diffY, diffX)
        let x2 = midViewXDouble + cos(angle)*radius
        let y2 = midViewYDouble + sin(angle)*radius
        buttonAngle.center = CGPoint(x: CGFloat(x2),y: CGFloat(y2))
        buttonAngleDegreesPosition = buttonAngleLocation.pointToDegreesAngle(inRect: circularView.frame)
        buttonAngle.setTitle("\(Int(buttonAngleDegreesPosition))", for: .normal)
        recognizer.setTranslation(.zero, in: buttonAngle)
        angleWheelDelegate?.didChangeAngleValue(value: buttonAngleDegreesPosition)
    }
    
    // MARK: - Button Action
    @objc func buttonAnglePressed() {
        fireTimer()
        startSpinning()
    }
    
    func animateToRandomAngle() -> Float {
        let randomAngle = Int.random(in: 0...360)
        let semiCirclePath = UIBezierPath(arcCenter: circularView.center,
                                          radius: CGFloat(radius),
                                          startAngle: CGFloat(buttonAngleDegreesPosition.degreesToRadians()),
                                          endAngle: CGFloat(Float(randomAngle).degreesToRadians()),
                                          clockwise: true)
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 1
        animation.repeatCount = 1
        animation.path = semiCirclePath.cgPath
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        buttonAngle.layer.add(animation, forKey: nil)
        self.buttonAngle.center = Float(randomAngle).degreesAngleToPoint(withRadius: self.radius, inRect: self.circularView.frame)
        self.buttonAngleDegreesPosition = Float(randomAngle)
        return Float(randomAngle)
    }
    
    func startSpinning() {
        let circlePath = UIBezierPath(arcCenter: circularView.center,
                                      radius: CGFloat(radius),
                                      startAngle: CGFloat(buttonAngleDegreesPosition.degreesToRadians()),
                                      endAngle: Math().percentToRadians(startAngle: CGFloat(buttonAngleDegreesPosition.degreesToRadians()),percentComplete: 100),
                                      clockwise: true)
        
        
        let repeatCount = Int.random(in: 1...5)
        let animationRandomLoops = CAKeyframeAnimation(keyPath: "position")
        animationRandomLoops.delegate = self
        animationRandomLoops.duration = 1
        animationRandomLoops.repeatCount = Float(repeatCount)
        animationRandomLoops.path = circlePath.cgPath
        buttonAngle.layer.add(animationRandomLoops, forKey: nil)
    }
    
    func fireTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
            let layer = self.buttonAngle.layer.presentation()
            let point = CGPoint(x: layer!.frame.midX, y: layer!.frame.midY)
            let degrees = point.pointToDegreesAngle(inRect: self.circularView.frame)
            self.buttonAngle.setTitle("\(Int(degrees))", for: .normal)
            self.angleWheelDelegate?.didChangeAngleValue(value: degrees)
        })
    }
}
extension AngleWheelViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.buttonAngle.setTitle("\(Int(self.buttonAngleDegreesPosition))", for: .normal)
        wheelStoppedSpinningAnimation = !wheelStoppedSpinningAnimation
        
        if wheelStoppedSpinningAnimation {
            randomAngle = animateToRandomAngle()
        } else {
            self.buttonAngle.setTitle("\(Int(randomAngle))", for: .normal)
            timer.invalidate()
        }
    }
}
class Math {
    func percentToRadians(startAngle: CGFloat, percentComplete: CGFloat) -> CGFloat {
        let degrees = (percentComplete/100) * 360
        return startAngle + (degrees * (.pi/180))
    }
}
