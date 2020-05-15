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
    
    var cannyFirstSliderValue : Float = 50.0
    var cannySecondSliderValue : Float = 50.0
    var houghThresholdSliderValue : Float = 50.0
    var houghMinLengthSliderValue : Float = 50.0
    var houghMaxGapSliderValue : Float = 50.0
    
    var cannyFirstLabel : UILabel = UILabel()
    var cannySecondLabel : UILabel = UILabel()
    var houghThresholdLabel : UILabel = UILabel()
    var houghMinLengthLabel : UILabel = UILabel()
    var houghMaxGapLabel : UILabel = UILabel()
    
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
        let cannyFirstRect = CGRect(x: 15, y: 625, width: 140, height: 10)
        let cannyFirstSlider = UISlider(frame: cannyFirstRect)
        cannyFirstSlider.maximumValue = 255
        cannyFirstSlider.minimumValue = 0
        cannyFirstSlider.value = 50
        cannyFirstSlider.isContinuous = true
        // add the label for slider
        let cannyFirstLabelRect = CGRect(x: 160, y: 625, width: 35, height: 15)
        cannyFirstLabel = UILabel(frame: cannyFirstLabelRect)
        cannyFirstLabel.text = "50"
        
        cannyFirstSlider.addTarget(self, action: #selector(cannyFirstSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannyFirstSlider)
        self.view.addSubview(cannyFirstLabel)
        
        // canny's second treshold
        let cannySecondRect = CGRect(x: 15, y: 675, width: 140, height: 10)
        let cannySecondSlider = UISlider(frame: cannySecondRect)
        cannySecondSlider.maximumValue = 255
        cannySecondSlider.minimumValue = 0
        cannySecondSlider.value = 50
        cannySecondSlider.isContinuous = true
        // add the label for slider
        let cannySecondLabelRect = CGRect(x: 160, y: 675, width: 35, height: 15)
        cannySecondLabel = UILabel(frame: cannySecondLabelRect)
        cannySecondLabel.text = "50"
        
        cannySecondSlider.addTarget(self, action: #selector(cannySecondSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannySecondSlider)
        self.view.addSubview(cannySecondLabel)
        
        // hough's treshold
        let houghThresholdRect = CGRect(x: 210, y: 575, width: 140, height: 10)
        let houghThresholdSlider = UISlider(frame: houghThresholdRect)
        houghThresholdSlider.maximumValue = 255
        houghThresholdSlider.minimumValue = 0
        houghThresholdSlider.value = 50
        houghThresholdSlider.isContinuous = true
        // add the label for slider
        let houghThresholdLabelRect = CGRect(x: 355, y: 575, width: 35, height: 15)
        houghThresholdLabel = UILabel(frame: houghThresholdLabelRect)
        houghThresholdLabel.text = "50"
        
        houghThresholdSlider.addTarget(self, action: #selector(houghThresholdSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghThresholdSlider)
        self.view.addSubview(houghThresholdLabel)
        
        // hough's min line length
        let houghMinLengthRect = CGRect(x: 210, y: 625, width: 140, height: 10)
        let houghMinLengthSlider = UISlider(frame: houghMinLengthRect)
        houghMinLengthSlider.maximumValue = 1000
        houghMinLengthSlider.minimumValue = 0
        houghMinLengthSlider.value = 50
        houghMinLengthSlider.isContinuous = true
        // add the label for slider
        let houghMinLengthLabelRect = CGRect(x: 355, y: 625, width: 35, height: 15)
        houghMinLengthLabel = UILabel(frame: houghMinLengthLabelRect)
        houghMinLengthLabel.text = "50"
        
        houghMinLengthSlider.addTarget(self, action: #selector(houghMinLengthSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMinLengthSlider)
        self.view.addSubview(houghMinLengthLabel)
        
        // hough's max line gap
        let houghMaxGapRect = CGRect(x: 210, y: 675, width: 140, height: 10)
        let houghMaxGapSlider = UISlider(frame: houghMaxGapRect)
        houghMaxGapSlider.maximumValue = 255
        houghMaxGapSlider.minimumValue = 0
        houghMaxGapSlider.value = 50
        houghMaxGapSlider.isContinuous = true
        // add the label for slider
        let houghMaxGapLabelRect = CGRect(x: 355, y: 675, width: 35, height: 15)
        houghMaxGapLabel = UILabel(frame: houghMaxGapLabelRect)
        houghMaxGapLabel.text = "50"
        
        houghMaxGapSlider.addTarget(self, action: #selector(houghMaxGapSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMaxGapSlider)
        self.view.addSubview(houghMaxGapLabel)
        
        // Add an empty shapelayer to recplace later
        arView.layer.addSublayer(CAShapeLayer())
    }
    
    @objc func enableUpdateCV() {
        updateCV = true;
    }
    
    @objc func cannyFirstSliderChanged(sender: UISlider) {
        cannyFirstSliderValue = sender.value
        cannyFirstLabel.text = String(format: "%.0f", sender.value)
    }
    
    @objc func cannySecondSliderChanged(sender: UISlider) {
        cannySecondSliderValue = sender.value
        cannySecondLabel.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghThresholdSliderChanged(sender: UISlider) {
        houghThresholdSliderValue = sender.value
        houghThresholdLabel.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMinLengthSliderChanged(sender: UISlider) {
        houghMinLengthSliderValue = sender.value
        houghMinLengthLabel.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMaxGapSliderChanged(sender: UISlider) {
        houghMaxGapSliderValue = sender.value
        houghMaxGapLabel.text = String(format: "%.0f", sender.value)
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
                    
                    let multiplier : Double = 736 / 1920;
                    
                    let lines =  opencv.test(Int32(Double(projection!.x) / multiplier),
                                             y: Int32(Double(projection!.y) / multiplier),
                                             cannyFirstThreshold: Double(cannyFirstSliderValue),
                                             cannySecondThreshold: Double(cannySecondSliderValue),
                                             houghThreshold: Double(houghThresholdSliderValue),
                                             houghMinLength: Double(houghMinLengthSliderValue),
                                             houghMaxGap: Double(houghMaxGapSliderValue),
                                             image: arView.session.currentFrame!.capturedImage)
                    
                    let points = lines.split(separator: "_")
                    
                    // Remove sublayers from previous frame
                    for subl in arView.layer.sublayers! {
                        if subl is CAShapeLayer {
                            subl.removeFromSuperlayer()
                        }
                    }
                    
                    let line = UIBezierPath()
                    
                    line.move(to: CGPoint(x: Double(String(points[0]))! * multiplier,
                                          y: Double(String(points[1]))! * multiplier))
                    line.addLine(to: CGPoint(x: Double(String(points[2]))! * multiplier,
                                             y: Double(String(points[3]))! * multiplier))
                    line.addLine(to: CGPoint(x: Double(String(points[6]))! * multiplier,
                                             y: Double(String(points[7]))! * multiplier))
                    line.addLine(to: CGPoint(x: Double(String(points[4]))! * multiplier,
                                             y: Double(String(points[5]))! * multiplier))
                    line.close()
                    
                    
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = line.cgPath
                    shapeLayer.opacity = 0.5
                    shapeLayer.strokeColor = UIColor.blue.cgColor
                    shapeLayer.fillColor = UIColor.green.cgColor
                    shapeLayer.lineWidth = 3
                    shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
                
                    arView.layer.addSublayer(shapeLayer)
                    
                    
                    updateCV = false
                }

            }
        }
    }
    
}
