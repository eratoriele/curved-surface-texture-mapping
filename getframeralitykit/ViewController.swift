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

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var arView: ARView!

    let opencv = OpenCVWrapper()
    var timer : Timer!
    var updateCV : Bool = true
    
    var cannyFirstSliderValue : Float = 100.0
    var cannySecondSliderValue : Float = 150.0
    var houghThresholdSliderValue : Float = 25.0
    var houghMinLengthSliderValue : Float = 400.0
    var houghMaxGapSliderValue : Float = 150.0
    
    var cannyFirstLabel : UILabel?
    var cannySecondLabel : UILabel?
    var houghThresholdLabel : UILabel?
    var houghMinLengthLabel : UILabel?
    var houghMaxGapLabel : UILabel?
    
    var imagePicker = UIImagePickerController()
    var image : UIImage?
    
    var lineMapButton : Bool = false
    var deneme : Bool = true
    
    
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
        cannyFirstSlider.value = cannyFirstSliderValue
        cannyFirstSlider.isContinuous = true
        // add the label for slider
        let cannyFirstLabelRect = CGRect(x: 160, y: 625, width: 55, height: 15)
        cannyFirstLabel = UILabel(frame: cannyFirstLabelRect)
        cannyFirstLabel!.text = "\(cannyFirstSliderValue)"
        
        cannyFirstSlider.addTarget(self, action: #selector(cannyFirstSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannyFirstSlider)
        self.view.addSubview(cannyFirstLabel!)
        
        // canny's second treshold
        let cannySecondRect = CGRect(x: 15, y: 675, width: 140, height: 10)
        let cannySecondSlider = UISlider(frame: cannySecondRect)
        cannySecondSlider.maximumValue = 255
        cannySecondSlider.minimumValue = 0
        cannySecondSlider.value = cannySecondSliderValue
        cannySecondSlider.isContinuous = true
        // add the label for slider
        let cannySecondLabelRect = CGRect(x: 160, y: 675, width: 55, height: 15)
        cannySecondLabel = UILabel(frame: cannySecondLabelRect)
        cannySecondLabel!.text = "\(cannySecondSliderValue)"
        
        cannySecondSlider.addTarget(self, action: #selector(cannySecondSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannySecondSlider)
        self.view.addSubview(cannySecondLabel!)
        
        // hough's treshold
        let houghThresholdRect = CGRect(x: 210, y: 575, width: 140, height: 10)
        let houghThresholdSlider = UISlider(frame: houghThresholdRect)
        houghThresholdSlider.maximumValue = 50
        houghThresholdSlider.minimumValue = 0
        houghThresholdSlider.value = houghThresholdSliderValue
        houghThresholdSlider.isContinuous = true
        // add the label for slider
        let houghThresholdLabelRect = CGRect(x: 355, y: 575, width: 55, height: 15)
        houghThresholdLabel = UILabel(frame: houghThresholdLabelRect)
        houghThresholdLabel!.text = "\(houghThresholdSliderValue)"
        
        houghThresholdSlider.addTarget(self, action: #selector(houghThresholdSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghThresholdSlider)
        self.view.addSubview(houghThresholdLabel!)
        
        // hough's min line length
        let houghMinLengthRect = CGRect(x: 210, y: 625, width: 140, height: 10)
        let houghMinLengthSlider = UISlider(frame: houghMinLengthRect)
        houghMinLengthSlider.maximumValue = 1000
        houghMinLengthSlider.minimumValue = 0
        houghMinLengthSlider.value = houghMinLengthSliderValue
        houghMinLengthSlider.isContinuous = true
        // add the label for slider
        let houghMinLengthLabelRect = CGRect(x: 355, y: 625, width: 55, height: 15)
        houghMinLengthLabel = UILabel(frame: houghMinLengthLabelRect)
        houghMinLengthLabel!.text = "\(houghMinLengthSliderValue)"
        
        houghMinLengthSlider.addTarget(self, action: #selector(houghMinLengthSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMinLengthSlider)
        self.view.addSubview(houghMinLengthLabel!)
        
        // hough's max line gap
        let houghMaxGapRect = CGRect(x: 210, y: 675, width: 140, height: 10)
        let houghMaxGapSlider = UISlider(frame: houghMaxGapRect)
        houghMaxGapSlider.maximumValue = 255
        houghMaxGapSlider.minimumValue = 0
        houghMaxGapSlider.value = houghMaxGapSliderValue
        houghMaxGapSlider.isContinuous = true
        // add the label for slider
        let houghMaxGapLabelRect = CGRect(x: 355, y: 675, width: 55, height: 15)
        houghMaxGapLabel = UILabel(frame: houghMaxGapLabelRect)
        houghMaxGapLabel!.text = "\(houghMaxGapSliderValue)"
        
        houghMaxGapSlider.addTarget(self, action: #selector(houghMaxGapSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMaxGapSlider)
        self.view.addSubview(houghMaxGapLabel!)
        
        let lineMapButtonRect = CGRect(x: 15, y: 560, width: 140, height: 40)
        let lineMapButton = UIButton(frame: lineMapButtonRect)
        lineMapButton.backgroundColor = UIColor.darkGray
        lineMapButton.setTitle("Line/Mapping", for: .normal)
        lineMapButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(lineMapButton)
        
        // Ask to get the texture
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
 
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        image = (info[.originalImage] as? UIImage)!
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 1.0)
        image!.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        image = newImage!
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func enableUpdateCV() {
        updateCV = true;
    }
    
    @objc func cannyFirstSliderChanged(sender: UISlider) {
        cannyFirstSliderValue = sender.value
        cannyFirstLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func cannySecondSliderChanged(sender: UISlider) {
        cannySecondSliderValue = sender.value
        cannySecondLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghThresholdSliderChanged(sender: UISlider) {
        houghThresholdSliderValue = sender.value
        houghThresholdLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMinLengthSliderChanged(sender: UISlider) {
        houghMinLengthSliderValue = sender.value
        houghMinLengthLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMaxGapSliderChanged(sender: UISlider) {
        houghMaxGapSliderValue = sender.value
        houghMaxGapLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        // Find the location of edges in the screen
        
        // Origin of the world
        let worldOrigin = AnchorEntity(world: [0,0,0])
        var anchorEntity : AnchorEntity?
        
        var markerPositions : [CGPoint] = [CGPoint]()
        for anc in arView.scene.anchors {
            if anc is AnchorEntity && anc.name == "entityWithBall" {
                anchorEntity = anc as? AnchorEntity
                
                for ball in anchorEntity!.children {
                    let ballpos = ball.position(relativeTo: worldOrigin)
                    let aaa = vector3(ballpos[0], ballpos[1], ballpos[2])
                    // contents are: [0] -> image plane, also the point wher ethe image center is
                    // [1] -> leftEdge, left side of the image
                    // [2] -> rightEdge, right side of the image
                    markerPositions.append(arView.project(aaa)!)
                }
            }
        }
        
        lineMapButton = !lineMapButton

        let multiplier : Double = Double(arView.bounds.size.height / (arView.session.configuration?.videoFormat.imageResolution.width)!)
        
        // Now call for the closest left and right lines
        
        let lines =  opencv.test(Int32(Double(markerPositions[0].x) / multiplier),
                                 y: Int32(Double(markerPositions[0].y) / multiplier),
                                 cannyFirstThreshold: Double(cannyFirstSliderValue),
                                 cannySecondThreshold: Double(cannySecondSliderValue),
                                 houghThreshold: Double(houghThresholdSliderValue),
                                 houghMinLength: Double(houghMinLengthSliderValue),
                                 houghMaxGap: Double(houghMaxGapSliderValue),
                                 image: arView.session.currentFrame!.capturedImage,
                                 lineMap: lineMapButton)
        
        // [0] through [3] is left line, [4] through [7] is right line
        // [8] [9] is the point that intersects the left line
        // [10] [11] is the point that intersects the right line
        let points = lines.split(separator: "_")
       
        // means, no lines were found as possible matches
        if (points[0] == "0") {
            print("no lines found")
            return
        }
        print(points)
        
        // Length of the marker is predetermined,
        // TODO Change it from 5 cm to ARReferenceImage's real life length
        let markerDiffx = markerPositions[2].x - markerPositions[1].x
        let MarkerDiffy = markerPositions[2].y - markerPositions[2].y
        let pixelsToCm = pow(Double(pow(markerDiffx, 2) + pow(MarkerDiffy, 2)), 0.5) / Double(5)
        
        // Check which line is longer, set that as the height of the cylinder
        let leftDiffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[0]))! * multiplier)
        let leftDiffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[1]))! * multiplier)
        let leftLength = pow(pow(leftDiffx, 2) + pow(leftDiffy, 2), 0.5)
        
        let rightDiffx = (Double(String(points[6]))! * multiplier) - (Double(String(points[4]))! * multiplier)
        let rightDiffy = (Double(String(points[7]))! * multiplier) - (Double(String(points[5]))! * multiplier)
        let rightLength = pow(pow(rightDiffx, 2) + pow(rightDiffy, 2), 0.5)
        
        // Get the distance between left and right lines to determine the
        // radiues of the cylinder
        let linesDiffx = (Double(String(points[10]))! * multiplier) - (Double(String(points[8]))! * multiplier)
        let linesDiffy = (Double(String(points[11]))! * multiplier) - (Double(String(points[9]))! * multiplier)
        let radius = pow(pow(linesDiffx, 2) + pow(linesDiffy, 2), 0.5) / (2 * pixelsToCm)
        
        // [0] is the length of the cylinder
        // [1] is how high the marker is
        var longerLine : [Double] = [Double]()
        if (rightLength < leftLength) {
            longerLine.append(leftLength / pixelsToCm)
            // the lower point is x1y1
            if (Double(String(points[3]))! < Double(String(points[1]))!) {
                let diffx = (Double(String(points[0]))! * multiplier) - (Double(String(points[8]))! * multiplier)
                let diffy = (Double(String(points[1]))! * multiplier) - (Double(String(points[9]))! * multiplier)
                longerLine.append(pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm)
            }
            // the lower point is x2y2
            else {
                let diffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[8]))! * multiplier)
                let diffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[9]))! * multiplier)
                longerLine.append(pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm)
            }
        }
        else {
            longerLine.append(rightLength / pixelsToCm)
            // the lower point is x1y1
            if (Double(String(points[8]))! < Double(String(points[5]))!) {
                let diffx = (Double(String(points[4]))! * multiplier) - (Double(String(points[8]))! * multiplier)
                let diffy = (Double(String(points[5]))! * multiplier) - (Double(String(points[9]))! * multiplier)
                longerLine.append(pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm)
            }
            // the lower point is x2y2
            else {
                let diffx = (Double(String(points[6]))! * multiplier) - (Double(String(points[8]))! * multiplier)
                let diffy = (Double(String(points[7]))! * multiplier) - (Double(String(points[9]))! * multiplier)
                longerLine.append(pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm)
            }
        }
        
        print(longerLine)
        print(radius)
        
        let box = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.015),
            materials: [SimpleMaterial()])
        box.position.y -= Float(radius / 200)
        box.position.z += Float(longerLine[1] / 100)
        
        anchorEntity!.addChild(box)
        
    }
}

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARImageAnchor {
                
                let imganc = anchor as! ARImageAnchor
                let width = imganc.referenceImage.physicalSize.width * imganc.estimatedScaleFactor
                let height = imganc.referenceImage.physicalSize.width * imganc.estimatedScaleFactor
                
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.name = "entityWithBall"
                
                // A plane that covers the whole image to signify that it is found
                let imagePlane = ModelEntity(
                    mesh: MeshResource.generatePlane(width: Float(width), depth: Float(height)),
                    materials: [SimpleMaterial(color: UIColor.green, isMetallic: false)])
                anchorEntity.addChild(imagePlane)
                
                // Left edge of the image
                let leftedge = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.005), materials: [SimpleMaterial()])
                leftedge.position.x += Float(width) / 2
                anchorEntity.addChild(leftedge)
                
                //Right edge of the image
                let rightedge = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.005), materials: [SimpleMaterial()])
                rightedge.position.x -= Float(width) / 2
                anchorEntity.addChild(rightedge)
                
                // Find the difference between how many pixels are
                // between left and right edge to determine pixels per cm
                
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARImageAnchor {
                
                if (updateCV && !lineMapButton) {
                
                    let pos = vector3(anchor.transform[3][0], anchor.transform[3][1], anchor.transform[3][2])
                    let projection = arView.project(pos)
                    
                    let multiplier : Double = Double(arView.bounds.size.height / (arView.session.configuration?.videoFormat.imageResolution.width)!);
                    
                    let lines =  opencv.test(Int32(Double(projection!.x) / multiplier),
                                             y: Int32(Double(projection!.y) / multiplier),
                                             cannyFirstThreshold: Double(cannyFirstSliderValue),
                                             cannySecondThreshold: Double(cannySecondSliderValue),
                                             houghThreshold: Double(houghThresholdSliderValue),
                                             houghMinLength: Double(houghMinLengthSliderValue),
                                             houghMaxGap: Double(houghMaxGapSliderValue),
                                             image: arView.session.currentFrame!.capturedImage,
                                             lineMap: lineMapButton)
                    
                    let points = lines.split(separator: "_")
                    
                    // Remove sublayers from previous frame
                    for subl in arView.layer.sublayers! {
                        if subl is CAShapeLayer {
                            subl.removeFromSuperlayer()
                        }
                    }
                    
                        
                    if (points.count == 0) {
                        break
                    }
                    for i in 0...points.count/4 - 1 {
                        let line = UIBezierPath()
                        
                        line.move(to: CGPoint(x: Double(String(points[i*4]))! * multiplier,
                                              y: Double(String(points[i*4 + 1]))! * multiplier))
                        line.addLine(to: CGPoint(x: Double(String(points[i*4 + 2]))! * multiplier,
                                                 y: Double(String(points[i*4 + 3]))! * multiplier))
                        line.close()
                            
                        let shapeLayer = CAShapeLayer()
                        shapeLayer.path = line.cgPath
                        shapeLayer.opacity = 1
                        shapeLayer.strokeColor = UIColor.blue.cgColor
                        shapeLayer.lineWidth = 3
                    
                        arView.layer.addSublayer(shapeLayer)
                    }
                    
                    updateCV = false
                        
                }

            }
        }
    }
    
}
