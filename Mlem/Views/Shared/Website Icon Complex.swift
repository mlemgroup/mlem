//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import LinkPresentation

struct WebsiteIconComplex: UIViewRepresentable {
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    
    @Environment(\.openURL) private var openURL
    
    let post: APIPost
    var onTapActions: (() -> Void)?

    init(
        post: APIPost,
        onTapActions: (() -> Void)? = nil
    ) {
        self.post = post
        self.onTapActions = onTapActions
    }
    
    @MainActor func setURL(_ uiView: Self.UIViewType? = nil, context: Self.Context, url: URL) {
        let testURL: URL? = nil
        context.coordinator.url = url
        context.coordinator.view = uiView ?? LPLinkView(url: testURL ?? url)
        Task {
            if let meta = await LPMetadataTracker.shared.fetch(testURL ?? url) {
                meta.originalURL = getLink(oldLink: meta.url)
                context.coordinator.view.metadata = meta
            }
        }
    }
    
    @MainActor func makeUIView(context: Self.Context) -> Self.UIViewType {
        if let url = post.url {
            self.setURL(nil, context: context, url: url)
        }
        let view = context.coordinator.view
        return view
    }
    
    func getLink(oldLink: URL?) -> URL? {
        if var host = oldLink?.host() {
            host.replace(/www\./, with: "")
            host.replace(/old\./, with: "")
            host.replace(/\.com/, with: "")
            print(host)
            // if there's for sure an app to handle this! let the app open!
            if openApp(host) { return oldLink }
        }
        
        var str: String = (oldLink?.absoluteString ?? "")
        str.replace(/https:\/\//, with: "http://")
        str.replace(/http:\/\//, with: "mlem://")
        return URL(string: str)
    }
    
    func openApp(_ appName: String) -> Bool {
        let appScheme = "\(appName)://app"
        guard let appUrl = URL(string: appScheme) else { return false }

        return UIApplication.shared.canOpenURL(appUrl)

    }
    
    @MainActor func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
        if let url = post.url, post.url != context.coordinator.url {
            self.setURL(uiView, context: context, url: url)
        }
    }
    
    @MainActor func makeCoordinator() -> Self.Coordinator { Self.Coordinator(LPLinkView()) }
    
    @objc class Coordinator: NSObject {
        var view: LPLinkView
        var url: URL?
        var metadataProvider = LPMetadataProvider()
        
        init(_ view: LPLinkView, _ url: URL? = nil) {
            self.view = view
            self.url = url
        }
    }

    typealias UIViewType = LPLinkView
}
