//
//  MaskCell.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/22/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit
import SvrfSDK

class MaskCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(id: String) {
        
        
        SvrfSDK.getMedia(id: id, onSuccess: { (media) in
            self.imageView.image = nil
            
            guard let previewImage = media.files?.images?._720x720,
                let imageUrl = URL(string: previewImage) else {
                    
                    print("Could not fetch 720x720 image")
                    return
            }
            
            URLSession.shared.dataTask(with: imageUrl,
                completionHandler: { (data, _, error) in
                    if error != nil {
                        print("Could not fetch image: \(error!)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let data = data, let remoteImage = UIImage(data: data) {
                            self.imageView.image = remoteImage
                        }
                    }
            }).resume()
            
        }) { (err) in
            print(err.svrfDescription ?? "none")
        }
    }
}
