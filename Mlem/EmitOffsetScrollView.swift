//
//  EmitOffsetScrollView.swift
//  Mlem
//
//  Created by Bosco Ho on 2024-01-06.
//

import SwiftUI

struct ScrollViewOffset<Content: View>: View {
    private let axes: Axis.Set
    private let content: () -> Content
    init(
        _ axes: Axis.Set = .vertical,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.content = content
    }
    
    @Namespace private var geometryPreferences

    var body: some View {
        ScrollView(axes) {
//            offsetReader
            content()
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ContentSizePreferenceKey.self,
                                value: geometry.size
                            )
                            .preference(
                                key: FramePreferenceKey.self,
                                value: geometry.frame(in: .named(geometryPreferences))
                            )
                    }
                }
        }
        .coordinateSpace(name: geometryPreferences)
        .preference(
            key: AxesPreferenceKey.self,
            value: axes
        )
//            .padding(.top, -8)
            
//            .onPreferenceChange(ContentSizePreferenceKey.self) { size in
//                print("content size -> \(size)")
//                contentSize = size
//                
//                let size = contentSize
//                let frame = geometry.frame(in: .named(geometryPreferences))
//                let boundaries: [(Bool, Edge.Set)] = [
//                    (frame.minX <= 0, .leading),
//                    (frame.minY <= 0, .top),
//                    (frame.maxX >= size.width, .trailing),
//                    (frame.maxY >= size.height, .bottom)
//                ]
//                let edges = boundaries.compactMap {
//                    $0.0 ? $0.1 : nil
//                }
//                let retVal = Edge.Set(edges)
//                
//                print("edges -> \(retVal)")
//                if retVal.contains(.top) {
//                    print(" -> top")
//                }
//                if retVal.contains(.bottom) {
//                    print(" -> bottom")
//                }
//                if retVal.contains(.leading) {
//                    print(" -> leading")
//                }
//                if retVal.contains(.trailing) {
//                    print(" -> trailing")
//                }
//                self.edges = retVal
//            }
            
//            .preference(
//                key: BouncePreferenceKey.self,
//                value: {
//                    let size = contentSize
//                    let frame = geometry.frame(in: .named(geometryPreferences))
//                    let boundaries: [(Bool, Edge.Set)] = [
//                        (frame.minX <= 0, .leading),
//                        (frame.minY <= 0, .top),
//                        (frame.maxX >= size.width, .trailing),
//                        (frame.maxY >= size.height, .bottom)
//                    ]
//                    let edges = boundaries.compactMap {
//                        $0.0 ? $0.1 : nil
//                    }
//                    return Edge.Set(edges)
//                }()
//            )
    }
    
//    var offsetReader: some View {
//        GeometryReader { geometry in
//            Color.clear
//                .preference(
//                    key: FramePreferenceKey.self,
//                    value: geometry.frame(in: .named(geometryPreferences))
//                )
//        }
//        .frame(height: 0)
//    }
}

struct TabBarVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: Visibility = .automatic
    static func reduce(value: inout Visibility, nextValue: () -> Visibility) {
        let next = nextValue()
        print("reduce \(value) -> \(next)")
//        value = next
    }
}

private struct AxesPreferenceKey: PreferenceKey {
    static var defaultValue: Axis.Set = []
    static func reduce(value: inout Axis.Set, nextValue: () -> Axis.Set) {}
}

private struct ContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private struct BouncePreferenceKey: PreferenceKey {
    static var defaultValue: Edge.Set = []
    static func reduce(value: inout Edge.Set, nextValue: () -> Edge.Set) {}
}

extension View {
    
    func onOffsetChange(
        _ change: @escaping (CGRect, Edge?) -> Void,
        bounce: ((Edge.Set) -> Void)? = nil
    ) -> some View {
        modifier(
            OffsetChangeModifier(
                onChange: change,
                onBounce: bounce
            )
        )
    }
}

private struct OffsetChangeModifier: ViewModifier {
    let onChange: (CGRect, Edge?) -> Void
    let onBounce: ((Edge.Set) -> Void)?
    
    @State private var axes: Axis.Set = []
    @State private var contentSize: CGSize = .zero
    @State private var previousOffset: CGPoint = .zero
    
    private func edges(frame: CGRect) -> Edge.Set {
        let size = contentSize
        let xAxis: [(Bool, Edge.Set)] = [
            (frame.minX >= 0, .leading),
            (frame.maxX <= size.width, .trailing)
        ]
        let yAxis: [(Bool, Edge.Set)] = [
            (frame.minY >= 0, .top),
            /// Not sure why `maxY` reports same value as `minY` here. [2024.01]
            (frame.minY + size.height <= -size.height, .bottom)
        ]
        let boundaries: [(Bool, Edge.Set)] = {
            var retVal: [(Bool, Edge.Set)] = []
            if axes.contains(.horizontal) {
                retVal.append(contentsOf: xAxis)
            }
            if axes.contains(.vertical) {
                retVal.append(contentsOf: yAxis)
            }
            return retVal
        }()
        
        let edges = boundaries.compactMap {
            $0.0 ? $0.1 : nil
        }
        return Edge.Set(edges)
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(AxesPreferenceKey.self) { axes in
                self.axes = axes
            }
            .onPreferenceChange(FramePreferenceKey.self) { frame in
                defer {
                    previousOffset = frame.origin
                }
                
                let edges = self.edges(frame: frame)
                if edges.isEmpty == false {
//                    print("* * * ")
//                    print("content size -> \(contentSize)")
//                    print("edges -> \(frame.origin)")
//                    print("minX - \(frame.minX)")
//                    print("minY - \(frame.minY)")
//                    print("maxX - \(frame.maxX)")
//                    print("maxY - \(frame.maxY)")
//                    
//                    if edges.contains(.top) {
//                        print(" -> top")
//                    }
//                    if edges.contains(.bottom) {
//                        print(" -> bottom")
//                    }
//                    if edges.contains(.leading) {
//                        print(" -> leading")
//                    }
//                    if edges.contains(.trailing) {
//                        print(" -> trailing")
//                    }
                    
                    onBounce?(edges)
                } else {
                    let towardsEdge: Edge? = {
                        if frame.minY > previousOffset.y {
                            return .top
                        } else if frame.minY < previousOffset.y {
                            return .bottom
                        } else {
                            return nil
                        }
                    }()
                    onChange(frame, towardsEdge)
                }
            }
            .onPreferenceChange(ContentSizePreferenceKey.self) { size in
                /// [2024.01] This value is produced inside ScrollView:
                /// - We observe and assign the change here in the view modifier because doing so inside the ScrollView can result in an infinite loop in certain configurations.
                /// - Be careful if you need to shift things around.
                contentSize = size
            }
    }
}

private struct BounceModifier: ViewModifier {
    let onBounce: (Edge.Set) -> Void
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(BouncePreferenceKey.self) { edge in
                onBounce(edge)
            }
    }
}
