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
            VStack(spacing: 0) {
                ZStack { content() }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                HStack {
                    ForEach(tabItemKeys, id: \.hashValue) { key in
                        Group {
                            if selection == key {
                                tabItems[key]?.labelActive()
                            } else {
                                tabItems[key]?.label()
                                
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { selection = key }
                    }
                }
                .background(.regularMaterial)
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
