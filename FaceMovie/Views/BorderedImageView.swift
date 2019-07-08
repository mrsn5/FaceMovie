//
//  BorderedImageView.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/23/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit

class BorderedImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        layer.masksToBounds = true
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10
    }

}
