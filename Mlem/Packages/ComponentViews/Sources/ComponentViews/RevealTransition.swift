//
//  RevealTransition.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-18.
//

import SwiftUI
import Theming

// swiftlint:disable identifier_name

private struct WaveMeasurements {
    let centerY: CGFloat
    let startRadius: CGFloat
    let endRadius: CGFloat
    var curveFactor: CGFloat = 1.1

    init(boundingBoxSize size: CGSize) {
        let width = size.width

        // Prevent division-by-zero
        let height = max(size.height, 1)

        // The center of the wave circle is positioned
        // at some distance above the content.
        let distanceAboveContent = width * curveFactor

        // The wave will first become visible when its radius is equal
        // to the distance between the center and the top of the content.
        self.startRadius = distanceAboveContent

        // The wave will stop being visible when the radius stops intersecting
        // with the content view. The last point that intersects the wave will
        // be the bottom corner of the content view. Use Pythagoras to calculate
        // that distance.

        let half = width / 2
        self.endRadius = (half * half + (distanceAboveContent + height) * (distanceAboveContent + height)).squareRoot()

        // The `RadialGradient` initialiser takes the center point as a fraction
        // of the content size, so normalise it here.
        self.centerY = -distanceAboveContent / height
    }
}

private struct Timer {
    var progress: CGFloat // Value between 0 and 1

    private var wipeFraction: CGFloat = 0.6  // seam reaches the far edge at this fraction of time

    init(progress: CGFloat) {
        self.progress = progress
    }

    var rawSeamProgress: CGFloat {
        min(progress / wipeFraction, 1)
    }

    // A value between 0 and 1 representing how far down the view is currently bounced
    var bounceProgress: CGFloat {
        if progress <= wipeFraction {
            let x = wipeFraction > 0 ? progress / wipeFraction : 1
            return x.eased()
        } else {
            let x = (progress - wipeFraction) / max(1 - wipeFraction, 0.0001)
            return 1 - x.eased()
        }
    }
}

struct RewriteEdge: ViewModifier, Animatable {
    @Environment(\.palette) var palette
    private var timer: Timer
    var bounceAmplitude: CGFloat = 3
    var seamHeight: CGFloat = 48
    var softEdgeHeight: CGFloat = 24

    // Whether this transition is for an incoming or outgoing view
    let isIncoming: Bool

    init(progress: CGFloat, isIncoming: Bool) {
        self.timer = .init(progress: progress)
        self.isIncoming = isIncoming
    }

    var animatableData: CGFloat {
        get { timer.progress }
        set { timer.progress = newValue }
    }

    func body(content: Content) -> some View {

        return content
            .padding(.bottom, bounceAmplitude)
            .mask {
                GeometryReader { geo in
                    Rectangle().fill(
                        radialGradient(
                            geo.size,
                            isIncoming ? revealStops(geo.size) : concealStops(geo.size)
                        )
                    )
                }
            }
            .padding(.bottom, -bounceAmplitude)
            .overlay {
                if isIncoming {
                    glowView
                }
            }
            .offset(y: timer.bounceProgress * self.bounceAmplitude)
    }

    @ViewBuilder
    var glowView: some View {
        let opacity = Double(sin(CGFloat.pi * timer.rawSeamProgress))
        ThemedColor.themedTranslationAccent.resolve(with: palette)
            .mask {
                GeometryReader { geo in
                    Rectangle()
                        .fill(radialGradient(geo.size, glowStops(geo.size)))
                }
            }
            .blendMode(.sourceAtop)
            .opacity(opacity)
    }

    func radialGradient(_ size: CGSize, _ stops: [Gradient.Stop]) -> RadialGradient {
        let r = WaveMeasurements(boundingBoxSize: size)
        return RadialGradient(
            gradient: .init(stops: stops),
            center: .init(x: 0.5, y: r.centerY),
            startRadius: r.startRadius,
            endRadius: r.endRadius
        )
    }

    func glowStops(_ size: CGSize) -> [Gradient.Stop] {
        let unit = self.unit(size)
        let seamHalf = seamHeight / 2 * unit
        let glowHeight = 100 * unit
        let progress = seamProgress(in: size)
        return Self.normalize([
            (progress - seamHalf - glowHeight, .clear),
            (progress - seamHalf - glowHeight / 2, .white)
        ])
    }

    private func unit(_ size: CGSize) -> CGFloat {
        return 1 / max(size.height, 1)
    }

    func revealStops(_ size: CGSize) -> [Gradient.Stop] {
        let unit = self.unit(size)
        let seamHalf = seamHeight / 2 * unit
        let softEdge = softEdgeHeight * unit
        let progress = seamProgress(in: size)
        return Self.normalize([
            (0, .white),
            (progress - seamHalf - softEdge, .white),
            (progress - seamHalf, .clear),
            (1, .clear)
        ])
    }

    func concealStops(_ size: CGSize) -> [Gradient.Stop] {
        let unit = self.unit(size)
        let seamHalf = seamHeight / 2 * unit
        let softEdge = softEdgeHeight * unit
        let progress = seamProgress(in: size)
        return Self.normalize([
            (0, .clear),
            (progress + seamHalf, .clear),
            (progress + seamHalf + softEdge, .white),
            (1, .white)
        ])
    }

    // A value representing the progress of middle point of the seam. This can be thought
    // of as a [0, 1] value, but it actually goes outside the [0, 1] range so that the full
    // thickness of the seam is hidden at the start and end of the animation.
    func seamProgress(in size: CGSize) -> CGFloat {
        // Find the distance between the curved center line of the seam
        // and the edge of the seam. This tells us how much to overshoot on
        // each end.
        let margin = (seamHeight / 2 + softEdgeHeight) * unit(size) + 0.02

        let startValue = -margin
        let endValue = 1 + margin

        let eased = timer.rawSeamProgress.eased()
        return startValue + eased * (endValue - startValue)
    }

    static func normalize(_ pairs: [(CGFloat, Color)]) -> [Gradient.Stop] {
        var last: CGFloat = 0
        return pairs.map { pair in
            let clamped = min(1, max(0, pair.0))

            // SwiftUI requires that the gradient stops are in ascending order. Ensure that
            // this stop is greater than the previous one.
            let newLocation = max(last, clamped)
            last = newLocation

            return .init(color: pair.1, location: newLocation)
        }
    }
}

private extension Numeric {
    func eased() -> Self {
        // https://en.wikipedia.org/wiki/Smoothstep
        self * self * (3 - 2 * self)
    }
}

extension AnyTransition {
    public static var glowReveal: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: RewriteEdge(progress: 0, isIncoming: true),
                identity: RewriteEdge(progress: 1, isIncoming: true)
            ),
            removal: .modifier(
                active: RewriteEdge(progress: 1, isIncoming: false),
                identity: RewriteEdge(progress: 0, isIncoming: false)
            )
        )
    }
}

// swiftlint:enable identifier_name
