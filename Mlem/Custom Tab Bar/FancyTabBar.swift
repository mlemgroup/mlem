//
//  FancyTabBar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabBar<Selection: FancyTabBarSelection, Content: View>: View {
    typealias NavigationSelection = any FancyTabBarSelection

    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    @AppStorage("hasTranslucentInsets") var hasTranslucentInsets: Bool = true
    
    @Binding private var selection: Selection
    
    private let content: () -> Content
    
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    var dragUpGestureCallback: (() -> Void)?
    
    init(
        selection: Binding<Selection>,
        navigationSelection: Binding<NavigationSelection>,
        dragUpGestureCallback: (() -> Void)? = nil,
        tabItemKeys: [Selection],
        tabItems: [Selection: FancyTabItemLabelBuilder<Selection>],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self._tabItemKeys = .init(initialValue: tabItemKeys)
        self._tabItems = .init(initialValue: tabItems)
        self.content = content
        self.dragUpGestureCallback = dragUpGestureCallback
    }
    
    var body: some View {
        TabView(selection: $selection, content: content)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, alignment: .center) {
                // this VStack/Spacer()/ignoresSafeArea thing prevents the keyboard from pushing the bar up
                VStack {
                    Spacer()
                    tabBar
                }
                .accessibilitySortPriority(-1)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
    }
    
    private func getAccessibilityLabel(tab: Selection) -> String {
        var label = String()
        
        if selection == tab {
            label += "Selected, "
        }
        
        if let tabLabel = tabItems[tab]?.tag.labelText {
            label += "\(tabLabel), "
        }
        
        label += "Tab \(tab.index) of \(tabItems.count.description)"
        
        return label
    }
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                ForEach(tabItemKeys, id: \.hashValue) { key in
                    tabItems[key]?.label()
                        .accessibilityElement(children: .combine)
                        // IDK how to get the "Tab: 1 of 5" VO working natively so here's a janky solution
                        .accessibilityLabel(getAccessibilityLabel(tab: key))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        // high priority to prevent conflict with long press/drag
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    
                                    selection = key
                                }
                        )
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if let callback = dragUpGestureCallback, gesture.translation.height < -50 {
                            callback()
                        }
                    }
            )
            .padding(.bottom, homeButtonExists ? 2.5 : 0)
            .background(hasTranslucentInsets ? nil : Color.systemBackground.ignoresSafeArea(.all))
            .background(.thinMaterial)
        }
        .accessibilityElement(children: .contain)
    }
}
