//
//  FullScreenViewer.swift
//  Mlem
//
//  Created by tht7 on 27/07/2023.
//

import SwiftUI

struct FullScreenViewer<Content: View>: View {

    @Environment(\.fullscreenLabel) var label
    @Environment(\.fullscreenContextMenu) var fullScreenContextMenu
    @Environment(\.onFullscreenDoubleTap) var doubleTapHandler

    @Binding var isOpen: Bool
    @State var animating: Bool = false
    @State var closiness: Double = 0
    @State var scrubbingHint = false

    @State var zoomScale: CGFloat = 1
    @State var contentOffset: CGPoint = .zero
    @State var doubleTapLocation: CGPoint = .zero
    @State var mediaSize: CGSize = .zero

    @State var showUI: Bool = true

    @StateObject var mediaState: MediaState = .init()

    let media: Content

    @State var momentryView: AnyView?

    @State var donatedContextActions: [MenuFunction] = .init()

    init(
        isOpen: Binding<Bool>,
        @ViewBuilder media: @escaping() -> Content
    ) {
        _mediaState = .init(wrappedValue: .init())
        _isOpen = isOpen
        self.media = media()
    }

    func getContent() -> AnyView {
        if let contentEX = self.media as? (any FullScreenActualContent),
           let url = contentEX.fullscreenContent {
            return AnyView(
                CoreMediaViewer(
                    url: url,
                    mediaStateSyncObject: mediaState,
                    errorView: { _ in EmptyView() },
                    onImageLoad: { _, size in mediaSize = size }
                    )
                )
        }
        return AnyView(media)
    }

    var body: some View {
        let actualContent = getContent()
        ZStack {
            GestureView(
                closiness: $closiness,
                animating: $animating,
                scale: $zoomScale,
                tapLocation: $doubleTapLocation,
                contentOffset: $contentOffset,
                content: {
                    VStack(spacing: 0) {
                        actualContent
                            .contextMenu {
                                ForEach(self.donatedContextActions) { item in
                                    Button {
                                        item.callback()
                                    } label: {
                                        Label(item.text, systemImage: item.imageName)
                                    }
                                }
                                ForEach(fullScreenContextMenu?() ?? []) { item in
                                    Button {
                                        item.callback()
                                    } label: {
                                        Label(item.text, systemImage: item.imageName)
                                    }
                                }
                            }
                    }
                }
            ).onTapGesture(count: 2) { _ in
                // Double tep to zoom
                if let doubleTapHandler = doubleTapHandler {
                    momentryView = AnyView(EmptyView())
                    Task { @MainActor in
                        withAnimation {
                            momentryView = doubleTapHandler()
                        }
                    }
                } 
                // unused buggy double-tap-to-zoom
//                else {
//                    doubleTapLocation = $0
//                }
            }.onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showUI.toggle()
                }
            }
            VStack(alignment: .leading) {
                if showUI {
                    HStack {
                        Button {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                isOpen.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.largeTitle)
                                .padding()
                        }
                        .background(.regularMaterial)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                        )
                        Spacer()
                    }
                    Spacer()

                    HStack {
                        let labelView = VStack {
                            if mediaState.duration > 0 {
                                ScrubberSlider(mediaState: mediaState)
                            }
                            if !scrubbingHint {
                                (label?() ?? AnyView(EmptyView()))
//                                    .padding()
                            } else {
                                ScrubberHint()
                                    .padding()
                            }
                        }
                            .background(.regularMaterial)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                            )
                        if mediaState.duration > 0 {
                            labelView
                                .gesture(
                                    DragGesture()
                                        .onChanged { action in
                                            animating = true
                                            mediaState.isPlaying = false
                                            mediaState.isEditingCurrentTime = true
                                            var time = action.translation.width
                                                .truncatingRemainder(dividingBy: mediaState.duration)
                                            if time < 0 {
                                                time = mediaState.duration + time
                                            }
                                            mediaState.currentTime = time
                                        }
                                        .onEnded { _ in
                                            animating = false
                                            mediaState.isEditingCurrentTime = false
                                            mediaState.isPlaying = true
                                        }
                                )
                        } else {
                            labelView
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            momentryView
        }
        .environment(\.fullscreenDismiss) {
            withAnimation {
                momentryView = nil
            }
        }
        .environment(\.fullscreenContextMenuDonationCollector) { menuFunctions in
            Task { @MainActor in
                donatedContextActions = menuFunctions
            }
        }
        .onChange(of: zoomScale) { newScale in
            withAnimation(.easeInOut(duration: 0.2)) {
                showUI = newScale <= 1
            }
        }
        .onChange(of: animating) { isAnimating in
            if !isAnimating {
                if closiness > 20 {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        isOpen.toggle()
                    }
                }
            }
        }
        .onChange(of: contentOffset) { newOffset in
            if mediaState.duration > 0 && zoomScale == 1 && (newOffset.x < -15 || newOffset.x > 15) {
                withAnimation {
                    scrubbingHint = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            scrubbingHint = false
                        }
                    }
                }
            }
        }
        .background {
            Color.black.opacity((100 - closiness)/100).ignoresSafeArea()
        }
    }
}

#if DEBUG
struct FullScreenViewerPreview: PreviewProvider {
    @Namespace static var testing
    static var previews: some View {
        ForEach(testImageURLs) { testURL in
            FullScreenViewer(isOpen: .constant(true)) {
                CachedImage(url: testURL, shouldExpand: false)
            }.fullScreenLabel {
                AnyView(
                    VStack(alignment: .leading) {
                        Text("Post title")
                            .font(.title2)
                        Text("image alt text")
                            .font(.body)
                        HStack {
                            Spacer()
                            Button {
                                print("up")
                            } label: {
                                Image(systemName: "arrow.up")
                            }.padding(.horizontal, 4)
                            Spacer()
                            Button {
                                print("down")
                            } label: {
                                Image(systemName: "arrow.down")
                            }.padding(.horizontal, 4)
                            Spacer()
                            Button {
                                print("save")
                            } label: {
                                Image(systemName: "bookmark")
                            }.padding(.horizontal, 4)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                })
            }
            .previewDisplayName(testURL.pathExtension.capitalized)
        }
    }
}
#endif
