//
//  ZoomableContainer.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-14.
//  Adapted from Ice Cubes for Mastodon: https://github.com/Dimillian/IceCubesApp
//

import SwiftUI

// ref: https://stackoverflow.com/questions/74238414/is-there-an-easy-way-to-pinch-to-zoom-and-drag-any-view-in-swiftui

private let maxAllowedScale = 4.0

@MainActor
struct ZoomableContainer<Content: View>: View {
    let content: Content
    @State private var currentScale: CGFloat = 1.0
    @State private var tapLocation: CGPoint = .zero
    
    /// True when currently zooming, false otherwise
    @State private var zooming: Bool = false
    
    /// Tracks whether currently responding to a double tap action
    @State private var handlingDoubleTap: Bool = false
    
    /// True when the current zoom is not 1.0, false otherwise. If the view is double tapped, this
    /// value is set immediately instead of waiting for the zoom to complete.
    @Binding var isZoomed: Bool

    init(isZoomed: Binding<Bool> = .constant(false), @ViewBuilder content: () -> Content) {
        self.content = content()
        self._isZoomed = isZoomed
    }

    func doubleTapAction(location: CGPoint) {
        handlingDoubleTap = true
        tapLocation = location
        if currentScale == 1.0 {
            isZoomed = true
            currentScale = maxAllowedScale
        } else {
            isZoomed = false
            currentScale = 1.0
        }
    }

    var body: some View {
        ZoomableScrollView(scale: $currentScale, tapLocation: $tapLocation, zooming: $zooming) {
            content
        }
        .onTapGesture(count: 2, perform: doubleTapAction)
        .onChange(of: zooming) {
            if !handlingDoubleTap {
                if zooming {
                    isZoomed = true
                } else {
                    isZoomed = currentScale != 1.0
                }
            }
            handlingDoubleTap = false
        }
    }

    fileprivate struct ZoomableScrollView<ScollContent: View>: UIViewRepresentable {
        private var content: ScollContent
        @Binding private var currentScale: CGFloat
        @Binding private var tapLocation: CGPoint
        @Binding private var zooming: Bool
        
        init(
            scale: Binding<CGFloat>,
            tapLocation: Binding<CGPoint>,
            zooming: Binding<Bool>,
            @ViewBuilder content: () -> ScollContent) {
                _currentScale = scale
                _tapLocation = tapLocation
                _zooming = zooming
                self.content = content()
            }

        func makeUIView(context: Context) -> UIScrollView {
            let scrollView = UIScrollView()
            scrollView.backgroundColor = .clear
            scrollView.delegate = context.coordinator
            scrollView.maximumZoomScale = maxAllowedScale
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false
            scrollView.backgroundColor = .clear

            let hostedView = context.coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = true
            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostedView.frame = scrollView.bounds
            hostedView.backgroundColor = .clear
            scrollView.addSubview(hostedView)

            return scrollView
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(hostingController: UIHostingController(rootView: content), scale: $currentScale, zooming: $zooming)
        }

        func updateUIView(_ uiView: UIScrollView, context: Context) {
            context.coordinator.hostingController.rootView = content

            if uiView.zoomScale > uiView.minimumZoomScale { // Scale out
                uiView.setZoomScale(currentScale, animated: true)
            } else if tapLocation != .zero { // Scale in to a specific point
                uiView.zoom(to: zoomRect(for: uiView, scale: uiView.maximumZoomScale, center: tapLocation), animated: true)
                DispatchQueue.main.async { tapLocation = .zero }
            }
        }

        @MainActor func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
            let scrollViewSize = scrollView.bounds.size

            let width = scrollViewSize.width / scale
            let height = scrollViewSize.height / scale
            let x = center.x - (width / 2.0)
            let y = center.y - (height / 2.0)

            return CGRect(x: x, y: y, width: width, height: height)
        }

        // swiftlint:disable nesting
        class Coordinator: NSObject, UIScrollViewDelegate {
            var hostingController: UIHostingController<ScollContent>
            @Binding var currentScale: CGFloat
            @Binding var zooming: Bool

            init(hostingController: UIHostingController<ScollContent>, scale: Binding<CGFloat>, zooming: Binding<Bool>) {
                self.hostingController = hostingController
                _currentScale = scale
                _zooming = zooming
            }

            func viewForZooming(in _: UIScrollView) -> UIView? {
                hostingController.view
            }

            func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale scale: CGFloat) {
                zooming = false
                currentScale = scale
            }
  
            func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
                Task {
                    self.zooming = true
                }
            }
        }
        // swiftlint:enable nesting
    }
}
