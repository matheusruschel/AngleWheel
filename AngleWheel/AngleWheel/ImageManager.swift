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
    private var randomAssets = [PHAsset]()
    var images = [UIImage]()
    
    func loadAssets(numberOfImages: Int) -> Int {
        var assets = [PHAsset]()
        randomAssets = []
        images = []
        
        let fetchAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        fetchAssets.enumerateObjects({ (object, count, stop) in
            assets.append(object)
            if count > 100 {
                stop.pointee = true
            }
        })
        for _ in 0...numberOfImages {
            let randomIndex = Int.random(in: 0..<assets.count)
            let randomAsset = assets.remove(at: randomIndex)
            self.randomAssets.append(randomAsset)
        }

        return randomAssets.count
    }
    
    func imageForAsset(assetAtIndex index: Int,
                       forImageSize imageSize: CGSize,
                       completion: @escaping (_ image: UIImage?)-> Void) {
        
        
        if index >= 0 && index < images.count {
            completion(images[index])
            return
        }
        
        manager.requestImage(for: randomAssets[index],
                             targetSize: imageSize,
                             contentMode: .aspectFill,
                             options: nil) { (result, _) in
                                self.images.insert(result!, at: index)
                                completion(result)
        }
    }

}
