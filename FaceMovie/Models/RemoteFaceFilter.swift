//
//  RemoteFaceFilter.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/23/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import SvrfSDK

class RemoteFaceFilter: SCNNode {
    // Root node which will have the Face Filter as it's child
    private var faceFilter: SCNNode?
    
    // BlendShapeAnimation
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:] {
        didSet {
            
            // Each child node may have blend shape targets so we enumerate over all of them to make sure
            // that each blend target is expressed completely
            faceFilter?.enumerateHierarchy({ (node, _) in
                if node.morpher?.targets != nil {
                    SvrfSDK.setBlendShapes(blendShapes: blendShapes, for: node)
                }
            })
        }
    }
    
    func loadFaceFilter(media: SvrfMedia) -> Void {
        
        // Generate a Face Filter SCNNode from a Media in a background thread
        DispatchQueue.global(qos: .background).async { [unowned self] in
            SvrfSDK.generateFaceFilterNode(for: media, onSuccess: { (faceFilter) in
                // Remove any existing Face Filter from the SCNScene
                self.resetFaceFilter()
                // Set new Face Filter
                self.faceFilter = faceFilter
                
                // Add the Face Filter as a child node
                if let head = self.faceFilter {
                    self.addChildNode(head)
                }
                print("generated")
            })
        }
    }
    
    // Deletes all childNodes from the self.faceFilter
    func resetFaceFilter() {
        if let head = self.faceFilter {
            for child in head.childNodes {
                child.removeFromParentNode()
            }
        }
    }
}
