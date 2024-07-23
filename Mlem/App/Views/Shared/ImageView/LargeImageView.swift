//
//  LargeImageView.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/2024.
//

import SwiftUI

// ImageView for use in LargePost and inline images. Allows blurring NSFW.
// In future this view would also handle alt-text display, and anything else
// that can't go in thumbnail views etc.

struct LargeImageView: View {
    @Environment(NavigationLayer.self) private var navigation

    let url: URL?
    @State var blurred: Bool = false
    
    @State private var loading: ImageView.LoadingState = .waiting

    var body: some View {
        ImageView(url: url, onLoadingStateChange: { loading = $0 })
            .blur(radius: blurred ? 50 : 0, opaque: true)
            .clipShape(.rect(cornerRadius: AppConstants.largeItemCornerRadius))
            .overlay {
                if blurred {
                    VStack(spacing: AppConstants.standardSpacing) {
                        Image(systemName: Icons.warning)
                            .font(.largeTitle)
                        Text("NSFW")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                } else {
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
