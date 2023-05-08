//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct WebsiteIconComplex: View
{
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true

    @State var post: Post

    @State private var overridenWebsiteFaviconName: String = "globe"
    
    @State private var isShowingSafari: Bool = false

    var faviconURL: URL?
    {
        if let baseURL = post.url?.host
        {
            return URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)")!
        }
        else
        {
            return nil
        }
    }

    var body: some View
    {
        GroupBox
        {
            VStack(alignment: .leading, spacing: 0) {
                if let thumbnailURL = post.thumbnailURL
                {
                    VStack(alignment: .center, spacing: 0) {
                        CachedAsyncImage(url: thumbnailURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 400)
                        } placeholder: {
                            ZStack(alignment: .center) {
                                Text("Loading image…")
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: 400)
                                    .background(Color.secondarySystemBackground)
                            }
                        }
                        
                        Divider()
                    }
                }
                HStack(alignment: .center, spacing: 0)
                {
                    if shouldShowWebsiteFavicons
                    {
                        CachedAsyncImage(url: faviconURL)
                        { image in
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
                    }
                    else
                    {
                        Image(systemName: overridenWebsiteFaviconName)
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .padding()
                            .onAppear
                            {
                                if let url = post.url
                                {
                                    if url.host!.contains("theonion")
                                    {
                                        overridenWebsiteFaviconName = "carrot"
                                    }
                                    else if url.host!.contains("twitter")
                                    {
                                        overridenWebsiteFaviconName = "bird.fill"
                                    }
                                    else if url.host!.contains(["youtube", "youtu.be"])
                                    {
                                        overridenWebsiteFaviconName = "play.rectangle.fill"
                                    }
                                    else if url.host!.contains("wiki")
                                    {
                                        overridenWebsiteFaviconName = "book.closed.fill"
                                    }
                                }
                            }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 2)
                    {
                        Text(post.name)

                        if let url = post.url
                        {
                            Text(url.host!)
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
        .onTapGesture {
            print("Bool before: \(isShowingSafari)")
            print("Tapped")
            self.isShowingSafari = true
            print("Bool after: \(isShowingSafari)")
        }
        .sheet(isPresented: $isShowingSafari) {
            InAppSafari(urlToOpen: post.url!)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
