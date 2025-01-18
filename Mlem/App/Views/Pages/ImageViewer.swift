//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let url: URL

    let duration: CGFloat = 0.25
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    @GestureState var dragState: Bool = false
    
    /// True when the image is zoomed in, false otherwise
    @State var isZoomed: Bool = false
    
    /// True when dimissal is in progress, false otherwise
    @State var isDismissing: Bool = false
    
    /// Vertical offset of the viewer
    @State var offset: CGFloat = 0
    
    /// Opacity of the viewer
    @State var opacity: CGFloat = 0
    
    // Whether the controls should be shown/hidden
    // @State var controlsShown: Bool = true
    var controlsShown: Bool { controlOffset == 0 && controlOpacity == 1 }
    
    /// Vertical offset for the control overlay
    @State var controlOffset: CGFloat = 0
    
    /// Opacity for the control overlay
    @State var controlOpacity: CGFloat = 1
    
    /// When true, enables tapping to show/hide controls
    @State var enableControlTap: Bool = true
    
    @State var quickLookUrl: URL?
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        self.url = components.url!
    }
    
    var body: some View {
        ZoomableContainer(isZoomed: $isZoomed) {
            MediaView(url: url, playImmediately: true)
        }
        .offset(y: offset)
        .background(.black)
        .opacity(opacity)
        .overlay {
            controlLayer
                .opacity(controlOpacity)
                .opacity(opacity)
        }
//        .onChange(of: controlsShown) {
//            if controlsShown {
//                showControls()
//            } else {
//                hideControls()
//            }
////            withAnimation(.easeOut(duration: duration)) {
////                controlOffset = controlsShown ? 0 : 100
////            }
//        }
        .onChange(of: isZoomed) {
            if isZoomed {
                hideControls(withSlide: true)
                // hideControls(fade: false)
                // controlsShown = false
            } else {
                showControls()
            }
        }
        .onTapGesture {
            if enableControlTap {
                if controlsShown {
                    hideControls()
                } else {
                    showControls()
                }
                // controlsShown = !controlsShown
            }
        }
        .simultaneousGesture(DragGesture(minimumDistance: 1.0)
            .onChanged { value in
                if !isZoomed, !isDismissing {
                    handleOffsetUpdate(value.translation.height)
                }
            }
            .updating($dragState) { _, state, _ in
                // this detects cancelled gestures (e.g., if you zoom while dragging)
                state = true
            }
        )
        .onAppear {
            animateOpacityUpdate(1.0)
        }
        .onChange(of: dragState) {
            if dragState {
                // drag gesture conflicts with control tap, so we disable it for a brief window after detecting a drag
                enableControlTap = false
            } else {
                if abs(offset) > 100 {
                    swipeDismiss(finalOffset: offset > 0 ? screenHeight : -screenHeight)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        enableControlTap = true
                    }
                    animateOffsetUpdate(0)
                }
            }
        }
        .quickLookPreview($quickLookUrl)
        .background(ClearBackgroundView())
    }
    
    @ViewBuilder
    var controlLayer: some View {
        VStack {
            HStack {
                Spacer()
  
                Button {
                    fadeDismiss()
                } label: {
                    Label("Close", systemImage: Icons.close)
                }
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
                .background {
                    Circle().fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                }
                .padding(.trailing, Constants.main.standardSpacing)
            }
            .offset(y: -controlOffset)
            
            Spacer()
            
            HStack {
                Button {
                    Task { await saveImage(url: url) }
                } label: {
                    Label("Save", systemImage: Icons.import)
                }
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
                .offset(y: -2)
                
                Button {
                    Task { await shareImage(url: url, navigation: navigation) }
                } label: {
                    Label("Share", systemImage: Icons.share)
                }
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
                .offset(y: -2)
                
                Button {
                    Task { await showQuickLook(url: url) }
                } label: {
                    Label("QuickLook", systemImage: Icons.menuCircle)
                }
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
            }
            .padding(.horizontal, Constants.main.halfSpacing)
            .background {
                Capsule().fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
            .offset(y: controlOffset)
        }
        .font(.title2)
        .fontWeight(.light)
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
    }
    
    private func fadeDismiss() {
        isDismissing = true
        animateOpacityUpdate(0) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func swipeDismiss(finalOffset: CGFloat = UIScreen.main.bounds.height) {
        isDismissing = true
        animateOffsetUpdate(finalOffset) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func hideControls(withSlide: Bool = false) {
        withAnimation(.easeOut(duration: duration)) {
            if withSlide {
                controlOffset = 50
            }
            controlOpacity = 0
        }
//        if fade {
//            withAnimation(.easeOut(duration: duration)) {
//                controlOpacity = 0
//            }
//        } else {
//            withAnimation(.easeOut(duration: duration)) {
//                controlOffset = 100
//            }
//        }
    }
    
    /// Returns controls to a visible state
    private func showControls() {
        if controlOffset > 0 {
            controlOpacity = 1
            withAnimation(.easeOut(duration: duration)) {
                controlOffset = 0
            }
        } else if controlOpacity < 1 {
            withAnimation(.easeOut(duration: duration)) {
                controlOpacity = 1
            }
        }
    }
    
    private func animateOpacityUpdate(_ newOpacity: CGFloat, callback: (() -> Void)? = nil) {
        withAnimation(.easeOut(duration: duration)) {
            opacity = newOpacity
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
    
    /// Sets the offsets to the given value with animation. If a callback is given, calls it when the animation completes.
    /// - Parameters:
    ///   - newOffset: value to update offsets to
    ///   - callback: function to call when animation completes
    private func animateOffsetUpdate(_ newOffset: CGFloat, callback: (() -> Void)? = nil) {
        withAnimation(.easeOut(duration: duration)) {
            handleOffsetUpdate(newOffset)
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
    
    /// Updates offset, controlOffset, and opacity to match the given raw offset˜
    /// - Parameter newOffset: raw offset to update for
    private func handleOffsetUpdate(_ newOffset: CGFloat) {
        let absOffset = abs(newOffset)
        offset = newOffset
        if controlsShown {
            controlOffset = absOffset
        }
        opacity = 1.0 - (absOffset / screenHeight)
    }
    
    private func showQuickLook(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            quickLookUrl = fileUrl
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
