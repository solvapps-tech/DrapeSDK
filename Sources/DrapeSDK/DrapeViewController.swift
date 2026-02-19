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
    @IBOutlet weak var viewCameraContainer: UIView!
    @IBOutlet weak var labelOriginal: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var runButton: UIButton!
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
        setTextValues()
        loadProductImage()
    }
    
    func loadProductImage() {
        Task {
            do {
                await self.productImageView.loadImage(from: self.productImageUrl)
                await self.bgImageView.loadImage(from: self.productImageUrl)
            }
        }
    }
    
    func setViewProperties() {
        self.addShadowTo(view: self.viewProductContainer)
        self.addShadowTo(view: self.viewOriginalContainer)
        self.viewCameraContainer.layer.cornerRadius = 50
        
        self.productImageView.layer.cornerRadius = 20
        self.originalImageView.layer.cornerRadius = 20
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    func setTextValues() {
        self.labelOriginal.text = DrapeLanguageManager.getText(for: .yourPhoto)
        self.runButton.setTitle(DrapeLanguageManager.getText(for: .tryNow), for: .normal)
    }
    
    func addShadowTo(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func runDrapeTapped(_ sender: Any) {
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
                    productUrl: productImage
                )
                
                debugPrint("✅ Success! Session ID: \(result.sessionId)")
                
                self.openResultFor(resultImageUrl: result.imageUrl)
                
            } catch {
                debugPrint("🛑 ERROR: \(error.localizedDescription)")
                showError(error.localizedDescription)
            }
            
            startLoading(false)
        }
    }
    
    func openResultFor(resultImageUrl: String?) {
        let controller = DrapeResultViewController()
        controller.resultImageUrl = resultImageUrl
        self.present(controller, animated: true)
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
