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
    @IBOutlet weak var labelCameraRollAccessDenied: UILabel!
    let imageManager = ImageManager()
    var numberOfImages = 0
    var currentSection = 0
    var indexOfLastSelectedCell = 0
    weak var angleWheelViewController: AngleWheelViewController!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        angleWheelViewController = children[0] as? AngleWheelViewController ?? AngleWheelViewController()
        angleWheelViewController.angleWheelDelegate = self
        labelCameraRollAccessDenied.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PHPhotoLibrary.requestAuthorization({ status in
            self.loadImages()
        })
    }
    
    // MARK: - Initialize camera access denied label
    func createCameraAccessDeniedMessage() {
        labelCameraRollAccessDenied.text = "Camera roll access was denied."
        labelCameraRollAccessDenied.textColor = .black
        labelCameraRollAccessDenied.textAlignment = .center
    }
    
    // MARK: - Load images
    func loadImages() {
        DispatchQueue.main.async {
            if let numberOfImages = try? self.imageManager.loadAssets(numberOfImages: Int.random(in: 10...20)) {
                self.numberOfImages = numberOfImages
                self.collectionView.reloadData()
                self.imageManager.imageForAsset(assetAtIndex: 0,
                                           forImageSize: CGSize(width: self.view.frame.width,
                                                                height: self.view.frame.height),
                                           completion: {  (result) in
                                            self.imageViewBackground.image = result
                })
            } else {
                self.createCameraAccessDeniedMessage()
            }
        }
    }
    
    func sectionForAngle(angle: Float) -> Int {
        let totalSections = numberOfImages
        return Int(floor(angle / 360.0 * Float(totalSections)))
    }
    
    func updateViewBasedOnButtonAngle(angle: Float) {
        let newSection = sectionForAngle(angle: angle)
        
        if newSection != currentSection && newSection < imageManager.randomAssets.count {
            indexOfLastSelectedCell = currentSection
            currentSection = newSection
            DispatchQueue.main.async {
                if newSection == self.indexOfLastSelectedCell {
                    self.collectionView.reloadItems(at: [IndexPath(item: newSection, section: 0)])
                } else {
                    self.collectionView.reloadItems(at: [IndexPath(item: newSection, section: 0)])
                    self.collectionView.reloadItems(at: [IndexPath(item: self.indexOfLastSelectedCell, section: 0)])
                }
                
                self.imageManager.imageForAsset(assetAtIndex: newSection,
                                                forImageSize: CGSize(width: self.view.frame.width,
                                                                     height: self.view.frame.height),
                                                completion: { result in
                                                    self.imageViewBackground.image = result
                                                    
                })
            }
        }
    }
}
// MARK: - Collection view delegate/datasource
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell {
            
            if currentSection == indexPath.item {
                let selectedColor = UIColor(displayP3Red: 14 / 255, green: 172 / 255, blue: 81 / 255, alpha: 1)
                cell.layer.borderColor = selectedColor.cgColor
                cell.layer.borderWidth = 3
            } else {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 3
            }
            
            let cellSize = (collectionView.frame.size.width/3) - 3
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let angle: Float = (Float(indexPath.item) / Float(numberOfImages) * 360) + 1
        angleWheelViewController.animateToAngle(angle: angle)
    }
}
// MARK: Collection View Layout
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
// MARK: AngleWheelDelegate
extension MainViewController: AngleWheelDelegate {
    func didChangeAngleValue(value: Float) {
        updateViewBasedOnButtonAngle(angle: value)
    }
    
    func didPressAngleButton() {
        loadImages()
    }
}
