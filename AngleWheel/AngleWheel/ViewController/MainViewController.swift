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
    var labelMsgCameraRollAccessNotAllowed: UILabel?
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadImages()
    }
    
    // MARK: - Initialize camera access denied label
    func createCameraAccessDeniedMessage() {
        labelMsgCameraRollAccessNotAllowed?.removeFromSuperview()
        labelMsgCameraRollAccessNotAllowed = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80))
        labelMsgCameraRollAccessNotAllowed?.text = "Camera roll access was denied."
        labelMsgCameraRollAccessNotAllowed?.textColor = .black
        labelMsgCameraRollAccessNotAllowed?.textAlignment = .center
        self.view.addSubview(labelMsgCameraRollAccessNotAllowed!)
        labelMsgCameraRollAccessNotAllowed?.center = self.view.center
    }
    
    // MARK: - Load images
    func loadImages() {
        if let numberOfImages = try? imageManager.loadAssets(numberOfImages: Int.random(in: 10...20)) {
            self.numberOfImages = numberOfImages
            self.collectionView.reloadData()
            imageManager.imageForAsset(assetAtIndex: 0,
                                       forImageSize: CGSize(width: view.frame.width,
                                                            height: view.frame.height),
                                       completion: {  (result) in
                                        self.imageViewBackground.image = result
            })
        } else {
            createCameraAccessDeniedMessage()
        }
    }
    
    func sectionForAngle(angle: Float) -> Int {
        let totalSections = numberOfImages
        return Int(floor(angle / 360.0 * Float(totalSections)))
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
        angleWheelViewController.animateToAngleWithTimer(angle: angle)
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
        let newSection = sectionForAngle(angle: value)
        
        if newSection != currentSection && newSection < imageManager.randomAssets.count {
            indexOfLastSelectedCell = currentSection
            currentSection = newSection
            
            if newSection == indexOfLastSelectedCell {
                collectionView.reloadItems(at: [IndexPath(item: newSection, section: 0)])
            } else {
                collectionView.reloadItems(at: [IndexPath(item: newSection, section: 0)])
                collectionView.reloadItems(at: [IndexPath(item: indexOfLastSelectedCell, section: 0)])
            }
            
            imageManager.imageForAsset(assetAtIndex: newSection,
                                       forImageSize: CGSize(width: view.frame.width,
                                                            height: view.frame.height),
                                        completion: { result in
                                            self.imageViewBackground.image = result
                                            
            })
        }
    }
    
    func didPressAngleButton() {
        loadImages()
    }
}
