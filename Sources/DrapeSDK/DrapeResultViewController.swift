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
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var viewShareContainer: UIView!
    @IBOutlet weak var viewCloseContainer: UIView!
    
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
        self.viewShareContainer.layer.cornerRadius = 25
        self.viewCloseContainer.layer.cornerRadius = 25
    }
    
    @IBAction func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareTapped() {
        guard let image = self.imageResult.image else { return }
        self.openShareFor(activityItems: [image])
    }
    
    func openShareFor(activityItems: [Any]) {
        let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}
