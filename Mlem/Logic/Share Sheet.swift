//
//  Share Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

func showShareSheet(URLtoShare: URL) {
    let activityVC = UIActivityViewController(activityItems: [URLtoShare], applicationActivities: nil)
    UIApplication.shared.firstKeyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
