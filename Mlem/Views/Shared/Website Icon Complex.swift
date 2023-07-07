//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import CachedAsyncImage
import Foundation
import SwiftUI

struct WebsiteIconComplex: View {
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true

    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true

    @State var post: APIPost

    @State private var overridenWebsiteFaviconName: String = "globe"

    @Environment(\.openURL) private var openURL

    var faviconURL: URL? {
        guard
            let baseURL = post.url?.host,
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
        if let url = post.url {
            return url.host ?? "some website"
        }
        return "some website"
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                if shouldShowWebsitePreviews {
                    if let thumbnailURL =  post.thumbnailUrl {
                        VStack(alignment: .center, spacing: 0) {
                            CachedImageWithNsfwFilter(isNsfw: post.nsfw, url: thumbnailURL)
                                .frame(maxHeight: 400)
                                .clipped()

                            Divider()
                        }
                    }
                }

                HStack(alignment: .center, spacing: 0) {
                    if shouldShowWebsiteFaviconAtAll {
                        if shouldShowWebsiteFavicons {
                            CachedAsyncImage(url: faviconURL, urlCache: AppConstants.urlCache) { image in
                                image
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .saturation(0)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .continuous))
                                    .padding()
                            } placeholder: {
                                Image(systemName: "globe")
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding()
                            }
                        } else {
                            Image(systemName: overridenWebsiteFaviconName)
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.secondary)
                                .padding()
                                .onAppear {
                                    if let url = post.url {
                                        if url.host!.contains("theonion") {
                                            overridenWebsiteFaviconName = "carrot"
                                        } else if url.host!.contains("twitter") {
                                            overridenWebsiteFaviconName = "bird.fill"
                                        } else if url.host!.contains(["youtube", "youtu.be"]) {
                                            overridenWebsiteFaviconName = "play.rectangle.fill"
                                        } else if url.host!.contains("wiki") {
                                            overridenWebsiteFaviconName = "book.closed.fill"
                                        }
                                    }
                                }
                        }

                        Divider()
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(linkLabel)
                        if shouldShowWebsiteHost {
                            Text(linkHost)
                                .lineLimit(1)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
        }
        .groupBoxStyle(OutlinedWebComplexStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel("\(linkLabel) from \(linkHost)")
        .onTapGesture {
            if let url = post.url {
                openURL(url)
            }
        }
    }
}
