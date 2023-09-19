//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import LinkPresentation

let metadataProvider = LPMetadataProvider()

struct WebsiteIconComplex: UIViewRepresentable {
    
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true

    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true
    
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
    @MainActor func makeUIView(context: Self.Context) -> Self.UIViewType {
        metadataProvider.shouldFetchSubresources = true
        context.coordinator.url = post.url
        context.coordinator.view = LPLinkView(url: post.url!)
        Task {
            if let meta = try? await context.coordinator.metadataProvider.startFetchingMetadata(for: post.url!) {
//                if meta.remoteVideoURL == nil {
                meta.url = getLink(oldLink: meta.url)
                    meta.originalURL = meta.url // URL(string: str)
//                }
                context.coordinator.view.metadata = meta
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    context.coordinator.fuckUpLPView()
//                }
//                DispatchQueue..asyncAfter(deadline: .now() + 2) {
//                    let view = context.coordinator.view
//                    view.subviews[0].subviews[0].subviews[0].gestureRecognizers?[1].isEnabled = false
//                    print(view.subviews.count)
//                }
            }
        }
        let view = context.coordinator.view
        print(view.subviews.count)
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
        if post.url != context.coordinator.url {
            context.coordinator.metadataProvider = LPMetadataProvider()
            context.coordinator.url = post.url
            Task {
                if let meta = try? await context.coordinator.metadataProvider.startFetchingMetadata(for: post.url!) {
//                    if meta.remoteVideoURL == nil {
                        meta.url = getLink(oldLink: meta.url)
                        meta.originalURL = meta.url // URL(string: str)
//                    }
                    uiView.metadata = meta
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        context.coordinator.fuckUpLPView()
//                    }
                }
            }
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
        
        func fuckUpLPView() {
            Task(priority: .background) {
                let fucked = false
                while !fucked {
                    if await (view.subviews.isEmpty) { continue; }
                    if await (view.subviews[0].subviews.isEmpty) { continue; }
                    if await (view.subviews[0].subviews[0].subviews.isEmpty) { continue; }
                    if await (view.subviews[0].subviews[0].subviews[0].gestureRecognizers?.count ?? 0 < 2) { continue; }
                    guard let reco = await view
                        .subviews[0]
                        .subviews[0]
                        .subviews[0]
                        .gestureRecognizers?[1] as? UITapGestureRecognizer
                    else { continue; }
                    Task { @MainActor in
                        reco.isEnabled = false
                    }
                    break
                }
                print("LPView fucked \(url)")
            }
        }
    }

    typealias UIViewType = LPLinkView
}

struct WebsiteIconComplexOLD: View {
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true

    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true

    let post: APIPost
    var onTapActions: (() -> Void)?
    
    init(
        post: APIPost,
        onTapActions: (() -> Void)? = nil
    ) {
        self.post = post
        self.onTapActions = onTapActions
    }

    @State private var overridenWebsiteFaviconName: String = "globe"

    @Environment(\.openURL) private var openURL

    var faviconURL: URL? {
        guard
            let baseURL = post.linkUrl?.host,
            let imageURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)")
        else {
            return nil
        }

        return imageURL
    }
    
    var linkLabel: String {
        if let embedTitle = post.embedTitle {
            return embedTitle
        } else {
            return post.name
        }
    }
    
    var linkHost: String {
        if let url = post.linkUrl {
            return url.host ?? "some website"
        }
        return "some website"
    }
    
    // REMOVEME: needed for TF hack
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var screenWidth: CGFloat = UIScreen.main.bounds.width - (AppConstants.postAndCommentSpacing * 2)
    var imageWidth: CGFloat { horizontalSizeClass == .regular ? screenWidth * 0.8 : screenWidth }
    var imageHeight: CGFloat { horizontalSizeClass == .regular ? 400 : screenWidth * 0.66 }

    var body: some View {
        VStack(spacing: 0) {
            if shouldShowWebsitePreviews, let thumbnailURL = post.thumbnailImageUrl {
                CachedImage(
                    url: thumbnailURL,
                    shouldExpand: false,
                    // CHANGEME: hack for TF release
                    fixedSize: CGSize(width: imageWidth, height: imageHeight)
                )
                // .frame(maxHeight: 400)
                .frame(width: imageWidth, height: imageHeight)
                .applyNsfwOverlay(post.nsfw)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                if shouldShowWebsiteHost {
                    HStack {
                        if shouldShowWebsiteIcon {
                            CachedImage(
                                url: faviconURL,
                                shouldExpand: false,
                                fixedSize: CGSize(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize),
                                imageNotFound: { AnyView(Image(systemName: "globe")) }
                            )
                        }
                        
                        Text(linkHost)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text(linkLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppConstants.postAndCommentSpacing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel("\(linkLabel) from \(linkHost)")
        .cornerRadius(AppConstants.largeItemCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .stroke(Color(.secondarySystemBackground), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = post.linkUrl {
                openURL(url)
                if let onTapActions {
                    onTapActions()
                }
            }
        }
    }
}
