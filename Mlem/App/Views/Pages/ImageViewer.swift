//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(Palette.self) var palette
    
    let url: URL
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { item in
            !(item.name.starts(with: "thumbnail"))
        }
        self.url = components.url!
    }
    
    var body: some View {
        ZoomableContainer {
            DynamicImageView(url: url)
                .padding(Constants.main.standardSpacing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView()
            }
        }
        .background(palette.background)
    }
}
