//
//  ViewControllerExtension.swift
//  Transform
//
//  Created by Kira on 2019/2/22.
//  Copyright © 2019 Kira. All rights reserved.
//

import UIKit

extension ViewController {
    static var previousScale: CGFloat = 1
    
    func addGestureRecognizer(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self,
                                             action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = SIMD2<Float>(Float(gesture.translation(in: gesture.view).x),
                                 Float(gesture.translation(in: gesture.view).y))
        renderer?.rotateUsing(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let sensitivity: Float = 0.8
        renderer?.zoomUsing(delta: gesture.scale-ViewController.previousScale,
                            sensitivity: sensitivity)
        ViewController.previousScale = gesture.scale
        if gesture.state == .ended {
            ViewController.previousScale = 1
        }
    }
}
