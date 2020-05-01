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
        
        // Add an empty shapelayer to recplace later
        arView.layer.addSublayer(CAShapeLayer())
    }
    
    @objc func enableUpdateCV() {
        updateCV = true;
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
                    
                    let multiplier : Double = 720 / 1920;
                    
                    // Remove sublayers from previous frame
                    for subl in arView.layer.sublayers! {
                        if subl is CAShapeLayer {
                            subl.removeFromSuperlayer()
                        }
                    }
                    
                    // Add every line as a sublayer
                    for i in (0...points.count/4) {
                        let line = UIBezierPath()
                        
                        line.move(to: CGPoint(x: Double(String(points[i]))! * multiplier,
                                              y: Double(String(points[i + 1]))! * multiplier))
                        line.addLine(to: CGPoint(x: Double(String(points[i + 2]))! * multiplier,
                                                 y: Double(String(points[i + 3]))! * multiplier))
                        
                        
                        let shapeLayer = CAShapeLayer()
                        shapeLayer.path = line.cgPath
                        shapeLayer.strokeColor = UIColor.blue.cgColor
                        shapeLayer.fillColor = UIColor.clear.cgColor
                        shapeLayer.lineWidth = 3
                    
                        arView.layer.addSublayer(shapeLayer)
                    }
                    
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
