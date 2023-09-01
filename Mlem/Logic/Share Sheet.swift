//
//  Share Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

// TODO: let's stop with the global functions? 😬
func showShareSheet(URLtoShare: URL, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
    let activityVC = UIActivityViewController(activityItems: [URLtoShare], applicationActivities: nil)
    activityVC.completionWithItemsHandler = completion
    if var topController = UIApplication.shared.firstKeyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        topController.present(activityVC, animated: true, completion: nil)
    }
}

func showShareSheet(items: [Any], completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    activityVC.completionWithItemsHandler = completion
    if var topController = UIApplication.shared.firstKeyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        topController.present(activityVC, animated: true, completion: nil)
        // topController should now be your topmost view controller
    }
    
}
