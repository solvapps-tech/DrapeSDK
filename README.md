# Drape SDK for iOS 👗✨

**Turn your fashion app into a Virtual Fitting Room in minutes.**

Drape SDK allows users to virtually try on clothes using their own photos. Powered by advanced Generative AI, it provides realistic fit and texture visualization, increasing user engagement and reducing return rates.

## Features

* 🚀 **Easy Integration:** Add a full virtual try-on experience with just a few lines of code.
* 🎨 **Customizable UI:** Use our pre-built `DrapeViewController` or build your own UI on top of our Core API.
* ⚡️ **High Performance:** Optimized image compression and secure API communication.
* 🌗 **Dark/Light Mode:** Fully compatible with iOS system themes.

---

## Installation

### Swift Package Manager (SPM)

1.  In Xcode, go to **File > Add Packages...**
2.  Enter the repository URL:
    ```
    [https://github.com/solvapps-tech/DrapeSDK.git](https://github.com/solvapps-tech/DrapeSDK.git)
    ```
3.  Select **Up to Next Major Version** (e.g., `1.0.0`).
4.  Click **Add Package**.

---

## Configuration

### 1. Permissions (Info.plist)
To access the user's photo library and camera, add the following keys to your `Info.plist` file:

| Key | Value (Description) |
| :--- | :--- |
| `NSPhotoLibraryUsageDescription` | "We need access to your photos to let you try on clothes virtually." |
| `NSCameraUsageDescription` | "We need camera access to take a photo for the virtual try-on." |
| `NSPhotoLibraryAddUsageDescription` | "We need permission to save the try-on result to your gallery." |

### 2. API Configuration
Configure the SDK with your unique API Key at the start of your application flow or add API Key to your `Info.plist` file:

| Key | Value (Description) |
| :--- | :--- |
| `DrapeAPIKey` | "YOUR_API_KEY" |

```swift
import DrapeSDK

Drape.configure(apiKey: "YOUR_API_KEY")
```

### 3. Usage
You can use the SDK in two ways depending on your needs.

#### Option A: Plug & Play (Built-in UI) 🚀
The fastest way to integrate. Opens a ready-to-use View Controller with image selection, processing, and result display.

```swift
import UIKit
import DrapeSDK

class ProductDetailViewController: UIViewController {

    func openVirtualTryOn() {
        // Initialize the built-in controller
        let drapeVC = DrapeViewController()
        
        // Pass the product image URL (Required)
        drapeVC.productImageUrl = "[https://your-store.com/images/jacket.jpg](https://your-store.com/images/jacket.jpg)"

        self.present(drapeVC, animated: true)
    }
}
```

#### Option B: Custom UI (Core API) 🛠️
If you want to build your own completely custom interface, use the Drape.shared manager to handle the heavy lifting.

```swift
import SwiftUI
import DrapeSDK

// Change this property when user select another category for the product (.upperBody, .lowerBody, or .dresses) 
var selectedCategory: DrapeCategory = .upperBody

func performTryOn(userImage: UIImage, productUrl: String) async {
    do {
        // Call the service
        let result = try await Drape.shared.tryOn(
                    humanImage: humanImage,
                    productUrl: productImage,
                    description: self.selectedCategory.rawValue,
                    category: self.selectedCategory
        )
        
        print("Result Image URL: \(result.imageUrl)")
        
        // Download and display result.imageUrl...
        
    } catch {
        print("Try-on failed: \(error.localizedDescription)")
    }
}
```

#### **Requirements**
iOS 15.0+

Swift 5.5+

Xcode 13+

## License
This SDK is proprietary software. Unauthorized copying, modification, or distribution is strictly prohibited. Copyright © 2026 Drape. All rights reserved.
