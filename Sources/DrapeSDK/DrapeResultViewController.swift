//
//  DrapeResultViewController.swift
//  DrapeSDK
//
//  Created by Mehmet Kılınçkaya on 21.01.2026.
//

import UIKit
import PhotosUI

public class DrapeResultViewController: UIViewController {
    
    @IBOutlet weak var imageResult: UIImageView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    
    public var resultImageUrl: String?
    
    public init() {
        super.init(nibName: "DrapeResultViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                await self.imageResult.loadImage(from: resultImageUrl)
            }
        }
        self.imageResult.layer.cornerRadius = 20
        self.buttonSave.setTitle(DrapeLanguageManager.getText(for: .save), for: .normal)
        self.buttonShare.setTitle(DrapeLanguageManager.getText(for: .share), for: .normal)
    }
    
    @IBAction func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped() {
        guard let image = self.imageResult.image else { return }
        saveImageToGallery(image)
    }
    
    @IBAction func shareTapped() {
        guard let image = self.imageResult.image else { return }
        self.openShareFor(activityItems: [image])
    }
    
    func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(title: DrapeLanguageManager.getText(for: .success),
                                                  message: DrapeLanguageManager.getText(for: .photoSaved),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: DrapeLanguageManager.getText(for: .done), style: .default))
                    self.present(alert, animated: true)
                } else {
                    debugPrint("Error:", error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func openShareFor(activityItems: [Any]) {
        let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}
