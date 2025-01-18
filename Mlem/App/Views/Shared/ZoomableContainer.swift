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
    @State private var activelyZooming: Bool = false
    @Binding var isZoomed: Bool

    init(isZoomed: Binding<Bool> = .constant(false), @ViewBuilder content: () -> Content) {
        self.content = content()
        self._isZoomed = isZoomed
    }

    func doubleTapAction(location: CGPoint) {
        tapLocation = location
        currentScale = currentScale == 1.0 ? maxAllowedScale : 1.0
    }

    var body: some View {
        ZoomableScrollView(scale: $currentScale, tapLocation: $tapLocation, activelyZooming: $activelyZooming) {
            content
        }
        .onTapGesture(count: 2, perform: doubleTapAction)
//        .onChange(of: currentScale) {
//            isZoomed = currentScale != 1.0
//        }
        .onChange(of: activelyZooming) {
            if activelyZooming {
                isZoomed = true
            } else {
                isZoomed = currentScale != 1.0
            }
        }
    }

    fileprivate struct ZoomableScrollView<ScollContent: View>: UIViewRepresentable {
        private var content: ScollContent
        @Binding private var currentScale: CGFloat
        @Binding private var tapLocation: CGPoint
        @Binding private var activelyZooming: Bool
        
        init(
            scale: Binding<CGFloat>,
            tapLocation: Binding<CGPoint>,
            activelyZooming: Binding<Bool>,
            @ViewBuilder content: () -> ScollContent) {
                _currentScale = scale
                _tapLocation = tapLocation
                _activelyZooming = activelyZooming
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
            Coordinator(hostingController: UIHostingController(rootView: content), scale: $currentScale, activelyZooming: $activelyZooming)
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
            @Binding var activelyZooming: Bool

            init(hostingController: UIHostingController<ScollContent>, scale: Binding<CGFloat>, activelyZooming: Binding<Bool>) {
                self.hostingController = hostingController
                _currentScale = scale
                _activelyZooming = activelyZooming
            }

            func viewForZooming(in _: UIScrollView) -> UIView? {
                hostingController.view
            }

            func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale scale: CGFloat) {
                activelyZooming = false
                currentScale = scale
            }
  
            func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
                Task {
                    self.activelyZooming = true
                }
            }
        }
        // swiftlint:enable nesting
    }
}
