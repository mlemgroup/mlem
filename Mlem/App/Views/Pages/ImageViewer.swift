//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
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
            NewMediaView(url: url, playImmediately: true)
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
            .onChanged { value in
                if !isZoomed, !isDismissing {
                    offset = value.translation.height
                    opacity = 1.0 - (abs(value.translation.height) / screenHeight)
                }
            }
            .updating($dragState) { _, state, _ in
                // this detects cancelled gestures (e.g., if you zoom while dragging)
                state = true
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
        .background(ClearBackgroundView())
    }
    
    private func fadeDismiss() {
        isDismissing = true
        updateOpacity(0) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func swipeDismiss(finalOffset: CGFloat = UIScreen.main.bounds.height) {
        isDismissing = true
        updateDragDistance(finalOffset) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func updateOpacity(_ newOpacity: CGFloat, callback: (() -> Void)? = nil) {
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

// https://stackoverflow.com/a/75037657
// .presentationBackground doesn't behave properly on iOS 17, but this does
// TODO: iOS 17 deprecation: remove this and replace usage with .presentationBackground
private struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        InnerView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            superview?.superview?.backgroundColor = .clear
        }
    }
}
