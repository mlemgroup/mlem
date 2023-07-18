//
//  FancyTabBar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabBar<Selection: Hashable, Content: View>: View {
    
    @Binding private var selection: Selection
    private let content: () -> Content
    
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    init(selection: Binding<Selection>,
         @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        ForEach(tabItemKeys, id: \.hashValue) { key in
                            tabItems[key]?.label()
                                .contentShape(Rectangle())
                                .onTapGesture { selection = key }
                        }
//                        Text("wheee")
//
//                        Text("whooo")
                    }
                }
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
            .onPreferenceChange(FancyTabItemPreferenceKey<Selection>.self) {
                self.tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                // self.tabItems = self.tabItems.reduce($0)
                self.tabItems = $0
                // self.tabItems.merge($0, uniquingKeysWith: { $1 })
            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
    }
}
