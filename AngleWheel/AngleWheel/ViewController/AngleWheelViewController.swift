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
    func didPressAngleButton()
}

class AngleWheelViewController: UIViewController {
    static let identifier = "AngleWheelViewController"
    var circularView: CircularView!
    var buttonAngle: UIButton!
    var buttonAngleLocation: CGPoint = CGPoint.zero
    var radius: Float = 125.0
    var buttonAngleDegreesPosition: Float = 0
    var timer: Timer!
    var randomAngle: Float = 0 
    var buttonAngleColor: UIColor = UIColor(displayP3Red: 14 / 255, green: 172 / 255, blue: 81 / 255, alpha: 1)
    var buttonAngleTextColor: UIColor = .white
    var buttonSize: CGFloat = 50
    var activeAnimation: String?
    weak var angleWheelDelegate: AngleWheelDelegate?
    static let spinningId = "spinning"
    static let singleMoveAnimationId = "singleMoveAnimation"
    static let animateToFinalPositionId = "animateToFinalPosition"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    // MARK: - Setup views
    private func setupViews() {
        setupCircularView()
        setupAngleButton()
    }
    
    private func setupCircularView() {
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
    
    private func setupAngleButton() {
        buttonAngle = UIButton(frame: CGRect(x: 0,
                                             y: 0,
                                             width: buttonSize,
                                             height: buttonSize))
        
        buttonAngle.center = buttonAngleDegreesPosition.degreesAngleToPoint(withRadius: radius, inRect: circularView.frame)
        buttonAngle.setTitle("\(Int(buttonAngleDegreesPosition))", for: .normal)
        buttonAngle.addTarget(self, action: #selector(buttonAnglePressed), for: .touchUpInside)
        buttonAngle.setTitleColor(buttonAngleTextColor, for: .normal)
        buttonAngle.backgroundColor = buttonAngleColor
        buttonAngle.titleLabel?.font = .boldSystemFont(ofSize: 17)
        buttonAngle.layer.cornerRadius = 0.5 * buttonAngle.bounds.size.width
        buttonAngle.clipsToBounds = true
        view.addSubview(buttonAngle)
        let holdDownGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAngleButton))
        holdDownGestureRecognizer.cancelsTouchesInView = true
        buttonAngle.addGestureRecognizer(holdDownGestureRecognizer)
    }
    
    // MARK: - Dragging button action
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
        angleWheelDelegate?.didPressAngleButton()
        fireTimer()
        startSpinning()
    }
    
    // MARK: - Animations
    private func animateToAngle(angle: Float, withKey key: String) {
        let semiCirclePath = UIBezierPath(arcCenter: circularView.center,
                                          radius: CGFloat(radius),
                                          startAngle: CGFloat(buttonAngleDegreesPosition.degreesToRadians()),
                                          endAngle: CGFloat(angle.degreesToRadians()),
                                          clockwise: true)
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 1
        animation.repeatCount = 1
        animation.path = semiCirclePath.cgPath
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        buttonAngle.layer.add(animation, forKey: nil)
        self.buttonAngle.center = angle.degreesAngleToPoint(withRadius: self.radius, inRect: self.circularView.frame)
        self.buttonAngleDegreesPosition = angle
        activeAnimation = key
    }
    
    func animateToAngle(angle: Float) {
        fireTimer()
        animateToAngle(angle: angle,withKey: AngleWheelViewController.singleMoveAnimationId)
    }
    
    private func startSpinning() {
        let endAngle = CGFloat(CGFloat(buttonAngleDegreesPosition.degreesToRadians()) + (CGFloat(360) * (.pi/180)))
        let circlePath = UIBezierPath(arcCenter: circularView.center,
                                      radius: CGFloat(radius),
                                      startAngle: CGFloat(buttonAngleDegreesPosition.degreesToRadians()),
                                      endAngle: endAngle,
                                      clockwise: true)
        
        
        let repeatCount = Int.random(in: 1...5)
        let animationRandomLoops = CAKeyframeAnimation(keyPath: "position")
        animationRandomLoops.delegate = self
        animationRandomLoops.duration = 1
        animationRandomLoops.repeatCount = Float(repeatCount)
        animationRandomLoops.path = circlePath.cgPath
        buttonAngle.layer.add(animationRandomLoops, forKey: nil)
        activeAnimation = AngleWheelViewController.spinningId
    }
    
    // MARK: - Timer
    private func fireTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
            let layer = self.buttonAngle.layer.presentation()
            let point = CGPoint(x: layer!.frame.midX, y: layer!.frame.midY)
            let degrees = point.pointToDegreesAngle(inRect: self.circularView.frame)
            self.buttonAngle.setTitle("\(Int(degrees))", for: .normal)
            self.angleWheelDelegate?.didChangeAngleValue(value: degrees)
        })
    }
}
// MARK: - Animation Delegate
extension AngleWheelViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.buttonAngle.setTitle("\(Int(self.buttonAngleDegreesPosition))", for: .normal)
        
        if activeAnimation == AngleWheelViewController.spinningId {
            randomAngle = Float(Int.random(in: 0...360))
            animateToAngle(angle: randomAngle, withKey: AngleWheelViewController.animateToFinalPositionId)
        } else if activeAnimation == AngleWheelViewController.animateToFinalPositionId {
            self.buttonAngle.setTitle("\(Int(randomAngle))", for: .normal)
            timer.invalidate()
        } else {
            timer.invalidate()
        }
    }
}
