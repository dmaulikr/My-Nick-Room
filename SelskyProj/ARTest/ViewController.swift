//
//  ViewController.swift
//  ARTest
//
//  Created by Selsky, Michael on 7/25/17.
//  Copyright © 2017 Selsky, Michael. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var scaleTransform: CGAffineTransform!
    var barcodes: Set<String> = []
    let recognitionQueue = DispatchQueue(label: "Recognition")
    var videoNode: SCNNode?
    var videoTitles = ["HeyArnold", "SweetVictory"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        self.sceneView.session.delegate = self
        self.sceneView.session.delegateQueue = DispatchQueue.global(qos: .background)
        self.sceneView.isPlaying = true
        self.sceneView.audioListener = self.sceneView.pointOfView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        scaleTransform = CGAffineTransform.init(scaleX: self.sceneView.frame.size.width, y: self.sceneView.frame.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         in sceneView: ARSCNView,
                                         objectPos: float3?,
                                         infinitePlane: Bool = false) -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: float3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane) || !highQualityFeatureHitTestResult {
            
            if let pointOnPlane = objectPos {
                let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
                if pointOnInfinitePlane != nil {
                    return (pointOnInfinitePlane, nil, true)
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let videoNode = self.videoNode else { return }
//        let newNode = SCNNode()
//        newNode.geometry = SCNPlane(width: 1, height: 1)
//        newNode.position = videoNode.position
//        newNode.position.x += Float(arc4random() % 5 * arc4random() % 2 == 0 ? 1 : -1)
//        newNode.position.y += Float(arc4random() % 3 * arc4random() % 2 == 0 ? 1 : -1)
////        newNode.position.z += Float(arc4random() % 5 * arc4random() % 2 == 0 ? 1 : -1)
//        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.random()
//        videoNode.addChildNode(newNode)
//    }
}

extension ViewController: ARSessionDelegate {
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        let barcodeRequest = VNDetectBarcodesRequest { (request, error) in
            guard let result = request.results?.first as? VNBarcodeObservation, let qrCode = result.barcodeDescriptor as? CIQRCodeDescriptor else { return }
            let str = String(data: qrCode.errorCorrectedPayload, encoding: .ascii)
            guard let s = str else { return }
            guard !self.barcodes.contains(s) else { return }

            let newResult = result.topLeft.applying(self.scaleTransform)
            print(newResult)
            let resultingPosition = self.worldPositionFromScreenPosition(newResult, in: self.sceneView, objectPos: nil)
            guard let position = resultingPosition.position else { return }
            DispatchQueue.main.async {
//                let nodePlane = SCNPlane(width: 1, height: 1)
//                let node = SCNNode(geometry: nodePlane)
//                node.position = SCNVector3Make(position.x, position.y, position.z)
//
//
                guard let videoTitle = self.videoTitles.first else {
                    self.sceneView.session.delegate = nil
                    return
                }
                guard let url = Bundle.main.url(forResource: videoTitle, withExtension: "mp4") else { return }
                let spriteKitScene = SKScene(size: CGSize(width: 1276.0 / 2.0, height: 712.0 / 2.0))
                let videoSpritKitNode = SKVideoNode(url: url)
                let videoNode = SCNNode()
                
                videoNode.position = SCNVector3Make(position.x, position.y, position.z)
                
                videoNode.geometry = SCNPlane(width: 0.3, height: 0.3)
                
                spriteKitScene.scaleMode = .aspectFit
                
                videoSpritKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
                videoSpritKitNode.size = spriteKitScene.size
                spriteKitScene.addChild(videoSpritKitNode)
                videoNode.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
                videoNode.geometry?.firstMaterial?.isDoubleSided = true
                videoSpritKitNode.yScale = -1
                self.sceneView.session.delegate = nil
                self.barcodes.insert(s)
                self.sceneView.scene.rootNode.addChildNode(videoNode)
                let audioSource = SCNAudioSource(fileNamed: "\(videoTitle).mp3")
                audioSource?.shouldStream = false
                if let audioS = audioSource{
                    let audioNode = SCNAudioPlayer(source: audioS)
                    print("Has Audio!")
                    videoNode.addAudioPlayer(audioNode)
                    audioNode.didFinishPlayback = {
                        videoNode.removeFromParentNode()
                        if self.videoTitles.count > 0 {
                            self.barcodes.remove(s)
                            self.sceneView.session.delegate = self
                        }
                    }
                }
                self.videoTitles.removeFirst()
                videoSpritKitNode.play()
                print("added node")
                self.videoNode = videoNode

                
                

//                node.geometry?.firstMaterial?.diffuse.contents = playerLayer
//
////                var transform = SCNMatrix4MakeRotation(Float(Double.pi), 0, 0, 1)
////                transform = SCNMatrix4Translate(transform, 1.0, 1.0, 1.0)
////                node.geometry?.firstMaterial?.diffuse.contentsTransform = transform
//
//                player.play()
            }
        }
        
            let pixelBuffer = frame.capturedImage
        recognitionQueue.async {
            do {
                try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([barcodeRequest])
            } catch {
                print(error)
            }
        }
        
    }
 
}

extension UIColor {
    static func random() -> UIColor {
        let colors: [UIColor] = [.black, .blue, .brown, .cyan, .darkGray, .gray, .green, .lightGray, .magenta, .orange, .purple, .red, .white, .yellow]
        
        return colors[Int(arc4random()) % colors.count]
    }
}
