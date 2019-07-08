//
//  QRScanVC.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/22/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class QRScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var masks: [NSManagedObject] = []
    var collection: MyCollectionVC!
    
    var video = AVCaptureVideoPreviewLayer()
    var isProcess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for m in masks {
            print("------")
            print(m.value(forKeyPath: "id") as! String)
        }

        let session = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            if let captureDevice = captureDevice {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                session.addInput(input)
            }
        } catch {
            print("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = .resizeAspectFill
        video.connection?.videoOrientation = .portrait
        video.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        view.layer.insertSublayer(video, at: 0)
        
        session.startRunning()
        print(view.layer.bounds)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if !isProcess {
            isProcess = true
            if metadataObjects != nil && metadataObjects.count != 0 {
                if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                    if object.type == AVMetadataObject.ObjectType.qr {
                        print(object.stringValue ?? "none")
                        if let url = object.stringValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.isProcess = false
                            }
                            save(id: url)
                        }
                    }
                }
            }
        }
    }
    
    func save(id: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Mask", in: managedContext)!
        let mask = NSManagedObject(entity: entity, insertInto: managedContext)
        
        for m in masks {
            let mid = m.value(forKeyPath: "id") as! String
            print("mid \(mid)")
            if id == mid {
                print("already in data")
                return
                
            }
        }
        
        mask.setValue(id, forKeyPath: "id")
        masks.append(mask)
        
        do {
            try managedContext.save()
            print("Saved")
            self.collection.masks = masks
            dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
