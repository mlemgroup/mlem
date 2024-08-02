//
//  LargeImageView.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/2024.
//

import SwiftUI

// ImageView for use in LargePost. Allows blurring NSFW.
// In future this view would also handle alt-text display,
// and anything else that can't go in thumbnail views etc.

struct LargeImageView: View {
    @Environment(NavigationLayer.self) private var navigation
    @AppStorage("safety.blurNsfw") var blurNsfw: Bool = true

    let url: URL?
    var shouldBlur: Bool
    @State var blurred: Bool = false
    
    init(url: URL?, blurred: Bool) {
        @AppStorage("safety.blurNsfw") var shouldBlur = true
        self.url = url
        self.shouldBlur = shouldBlur ? blurred : false
        self._blurred = .init(wrappedValue: shouldBlur ? blurred : false)
    }
    
    @State private var loading: DynamicImageView.LoadingState = .waiting

    var body: some View {
        DynamicImageView(url: url, onLoadingStateChange: { loading = $0 })
            .blur(radius: blurred ? 50 : 0, opaque: true)
            .clipShape(.rect(cornerRadius: AppConstants.largeItemCornerRadius))
            .overlay {
                if blurred {
                    VStack(spacing: 8) {
                        Image(systemName: Icons.warning)
                            .font(.largeTitle)
                        Text("NSFW")
                            .fontWeight(.black)
                    }
                    .foregroundStyle(.white)
                } else if shouldBlur, blurNsfw {
                    Button {
                        blurred = true
                    } label: {
                        Image(systemName: Icons.hide)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 3)
                            .background(.thinMaterial, in: .rect(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .animation(.easeOut(duration: 0.1), value: blurred)
            .onTapGesture {
                if blurred {
                    blurred = false
                } else if loading == .done, let url {
                    // Sheets don't cover the whole screen on iPad, so use a fullScreenCover instead
                    if UIDevice.isPad {
                        navigation.showFullScreenCover(.imageViewer(url))
                    } else {
                        navigation.openSheet(.imageViewer(url))
                    }
                }
            }
    }
}
