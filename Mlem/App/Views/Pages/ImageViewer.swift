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
    
    let duration: CGFloat = 0.25
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    @GestureState var dragState: Bool = false
    
    @State var isZoomed: Bool = false
    @State var offset: CGFloat = 0
    @State var isDismissing: Bool = false
    @State var opacity: CGFloat = 0
    
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
        .background(.black)
        .opacity(opacity)
        .overlay(alignment: .topTrailing) {
            if offset == 0 {
                Button {
                    fadeDismiss()
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
        .simultaneousGesture(DragGesture(minimumDistance: 1.0)
            .updating($dragState) { value, state, _ in
                state = true
                if !isZoomed, !isDismissing {
                    offset = value.translation.height
                    opacity = 1.0 - (abs(value.translation.height) / screenHeight)
                }
            }
        )
        .onAppear {
            updateOpacity(1.0)
        }
        .onChange(of: dragState) {
            if !dragState {
                if abs(offset) > 100 {
                    swipeDismiss(finalOffset: offset > 0 ? screenHeight : -screenHeight)
                } else {
                    updateDragDistance(0)
                }
            }
        }
    }
    
    private func fadeDismiss() {
        isDismissing = true
        updateOpacity(0) {
            mediaState.url = nil
        }
    }
    
    private func swipeDismiss(finalOffset: CGFloat = UIScreen.main.bounds.height) {
        isDismissing = true
        updateDragDistance(finalOffset) {
            mediaState.url = nil
        }
    }
    
    private func updateOpacity(_ newOpacity: CGFloat, callback: (() -> Void)? = nil) {
        print("DEBUG updating opacity to \(newOpacity)")
        withAnimation(.easeOut(duration: duration)) {
            opacity = newOpacity
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
    
    private func updateDragDistance(_ newDistance: CGFloat, callback: (() -> Void)? = nil) {
        withAnimation(.easeOut(duration: duration)) {
            offset = newDistance
            opacity = 1.0 - (abs(newDistance) / screenHeight)
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
}
