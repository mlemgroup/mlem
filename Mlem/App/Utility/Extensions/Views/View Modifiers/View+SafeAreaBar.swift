//
//  View+SafeAreaBar.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-04.
//

import SwiftUI

extension View {
    @ViewBuilder
    func safeAreaBar_(edge: VerticalEdge, @ViewBuilder content: () -> some View) -> some View {
        safeAreaBar(edge: edge, content: content)
    }
}
