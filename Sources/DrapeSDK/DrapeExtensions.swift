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
