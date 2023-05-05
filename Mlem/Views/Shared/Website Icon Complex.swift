//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI

struct WebsiteIconComplex: View
{
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true

    @State var title: String?
    @State var url: URL

    @State private var overridenWebsiteFaviconName: String = "globe"

    var faviconURL: URL
    {
        return URL(string: "https://www.google.com/s2/favicons?sz=32&domain=\(url)")!
    }

    var body: some View
    {
        GroupBox
        {
            HStack(alignment: .center, spacing: 15)
            {
                if shouldShowWebsiteFavicons
                {
                    AsyncImage(url: faviconURL)
                    { image in
                        image
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .saturation(0)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .continuous))
                    } placeholder: {
                        Image(systemName: "globe")
                    }
                }
                else
                {
                    Image(systemName: overridenWebsiteFaviconName)
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .foregroundColor(.secondary)
                        .onAppear
                        {
                            if url.host!.contains("theonion")
                            {
                                overridenWebsiteFaviconName = "carrot"
                            }
                            else if url.host!.contains("twitter")
                            {
                                overridenWebsiteFaviconName = "bird.fill"
                            }
                            else if url.host!.contains("youtube")
                            {
                                overridenWebsiteFaviconName = "play.rectangle.fill"
                            }
                        }
                }

                Divider()

                VStack(alignment: .leading, spacing: 10)
                {
                    if let title
                    {
                        Text(title)
                            .multilineTextAlignment(.leading)
                    }

                    Text(url.host!)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}
