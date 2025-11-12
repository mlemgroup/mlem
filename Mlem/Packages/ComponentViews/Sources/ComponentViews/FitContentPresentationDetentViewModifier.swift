//
//  File.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-06-15.
//

import SwiftUI

private struct FitContentPresentationDetentViewModifier: ViewModifier {
    let otherDetents: Set<PresentationDetent>
    var selection: Binding<PresentationDetent>?
    
    @State private var sheetContentHeight: CGFloat = SheetHeightKey.defaultValue
    
    func body(content: Content) -> some View {
        if let selection {
            innerBody(content: content)
                .presentationDetents(
                    otherDetents.union([.height(sheetContentHeight)]),
                    selection: selection
                )
        } else {
            innerBody(content: content)
                .presentationDetents(otherDetents.union([.height(sheetContentHeight)]))
        }
    }

    func innerBody(content: Content) -> some View {
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
    }
}

public extension View {
    @ViewBuilder
    func presentationDetentFitsContent(
        fitDetentEnabled: Bool = true,
        _ otherDetents: Set<PresentationDetent> = []
    ) -> some View {
        if fitDetentEnabled {
            modifier(FitContentPresentationDetentViewModifier(otherDetents: otherDetents))
        } else {
            presentationDetents(otherDetents)
        }
    }

    @ViewBuilder
    func presentationDetentFitsContent(
        fitDetentEnabled: Bool = true,
        _ otherDetents: Set<PresentationDetent> = [],
        selection: Binding<PresentationDetent>
    ) -> some View {
        if fitDetentEnabled {
            modifier(FitContentPresentationDetentViewModifier(otherDetents: otherDetents, selection: selection))
        } else {
            presentationDetents(otherDetents, selection: selection)
        }
    }
}

private struct SheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 500
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
