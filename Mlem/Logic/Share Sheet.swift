//
//  Share Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

@available(*, deprecated, message: "Migrate to ShareLink")
func showShareSheet(URLtoShare: URL, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
    let activityVC = UIActivityViewController(activityItems: [URLtoShare], applicationActivities: nil)
    activityVC.completionWithItemsHandler = completion
    UIApplication.shared.firstKeyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
