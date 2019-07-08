//
//  MasksCollectionView.swift
//  FaceMovie
//
//  Created by San Byn Nguyen on 6/23/19.
//  Copyright © 2019 San Byn Nguyen. All rights reserved.
//

import UIKit

class MasksCollectionView: UICollectionView {

    override func awakeFromNib() {
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.minimumLineSpacing = 0
//            collectionViewFlowLayout.scrollDirection = .horizontal
        }
//
//        showsHorizontalScrollIndicator = false
//        showsVerticalScrollIndicator = false
//        alwaysBounceHorizontal = true
//        clipsToBounds = false
    }

}
