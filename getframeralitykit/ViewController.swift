//
//  ViewController.swift
//  imageDetectionRealityKit
//
//  Created by macos on 5.02.2020.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!

    let opencv = OpenCVWrapper()
    var timer : Timer!
    var updateCV : Bool = true
    
    var cannyFirstSliderValue : Float = 0.0
    var cannySecondSliderValue : Float = 0.0
    var houghThresholdSliderValue : Float = 0.0
    var houghMinLengthSliderValue : Float = 0.0
    var houghMaxGapSliderValue : Float = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        
        print(configuration.videoFormat.imageResolution)
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "trackImages", bundle: Bundle.main) else {
            return
        }
        
        configuration.detectionImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 10
        
        arView.session.run(configuration)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(enableUpdateCV), userInfo: nil, repeats: true)
        
        
        // 5 sliders are needed
        // First, canny's first treshold
        let cannyFirstRect = CGRect(x: 15, y: 600, width: 180, height: 10)
        let cannyFirstSlider = UISlider(frame: cannyFirstRect)
        cannyFirstSlider.maximumValue = 255
        cannyFirstSlider.minimumValue = 0
        cannyFirstSlider.value = 50
        cannyFirstSlider.isContinuous = false
        cannyFirstSlider.addTarget(self, action: #selector(cannyFirstSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannyFirstSlider)
        
        // canny's second treshold
        let cannySecondRect = CGRect(x: 15, y: 650, width: 180, height: 10)
        let cannySecondSlider = UISlider(frame: cannySecondRect)
        cannySecondSlider.maximumValue = 255
        cannySecondSlider.minimumValue = 0
        cannySecondSlider.value = 50
        cannySecondSlider.isContinuous = false
        cannySecondSlider.addTarget(self, action: #selector(cannySecondSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannySecondSlider)
        
        // hough's treshold
        let houghThresholdRect = CGRect(x: 210, y: 550, width: 180, height: 10)
        let houghThresholdSlider = UISlider(frame: houghThresholdRect)
        houghThresholdSlider.maximumValue = 255
        houghThresholdSlider.minimumValue = 0
        houghThresholdSlider.value = 50
        houghThresholdSlider.isContinuous = false
        houghThresholdSlider.addTarget(self, action: #selector(houghThresholdSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghThresholdSlider)
        
        // hough's min line length
        let houghMinLengthRect = CGRect(x: 210, y: 600, width: 180, height: 10)
        let houghMinLengthSlider = UISlider(frame: houghMinLengthRect)
        houghMinLengthSlider.maximumValue = 500
        houghMinLengthSlider.minimumValue = 0
        houghMinLengthSlider.value = 50
        houghMinLengthSlider.isContinuous = false
        houghMinLengthSlider.addTarget(self, action: #selector(houghMinLengthSliderChanged(sender:)),
                                    for: UIControl.Event.valueChanged)
         
        self.view.addSubview(houghMinLengthSlider)
        
        // hough's max line gap
        let houghMaxGapRect = CGRect(x: 210, y: 650, width: 180, height: 10)
        let houghMaxGapSlider = UISlider(frame: houghMaxGapRect)
        houghMaxGapSlider.maximumValue = 255
        houghMaxGapSlider.minimumValue = 0
        houghMaxGapSlider.value = 50
        houghMaxGapSlider.isContinuous = false
        houghMaxGapSlider.addTarget(self, action: #selector(houghMaxGapSliderChanged(sender:)),
                                    for: UIControl.Event.valueChanged)
         
         self.view.addSubview(houghMaxGapSlider)
        
        // Add an empty shapelayer to recplace later
        arView.layer.addSublayer(CAShapeLayer())
    }
    
    @objc func enableUpdateCV() {
        updateCV = true;
    }
    
    @objc func cannyFirstSliderChanged(sender: UISlider) {
        cannyFirstSliderValue = sender.value
    }
    
    @objc func cannySecondSliderChanged(sender: UISlider) {
        cannySecondSliderValue = sender.value
    }
    
    @objc func houghThresholdSliderChanged(sender: UISlider) {
        houghThresholdSliderValue = sender.value
    }
    
    @objc func houghMinLengthSliderChanged(sender: UISlider) {
        houghMinLengthSliderValue = sender.value
    }
    
    @objc func houghMaxGapSliderChanged(sender: UISlider) {
        houghMaxGapSliderValue = sender.value
    }
}

extension ViewController: ARSessionDelegate {
    /*
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARImageAnchor {
                
                let pos = vector3(anchor.transform[3][0], anchor.transform[3][1], anchor.transform[3][2])
                let projection = arView.project(pos)
                
                let a =  opencv.test3(Int32(projection!.x), y: Int32(projection!.y),
                                  image: arView.session.currentFrame!.capturedImage)
                
                print(a);
                
            }
        }
    }*/
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARImageAnchor {
                
                if (updateCV) {
                
                    let pos = vector3(anchor.transform[3][0], anchor.transform[3][1], anchor.transform[3][2])
                    let projection = arView.project(pos)
                    
                    let lines =  opencv.test3(Int32(projection!.x), y: Int32(projection!.y),
                                              image: arView.session.currentFrame!.capturedImage)
                    
                    let points = lines.split(separator: "_")
                    
                    print(points)
                    
                    let multiplier : Double = 736 / 1920;
                    
                    // Remove sublayers from previous frame
                    for subl in arView.layer.sublayers! {
                        if subl is CAShapeLayer {
                            subl.removeFromSuperlayer()
                        }
                    }
                    
                    let line = UIBezierPath()
                    /*
                    line.move(to: CGPoint(x: Double(String(points[0]))! * multiplier,
                                          y: Double(String(points[1]))! * multiplier))
                    line.addLine(to: CGPoint(x: Double(String(points[2]))! * multiplier,
                                             y: Double(String(points[3]))! * multiplier))
                    */
                
                    line.move(to: CGPoint(x: 0,
                                          y: 0))
                    line.addLine(to: CGPoint(x: 414,
                                             y: 736 ))
                    
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = line.cgPath
                    shapeLayer.strokeColor = UIColor.blue.cgColor
                    shapeLayer.fillColor = UIColor.clear.cgColor
                    shapeLayer.lineWidth = 3
                
                    arView.layer.addSublayer(shapeLayer)
                
                    
                    updateCV = false
                }
                
                /*
                let circlePath = UIBezierPath(arcCenter: projection!, radius: CGFloat(20), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

                let shapeLayer = CAShapeLayer()
                shapeLayer.path = circlePath.cgPath

                // Change the fill color
                shapeLayer.fillColor = UIColor.red.cgColor
                // You can change the stroke color
                shapeLayer.strokeColor = UIColor.red.cgColor
                // You can change the line width
                shapeLayer.lineWidth = 3.0

                for subl in arView.layer.sublayers! {
                    if subl is CAShapeLayer {
                        arView.layer.replaceSublayer(subl, with: shapeLayer)
                        break
                    }
                }*/
                
                
                //print(projection as Any)
            }
        }
    }
    
}
