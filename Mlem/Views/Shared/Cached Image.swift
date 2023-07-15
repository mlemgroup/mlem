//
//  Cached Image.swift
//  Mlem
//
//  Created by tht7 on 26/06/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import NukeUI

struct CachedImage: View {

    let url: URL?

    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if state.error != nil {
                // Indicates an error
                Color.red
                    .frame(minWidth: 300, minHeight: 300)
                    .blur(radius: 30)
                    .overlay(VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Error")
                            .fontWeight(.black)
                    }
                    .foregroundColor(.white)
                    .padding(8))
            } else {
                ProgressView() // Acts as a placeholder
                    .frame(minWidth: 300, minHeight: 300)
            }
        }
    }
}
