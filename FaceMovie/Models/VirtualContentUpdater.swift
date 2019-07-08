//
//  VirtualContentUpdater.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/23/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import SceneKit
import ARKit

class VirtualContentUpdater: NSObject {
    
    // The virtual content that should be displayed and updated.
    var remoteFaceFilter: RemoteFaceFilter? {
        didSet {
            setupFaceNodeContent()
        }
    }
    
    // A reference to the node that was added by ARKit in `renderer(_:didAdd:for:)`.
    private var faceNode: SCNNode?
    
    // The queue reference
    private let serialQueue = DispatchQueue(label: "ua.nguyen.FaceMovie.serialSceneKitQueue")
    
    //MARK: private functions
    private func setupFaceNodeContent() {
        guard let node = faceNode else {
            return
        }
        
        resetFaceNode()
        
        if let content = remoteFaceFilter {
            node.addChildNode(content)
            print("face added")
        }
    }
    
    private func resetFaceNode() {
        guard let node = faceNode else {
            return
        }
        
        // Remove all childNodes from the faceNode
        for child in node.childNodes {
            child.removeFromParentNode()
        }
    }
}

// Extension that realises ARSCNViewDelegate protocol's functions
extension VirtualContentUpdater: ARSCNViewDelegate {
    
    // ARNodeTracking
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Hold onto the `faceNode` so that the session does not need to be restarted when switching Face Filters.
        faceNode = node
        
        // Setup face node content in async thread
        serialQueue.async {
            self.setupFaceNodeContent()
        }
    }
    
    // ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // FaceAnchor unwrapping
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Update virtualFaceNode's blendshapes with FaceAnchor's blendshapes
        remoteFaceFilter?.blendShapes = faceAnchor.blendShapes
//        print("blended")
    }
}
