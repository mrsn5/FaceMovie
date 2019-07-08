//
//  ARCameraVC
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/23/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit
import ARKit
import ReplayKit
import SvrfSDK

class ARCameraVC: UIViewController, RPPreviewViewControllerDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var lastSnap: UIImageView!
    @IBOutlet weak var gallaryButton: UIButton!
    @IBOutlet weak var shootButton: ShotButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    let contentUpdater = VirtualContentUpdater()
    let remoteFaceFilter = RemoteFaceFilter()
    let recorder = RPScreenRecorder.shared()
    var id: String = ""
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("=================== \n \(id)")
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the ARSCNView session
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration, options: ARSession.RunOptions())
        
        // Keep the screen on
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the ARSCNView session
        sceneView.session.pause()
        
        // Let the screen sleep
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func configure() {
        SvrfSDK.getMedia(id: id, onSuccess: { (media) in
            self.sceneView.delegate = self.contentUpdater
            self.contentUpdater.remoteFaceFilter = self.remoteFaceFilter
            
            self.remoteFaceFilter.loadFaceFilter(media: media)
            self.loadingLabel.isHidden = true
        }) { (err) in
            print(err.svrfDescription ?? "none")
        }
    }
   
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shotPressed(_ sender: Any) {
        let image = sceneView.snapshot()
        lastSnap.isHidden = false
        lastSnap.image = image
        gallaryButton.isHidden = false
        
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        splashView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            self.splashView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }) { (_) in
            self.splashView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.splashView.isHidden = true
        }
        
        if isRecording {
            recorder.stopRecording { [unowned self] (preview, error) in
                if let unwrappedPreview = preview {
                    print("stop record")
                    unwrappedPreview.previewControllerDelegate = self
                    self.present(unwrappedPreview, animated: true)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.recorder.stopRecording { [unowned self] (preview, error) in
                    print("stop record")
                }
            }
        }
        isRecording = false
        shootButton.isHidden = false
        backButton.isHidden = false
        lastSnap.isHidden = false
    }
    
    @IBAction func touchDown(_ sender: Any) {
        print("start recording")
        self.isRecording = false
        
        shootButton.isHidden = true
        backButton.isHidden = true
        lastSnap.isHidden = true
        
        recorder.startRecording{ [unowned self] (error) in
            
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isRecording = true
        }
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        
        dismiss(animated: true)
    }
    
    @IBAction func goToGalleryPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
