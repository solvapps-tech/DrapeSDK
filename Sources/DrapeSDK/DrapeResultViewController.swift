//
//  DrapeResultViewController.swift
//  DrapeDemo
//
//  Created by Mehmet Kılınçkaya on 21.01.2026.
//

import UIKit
import PhotosUI

class DrapeResultViewController: UIViewController {
    
    @IBOutlet weak var imageResult: UIImageView!
    
    var resultImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageResult.image = resultImage
        self.imageResult.layer.cornerRadius = 20
    }
    
    @IBAction func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped() {
        guard let image = resultImage else { return }
        saveImageToGallery(image)
    }
    
    @IBAction func shareTapped() {
        guard let image = resultImage else { return }
        self.openShareFor(activityItems: [image])
    }
    
    func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(title: "Başarılı", message: "Fotoğraf galeriye kaydedildi", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self.present(alert, animated: true)
                } else {
                    debugPrint("Hata:", error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func openShareFor(activityItems: [Any]) {
        let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}
