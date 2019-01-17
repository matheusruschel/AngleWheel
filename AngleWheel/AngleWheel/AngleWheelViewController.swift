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
        view.addSubview(circularView)
    }
    
    func setupAngleButton() {
        buttonAngle = UIButton(frame: CGRect(x: circularView.center.x - CGFloat(60.0/2),
                                             y: circularView.frame.origin.y - 45,
                                             width: 60,
                                             height: 60))
        buttonAngle.setTitle("0", for: .normal)
        buttonAngle.addTarget(self, action: #selector(buttonAnglePressed(button:)), for: .touchUpInside)
        buttonAngle.addTarget(self, action: #selector(buttonAngleWasDragged(button:withEvent:)), for: .touchDragInside)
        buttonAngle.setTitleColor(.blue, for: .normal)
        view.addSubview(buttonAngle)
    }
    
    @objc func buttonAngleStartedDragging(gestureRecognizer: UIPanGestureRecognizer) {
        buttonAngleLocation = gestureRecognizer.location(in: view)
        buttonAngle.center = buttonAngleLocation
    }
    
    @objc func buttonAngleWasDragged(button: UIButton, withEvent: UIEvent) {
        //print("dragging")
        button.center = withEvent.allTouches!.first!.location(in: view)
    }
    
    @objc func buttonAnglePressed(button: UIButton) {
        print("spinnn")
    }
}
