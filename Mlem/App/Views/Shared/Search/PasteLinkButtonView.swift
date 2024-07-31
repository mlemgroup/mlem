//
//  PasteLinkButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 20/06/2024.
//

import Dependencies
import SwiftUI

struct PasteLinkButtonView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button("Open URL from Clipboard", systemImage: Icons.paste) {
            if let url = UIPasteboard.general.url {
                openURL(url)
            } else if let string = UIPasteboard.general.string,
                      let url = URL(string: string),
                      UIApplication.shared.canOpenURL(url) {
                openURL(url)
            } else {
                ToastModel.main.add(.failure("Couldn't read URL"))
            }
        }
    }
}
