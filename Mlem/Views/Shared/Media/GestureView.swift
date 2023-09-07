//
//  GestureView.swift
//  Mlem
//
//  Created by tht7 on 27/07/2023.
//

import Foundation
import UIKit
import SwiftUI

private let maxAllowedScale = 8.0

struct GestureView<Content: View>: UIViewRepresentable {
    typealias Coordinator = GestureCoordinator<Content>

    public var content: Content
    @Binding public var currentScale: CGFloat
    @Binding public var tapLocation: CGPoint
    @Binding public var contentOffset: CGPoint
    @Binding public var closiness: Double
    @Binding public var animating: Bool
    
    init(
        closiness: Binding<Double>,
        animating: Binding<Bool>,
        scale: Binding<CGFloat>,
        tapLocation: Binding<CGPoint>,
        contentOffset: Binding<CGPoint>,
        @ViewBuilder content: () -> Content
    ) {
        _animating = animating
        _closiness = closiness
        _currentScale = scale
        _tapLocation = tapLocation
        _contentOffset = contentOffset
        self.content = content()
    }

    func makeUIView(context: Context) -> CenteringScrollView {
        // Setup the UIScrollView
        let scrollView = CenteringScrollView()
        scrollView.delegate = context.coordinator // for viewForZooming(in:)
        scrollView.maximumZoomScale = maxAllowedScale
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        // Create a UIHostingController to hold our SwiftUI content
        let hostingController = context.coordinator.hostingController
        let hostedView = hostingController.view!
        hostedView.contentMode = .scaleAspectFit
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.preservesSuperviewLayoutMargins = false
//        hostedView.backgroundColor = .blue
        hostingController.sizingOptions =  [.intrinsicContentSize]
        scrollView.addSubview(hostedView)
        
        hostedView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        hostedView.topAnchor.constraint(lessThanOrEqualTo: scrollView.topAnchor).isActive = true
        hostedView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor).isActive = true
        
        context.coordinator.setParent(scrollView)
        
//        hostedView.invalidateIntrinsicContentSize()
//        scrollView.setNeedsLayout()
        
        scrollView.backgroundColor = .clear
        DispatchQueue.main.async {
            scrollView.superview?.superview?.backgroundColor = .clear
        }
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController:
                            UIHostingController(rootView: content),
                           animating: _animating,
                           closiness: $closiness,
                           scale: $currentScale,
                           contentOffset: $contentOffset
        )
    }

    func updateUIView(_ uiView: CenteringScrollView, context: Context) {
        // Update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = content
        
        context.coordinator.hostingController.view.invalidateIntrinsicContentSize()
        uiView.setNeedsLayout()
        
        if context.coordinator.isAnimating {
            return
        }
        
        if uiView.zoomScale > uiView.minimumZoomScale { // Scale out
            uiView.setZoomScale(currentScale, animated: true)
        } else if tapLocation != .zero { // Scale in to a specific point
            uiView.zoom(to: zoomRect(for: uiView, scale: uiView.maximumZoomScale, center: tapLocation), animated: true)
            // Reset the location to prevent scaling to it in case of a negative scale (manual pinch)
            // Use the main thread to prevent unexpected behavior
            DispatchQueue.main.async { tapLocation = .zero }
        }
        
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    func zoomRect(for scrollView: CenteringScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        let scrollViewSize = scrollView.bounds.size

        let width = scrollViewSize.width / scale
        let height = scrollViewSize.height / scale
        let x = center.x - (width / 2.0)
        let y = center.y - (height / 2.0)

        return CGRect(x: x, y: y, width: width, height: height)
    }
}

class CenteringScrollView: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // this will adjust the content inset to make sure that even if the SwiftUI view changes size it's centered nicly
        guard let contentSize = subviews.last?.bounds.size else { return }
        self.contentSize = CGSize(
            width: contentSize.width * zoomScale,
            height: contentSize.height * zoomScale)
        var scrollViewInsets: UIEdgeInsets = .zero
        scrollViewInsets.top = ((bounds.size.height)/2.0) - safeAreaInsets.top
        scrollViewInsets.top -= (self.contentSize.height)/2.0
        
        scrollViewInsets.top = max(scrollViewInsets.top, 0)
        if contentInset.top != scrollViewInsets.top || contentInset.bottom != scrollViewInsets.bottom {
            contentInset = scrollViewInsets
            adjustedContentInsetDidChange()
        }
    }
}

