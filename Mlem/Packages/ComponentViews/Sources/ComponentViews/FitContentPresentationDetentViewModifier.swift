//
//  File.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-06-15.
//

import SwiftUI

private struct FitContentPresentationDetentViewModifier: ViewModifier {
    let otherDetents: Set<PresentationDetent>
    
    @State private var sheetContentHeight: CGFloat = SheetHeightKey.defaultValue
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SheetHeightKey.self,
                        value: proxy.size.height
                    )
                }
            }
            .onPreferenceChange(SheetHeightKey.self) { sheetContentHeight = $0 }
            .presentationDetents(otherDetents.union([.height(sheetContentHeight)]))
    }
}

public extension View {
    func presentationDetentFitsContent(
        _ otherDetents: Set<PresentationDetent> = []
    ) -> some View {
        modifier(FitContentPresentationDetentViewModifier(otherDetents: otherDetents))
    }
}

private struct SheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 500
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
