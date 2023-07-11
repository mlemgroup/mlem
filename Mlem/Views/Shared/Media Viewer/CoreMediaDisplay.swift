//
//  CoreMediaDisplay.swift
//  Mlem
//
//  Created by tht7 on 11/07/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CoreMediaDisplay<Modifers: ViewModifier, Error: View>: View {
    let url: URL?
    let errorView: Error?
    let modifiers: Modifers
    
    @State var didFailLoading: Bool = false
    
    init(
        url: URL?,
        modifiers: Modifers,
        @ViewBuilder error: @escaping () -> Error
    ) {
        self.url = url
        self.errorView = error()
        self.modifiers = modifiers
    }
    
    var defaultErrorView: some View {
        Color.red
            .blur(radius: 30)
            .allowsHitTesting(false)
            .overlay(
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text("Error")
                        .fontWeight(.black)
                }
                    .foregroundColor(.white)
                    .padding(8)
            )
    }
    
    var body: some View {
        if !didFailLoading {
            WebImage(url: url)
                .placeholder { ProgressView() }
                .onFailure { _ in didFailLoading.toggle() }
                .resizable()
                .scaledToFill()
        } else {
            if let errorView = errorView {
                errorView
            } else {
                self.defaultErrorView
            }
        }
    }
}

extension CoreMediaDisplay where Modifers == EmptyModifier, Error == EmptyView {
    init(
        _ url: URL?
    ) {
        self.url = url
        self.errorView = nil
        self.modifiers = EmptyModifier()
    }
}

extension CoreMediaDisplay where Modifers == EmptyModifier {
    init(
        url: URL?,
        @ViewBuilder error: @escaping () -> Error
    ) {
        self.url = url
        self.errorView = error()
        self.modifiers = EmptyModifier()
    }
}

extension CoreMediaDisplay where Error == EmptyView {
    init(
        url: URL?,
        modifiers: Modifers
    ) {
        self.url = url
        self.modifiers = modifiers
        self.errorView = nil
    }
}

#if DEBUG
let testURLs = [
    "https://user-images.githubusercontent.com/6067331/250637207-cb4f2704-6990-4241-b52e-fe20ae90ea1c.mov",
    "https://user-images.githubusercontent.com/6067331/250647789-71280d79-ee35-4d7e-84fd-5ad44282ddcd.mp4",
    "https://user-images.githubusercontent.com/5231793/252165984-9dd512da-f983-475a-a874-82f3dec64a6d.png",
    "https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExOTZsd3doeTVwdDg2Y2V1YWZjemxzOXF6OXA2MncxbTZuZjAzOXplNyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/xQdhiI5XdTCRGokbWy/giphy.gif"
]

struct CoreMediaDisplay_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ForEach(testURLs, id: \.hashValue) { testURL in
            let url = URL(string: testURL)!
            CoreMediaDisplay(url)
                .previewDisplayName(
                    url.pathExtension.capitalized)
        }
    }
}

#endif
