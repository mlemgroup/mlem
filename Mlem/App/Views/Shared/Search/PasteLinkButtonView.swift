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
        Button("Open URL from Clipboard", icon: .general.paste) {
            if let url = UIPasteboard.general.url {
                openURL(url)
            } else if let string = UIPasteboard.general.string,
                      let url = urlFromString(string),
                      UIApplication.shared.canOpenURL(url) {
                openURL(url)
            } else {
                ToastModel.main.add(.failure("Couldn't read URL"))
            }
        }
    }
    
    func urlFromString(_ string: String) -> URL? {
        if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return webfingersToUrl(string)
    }
    
    func webfingersToUrl(_ webfingers: String) -> URL? {
        do {
            guard let match = try /[!|@](?<name>[\w_-]+)@(?<host>[\w_-]+\.[\w_\-\.]+)+/.wholeMatch(in: webfingers) else { return nil }
            
            let name = match.output.name
            let host = match.output.host
            let prefix = webfingers.starts(with: "@") ? "u" : "c"
            
            return URL(string: "https://\(host)/\(prefix)/\(name)")
        } catch {
            return nil
        }
    }
}
