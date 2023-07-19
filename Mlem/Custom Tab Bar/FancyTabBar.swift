//
//  FancyTabBar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabBar<Selection: FancyTabBarSelection, Content: View>: View {
    
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
            VStack(spacing: 0) {
                ZStack { content() }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                Group {
                    Divider()
                    
                    HStack(spacing: 0) {
                        ForEach(tabItemKeys, id: \.hashValue) { key in
                            tabItems[key]?.label()
                                .accessibilityElement(children: .combine)
                            // IDK how to get the "Tab: 1 of 5" VO working--hopefully there's a nice clean way, if not we can add an 'index: Int' field to the FancyTabBarSelection protocol and use that 🙃
                                .accessibilityLabel("Tab of \(tabItems.count.description)")
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.25)) {
                                        selection = key
                                    }
                                }
                        }
                    }
                    .background(.regularMaterial)
                }
                .accessibilityElement(children: .contain)
            }
            .onPreferenceChange(FancyTabItemPreferenceKey<Selection>.self) {
                self.tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                self.tabItems = $0
            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
    }
}
