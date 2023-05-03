//
//  Share Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

func showShareSheet(URLasString: String)
{
    let urlToShare = URL(string: URLasString)!
    let activityVC = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}
