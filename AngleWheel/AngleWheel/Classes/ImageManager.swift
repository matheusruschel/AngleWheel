//
//  ImageManager.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-19.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImageManager {
    private let manager = PHImageManager.default()
    var randomAssets = [PHAsset]()
    var assets = [PHAsset]()
    
    init() {
        let fetchAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        fetchAssets.enumerateObjects({ (object, count, stop) in
            self.assets.append(object)
        })
    }
    
    func loadAssets(numberOfImages: Int) -> Int {
        
        var assetsCopy = Array(assets)
        randomAssets = []

        for _ in 0..<numberOfImages where assetsCopy.count > 0 {
            let randomIndex = Int.random(in: 0..<assetsCopy.count)
            let randomAsset = assetsCopy.remove(at: randomIndex)
            self.randomAssets.append(randomAsset)
        }

        return randomAssets.count
    }
    
    func imageForAsset(assetAtIndex index: Int,
                       forImageSize imageSize: CGSize,
                       completion: @escaping (_ image: UIImage?)-> Void) {
        if index < randomAssets.count && index >= 0 {
            manager.requestImage(for: randomAssets[index],
                                 targetSize: imageSize,
                                 contentMode: .aspectFill,
                                 options: nil) { (result, _) in
                                    completion(result)
            }
        }
    }

}
