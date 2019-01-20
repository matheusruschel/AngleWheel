//
//  MainViewController.swift
//  AngleWheel
//
//  Created by Matheus Ruschel on 2019-01-19.
//  Copyright © 2019 Matheus Ruschel. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageViewBackground: UIImageView!
    let imageManager = ImageManager()
    var numberOfImages = 0
    var currentSection = 0
    var cellSize: CGFloat!
    weak var angleWheelViewController: AngleWheelViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        angleWheelViewController = children[0] as? AngleWheelViewController ?? AngleWheelViewController()
        angleWheelViewController.angleWheelDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewInitialState()
    }
    
    func setupViewInitialState() {
        cellSize = (collectionView.frame.size.width/3) - 3
        numberOfImages = imageManager.loadAssets(numberOfImages: Int.random(in: 1...3))
        self.collectionView.reloadData()
        imageManager.imageForAsset(assetAtIndex: 0,
                                   forImageSize: CGSize(width: cellSize,
                                                        height: cellSize),
                                   completion: {  (result) in
                                    self.imageViewBackground.image = result
        })
    }
    
    func sectionForAngle(angle: Float) -> Int {
        let totalSections = numberOfImages
        return Int(floor(angle / 360.0 * Float(totalSections)))
    }
}
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell {
            imageManager.imageForAsset(assetAtIndex: indexPath.row,
                                       forImageSize: CGSize(width: cellSize,
                                       height: cellSize),
                                       completion: {  (result) in
                                        cell.imageViewPhoto.image = result
            })
            
            return cell
        }
        return UICollectionViewCell()
    }
}
// MARK: <UICollectionViewDelegateFlowLayout>
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView( _ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellLeg = (collectionView.frame.size.width/3) - 3
        return CGSize(width: cellLeg,height: cellLeg)
    }
}
extension MainViewController: AngleWheelDelegate {
    func didChangeAngleValue(value: Float) {
        let newSection = sectionForAngle(angle: value)
        
        if newSection != currentSection {
            currentSection = newSection
            imageViewBackground.image = imageManager.images[newSection]
        }
    }
}
