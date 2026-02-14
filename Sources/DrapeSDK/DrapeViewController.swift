//
//  DrapeViewController.swift
//  DrapeSDK
//
//  Created by Mehmet Kılınçkaya on 15.01.2026.
//

import UIKit
import PhotosUI

public class DrapeViewController: UIViewController {
    
    @IBOutlet weak var viewProductContainer: UIView!
    @IBOutlet weak var viewOriginalContainer: UIView!
    @IBOutlet weak var viewResultContainer: UIView!
    @IBOutlet weak var labelProduct: UILabel!
    @IBOutlet weak var labelOriginal: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var buttonCategory: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var productImageUrl: String?
    var selectedCategory: DrapeCategory = .upperBody
    
    public init() {
        super.init(nibName: "DrapeViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setViewProperties()
        loadProductImage()
    }
    
    func loadProductImage() {
        guard let productImageUrl = self.productImageUrl else { return }
        Task {
            do {
                await loadImage(from: productImageUrl, forImageView: self.productImageView)
            }
        }
    }
    
    func setViewProperties() {
        self.viewProductContainer.layer.cornerRadius = 20
        self.viewOriginalContainer.layer.cornerRadius = 20
        self.viewResultContainer.layer.cornerRadius = 20
        
        self.productImageView.layer.cornerRadius = 20
        self.originalImageView.layer.cornerRadius = 20
        self.resultImageView.layer.cornerRadius = 20
        
        self.buttonCategory.setTitle(self.selectedCategory.visibleName, for: .normal)
    }
    
    @IBAction func selectImageTapped(_ sender: Any) {
        let saveImage = UIAlertAction(title: DrapeLanguageManager.getText(for: .choseFromGalery), style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }
        let openFullImage = UIAlertAction(title: DrapeLanguageManager.getText(for: .openCamera), style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated: true)
        }
        let cancelAction = UIAlertAction(title: DrapeLanguageManager.getText(for: .cancel), style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: DrapeLanguageManager.getText(for: .options),
                                                message: DrapeLanguageManager.getText(for: .toAddPhoto),
                                                preferredStyle: .actionSheet)
        alertController.addAction(saveImage)
        alertController.addAction(openFullImage)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func categoryTapped(_ sender: Any) {
        let upperBodyAction = UIAlertAction(title: DrapeCategory.upperBody.visibleName, style: .default) { _ in
            self.selectedCategory = .upperBody
            self.buttonCategory.setTitle(DrapeCategory.upperBody.visibleName, for: .normal)
        }
        let lowerBodyAction = UIAlertAction(title: DrapeCategory.lowerBody.visibleName, style: .default) { _ in
            self.selectedCategory = .lowerBody
            self.buttonCategory.setTitle(DrapeCategory.lowerBody.visibleName, for: .normal)
        }
        let dressAction = UIAlertAction(title: DrapeCategory.dresses.visibleName, style: .default) { _ in
            self.selectedCategory = .dresses
            self.buttonCategory.setTitle(DrapeCategory.dresses.visibleName, for: .normal)
        }
        
        let alertController = UIAlertController(title: DrapeLanguageManager.getText(for: .choseCategory),
                                                message: DrapeLanguageManager.getText(for: .categorySelectText),
                                                preferredStyle: .actionSheet)
        alertController.addAction(upperBodyAction)
        alertController.addAction(lowerBodyAction)
        alertController.addAction(dressAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func runDrapeTapped(_ sender: Any) {
        resultImageView.image = nil
        labelResult.isHidden = false
        guard let productImage = productImageUrl else {
            self.showError(DrapeLanguageManager.getText(for: .choseProductPhoto))
            return
        }
        guard let humanImage = originalImageView.image else {
            self.showError(DrapeLanguageManager.getText(for: .chosePhoto))
            return
        }
        
        startLoading(true)
        
        Task {
            do {
                debugPrint("🚀 Drape starting...")
                
                let result = try await Drape.shared.tryOn(
                    humanImage: humanImage,
                    productUrl: productImage,
                    category: self.selectedCategory
                )
                
                debugPrint("✅ Success! Session ID: \(result.sessionId)")
                debugPrint("🖼️ Generated image url: \(result.imageUrl)")
                
                labelResult.isHidden = true
                await loadImage(from: result.imageUrl, forImageView: self.resultImageView)
                
            } catch {
                debugPrint("🛑 ERROR: \(error.localizedDescription)")
                debugPrint("🛑 RAW ERROR: \(error)")
                showError(error.localizedDescription)
            }
            
            startLoading(false)
        }
    }
    
    @IBAction func resultImageTapped() {
        guard let resultImage = resultImageView.image else { return }
        let controller = DrapeResultViewController()
        controller.resultImage = resultImage
        self.present(controller, animated: true)
    }
    
    func loadImage(from urlString: String, forImageView: UIImageView) async {
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }
        
        forImageView.image = image
    }
    
    func startLoading(_ isLoading: Bool) {
        runButton.isEnabled = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func showError(_ msg: String) {
        let alert = UIAlertController(title: DrapeLanguageManager.getText(for: .error), message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: DrapeLanguageManager.getText(for: .done), style: .default))
        present(alert, animated: true)
    }

}

extension DrapeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImageView.image = image
        }
        picker.dismiss(animated: true)
    }
}
