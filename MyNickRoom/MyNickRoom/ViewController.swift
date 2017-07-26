//
//  ViewController.swift
//  MyNickRoom
//
//  Created by David Engelhardt on 7/25/17.
//  Copyright © 2017 Viacom. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        let scene = SCNScene(named: "art.scnassets/raph.scn")!
//        let scene = SCNScene(named: "art.scnassets/leo.scn")!
//        let scene = SCNScene(named: "art.scnassets/spongebob2.scn")!

//        let scene = SCNScene()
//        var raphGeometry : SCNGeometry
//        let tempScene = SCNScene(named: "art.scnassets/raph.scn")
//        raphGeometry = tempScene!.rootNode.childNodes.first!.geometry!
//        let material = SCNMaterial()
//        material.metalness.contents = UIImage(named: "TN_Raph_Metal_C.tif")
////        material.diffuse.contents = UIImage(named: "texture.jpg")
//        raphGeometry.materials = [material]
//        let raphNode = SCNNode(geometry: raphGeometry)
//        scene.rootNode.addChildNode(raphNode)
//
        //-----
        let bundle = Bundle.main
        let path = bundle.path(forResource: "spongebob", ofType: "obj")
        let url = URL(fileURLWithPath: path!)
        let asset = MDLAsset(url: url)
        //-----
//
////        let url = URL(string: "Raph/OBJ/Raph.obj")
////        let asset = MDLAsset(url: url!)
////        let object = asset.object(at: 0)
////        let node = SCNNode(mdlObject: object)
//
//        
//        
////        let scene = SCNScene(named: "Raph.obj")
        let scene = SCNScene(mdlAsset: asset)
////        scene.rootNode.addChildNode(node)
//        
//        
//        
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
//
//        // Load the .OBJ file
//        guard let url = Bundle.main.url(forResource: "Raph", withExtension: "obj") else {
//            fatalError("Failed to find model file.")
//        }
//
//        let asset = MDLAsset(url: url)
//        guard let object = asset.object(at: 0) as? MDLMesh else {
//            fatalError("Failed to get mesh from asset.")
//        }
//
//        // Create a material from the various textures
//        let scatteringFunction = MDLScatteringFunction()
//        let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
//
//        material.setTextureProperties([
//            .BaseColor:"Fighter_Diffuse_25.jpg",
//            .Specular:"Fighter_Specular_25.jpg",
//            .Emission:"Fighter_Illumination_25.jpg"])
//
//        // Apply the texture to every submesh of the asset
//        for submesh in object.submeshes!  {
//            if let submesh = submesh as? MDLSubmesh {
//                submesh.material = material
//            }
//        }
//
//        // Wrap the ModelIO object in a SceneKit object
//        let node = SCNNode(mdlObject: object)
//        let scene = SCNScene()
//        scene.rootNode.addChildNode(node)
//
//        // Set up the SceneView
//        sceneView.scene = scene
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
