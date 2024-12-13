//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(Palette.self) var palette
    @Environment(MediaState.self) var mediaState
    
    let url: URL
    
    @State var isZoomed: Bool = false
    @State var offset: CGFloat = UIScreen.main.bounds.height
    @State var isDismissing: Bool = false
    
    var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        self.url = components.url!
    }
    
    var body: some View {
        ZoomableContainer(isZoomed: $isZoomed) {
            DynamicMediaView(url: url, cornerRadius: 0, playImmediately: true)
        }
        .offset(y: offset)
        .onAppear {
            updateDragDistance(0)
        }
        .background(Color.black.opacity(1.0 - (abs(offset) / screenHeight)))
        .overlay(alignment: .topTrailing) {
            if offset == 0 {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: Icons.close)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.white)
                        .padding([.top, .trailing], Constants.main.standardSpacing)
                        .padding([.bottom, .leading], Constants.main.doubleSpacing)
                        .contentShape(.rect)
                }
                .padding(Constants.main.standardSpacing)
            }
        }
        .simultaneousGesture(DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                if !isZoomed, !isDismissing {
                    offset = value.translation.height
                }
            }
            .onEnded { value in
                guard !isDismissing, !isZoomed else { return }
                
                if abs(value.translation.height) > 100 {
                    dismiss(finalOffset: value.translation.height > 0 ? screenHeight : -screenHeight)
                } else {
                    updateDragDistance(0)
                }
            }
        )
    }
    
    private func dismiss(finalOffset: CGFloat = UIScreen.main.bounds.height) {
        isDismissing = true
        updateDragDistance(finalOffset) {
            mediaState.url = nil
        }
    }
    
    private func updateDragDistance(_ newDistance: CGFloat, callback: (() -> Void)? = nil) {
        let duration: CGFloat = 0.35
        withAnimation(.easeOut(duration: duration)) {
            offset = newDistance
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
}
