//
//  Sticky Image View.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct StickyImageView: View {

    @State var url: URL?

    var body: some View {
        GeometryReader { proxy in
            AsyncImage(url: url) { banner in
                banner
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: self.getHeightForHeaderImage(proxy), alignment: .center)
                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(proxy))
            } placeholder: {
                ProgressView()
            }
        }
        .frame(height: 300)
    }

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)

        if offset > 0 {
            return -offset
        }

        return 0
    }
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)

        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
}