// MARK: - Coordinator
class GestureCoordinator<Content: View>: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>
    var parent: CenteringScrollView = CenteringScrollView()
    @Binding var currentScale: CGFloat
    @Binding var contentOffset: CGPoint
    @Binding var animating: Bool
    @Binding private var closiness: Double
    public var dragClosiness: CGFloat = 0
    public var zoomingClosiness: CGFloat = 0
    
    public var isAnimating: Bool {
        isZooming || isDragging
    }
    
    /*** tht7 note:
     * we can't use UIScrollView.isDragging/.isZooming since they report "true" until the *animations* are done
     * by that time the scroll scale and position have already been bounced back, so we can't use them to detect if the user finied the action in a position that would dismiss the view
     */
    public var isZooming: Bool {
        parent.pinchGestureRecognizer?.state == .began ||
        parent.pinchGestureRecognizer?.state == .changed
    }
    
    public var isDragging: Bool {
        parent.panGestureRecognizer.state == .began ||
        parent.panGestureRecognizer.state == .changed
    }
    
    func setParent(_ parent: CenteringScrollView) {
        self.parent = parent
        
        parent.pinchGestureRecognizer?.addTarget(self, action: #selector(self.handleZooming))
        parent.panGestureRecognizer.addTarget(self, action: #selector(self.handlePanning))
    }
    
    func getBounds() -> (Double, Double) {
        let contentSizeHeight = hostingController.view!.bounds.size.height * parent.zoomScale
        let topOffest = max(
            (((parent.bounds.size.height)/2.0)) - (contentSizeHeight/2.0),
            parent.safeAreaInsets.top
        )
        let topDiffY = parent.contentOffset.y + topOffest
        let scrollViewHeight = parent.bounds.height
        let bottomInset = max(scrollViewHeight - contentSizeHeight - topOffest, parent.safeAreaInsets.bottom)
        // scrollViewBottomOffset: this will go negative when the view is dragged above it's bottom limit
        //  (so like the images was already panned all the way to the bottom but we're dragging more in the up direction)
        //  (imagine this action like the one in the photos library, when dragging more then the bottom it brings the image info up)
        let scrollViewBottomOffset =  (contentSizeHeight - scrollViewHeight + bottomInset) - parent.contentOffset.y
        
        return (topDiffY, scrollViewBottomOffset)
    }
    
    init(
        hostingController: UIHostingController<Content>,
        animating: Binding<Bool>,
        closiness: Binding<Double>,
        scale: Binding<CGFloat>,
        contentOffset: Binding<CGPoint>
    ) {
        _animating = animating
        self.hostingController = hostingController
        hostingController.view.backgroundColor = .clear
        hostingController.view.invalidateIntrinsicContentSize()
        _closiness = closiness
        _currentScale = scale
        _contentOffset = contentOffset
    }
    
    @objc
    func handleZooming() {
        if parent.pinchGestureRecognizer?.state != .ended {
            let scale = parent.zoomScale
            currentScale = scale
            zoomingClosiness = max(100 - (scale * 100), zoomingClosiness) // we'll only reset that when the zoom endsss
            closiness = max(zoomingClosiness, dragClosiness)
        } else {
            animating = isDragging
        }
    }
    
    @objc
    func handlePanning() {
        if isZooming { return }
        let (topDiffY, bottomDiffY) = self.getBounds()
        let bestDiff = min(min(topDiffY, 0), min(bottomDiffY, 0))
        if bestDiff < 0 {
            // we are now below the screenline!
            // time to mess with closiness! diff time!
            dragClosiness = max(0, min(100, -bestDiff))
            closiness = max(zoomingClosiness, dragClosiness)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return hostingController.view
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // if someone wants to animate the clossiness/location of the view based on the velocity
        animating = isDragging
        currentScale = scale
        zoomingClosiness = 0
        if !isAnimating {
            DispatchQueue.main.async {
                self.closiness = max(self.zoomingClosiness, self.dragClosiness)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animating = true
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        animating = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        // if someone wants to animate the clossiness/location of the view based on the velocity
        animating = isZooming
        contentOffset = scrollView.contentOffset
        dragClosiness = 0
        DispatchQueue.main.async {
            self.closiness = max(self.zoomingClosiness, self.dragClosiness)
        }
    }
}
