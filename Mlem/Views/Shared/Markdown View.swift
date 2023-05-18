//
//  Markdown View.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import SwiftUI
import MarkdownUI
import SafariServices

extension Theme
{
    static let mlem = Theme()
        .blockquote { label in
            label.body
                .markdownTextStyle {
                    ForegroundColor(.secondary)
                }
        }
}

struct MarkdownView: View {
    @Environment(\.openURL) private var openURL
    
    @State var text: String
    
    var body: some View {
        Markdown(text)
            .markdownTheme(.gitHub)
            .environment(\.openURL, OpenURLAction { interceptedURL in
                let safariViewController = SFSafariViewController(url: interceptedURL, configuration: AppConstants.inAppSafariConfiguration)
                
                UIApplication.shared.firstKeyWindow?.rootViewController?.present(safariViewController, animated: true)
                
                return .handled
            })
    }
}
