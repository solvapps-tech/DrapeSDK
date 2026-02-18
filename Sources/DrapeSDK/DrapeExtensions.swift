//
//  DrapeExtensions.swift
//  DrapeSDK
//
//  Created by Mehmet Kılınçkaya on 18.02.2026.
//

import Foundation
import UIKit

class DrapeExtensions {
    
}

extension UIImageView {
    func loadImage(from urlString: String?) async {
        guard let urlString = urlString,
              let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }
        
        self.image = image
    }
}

extension UIView {
    func addGlassEffect() {
        let glassEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.frame = self.bounds
        glassView.layer.cornerRadius = self.bounds.height / 2
        glassView.clipsToBounds = true
        glassView.layer.borderWidth = 0.5
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        let viberancyEffect = UIVibrancyEffect(blurEffect: glassEffect, style: .label)
        let vibrancyView = UIVisualEffectView(effect: viberancyEffect)
        vibrancyView.frame = glassView.contentView.bounds
        glassView.contentView.addSubview(vibrancyView)
        glassView.isUserInteractionEnabled = false
        self.insertSubview(glassView, at: 0)
    }
}
