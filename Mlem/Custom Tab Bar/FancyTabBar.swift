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
    
    @Binding private var selection: Selection
    @Binding private var navigationSelection: NavigationSelection
    
    private let content: () -> Content
    
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    var dragUpGestureCallback: (() -> Void)?
    
    init(selection: Binding<Selection>,
         navigationSelection: Binding<NavigationSelection>,
         dragUpGestureCallback: (() -> Void)? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self._navigationSelection = navigationSelection
        self.content = content
        self.dragUpGestureCallback = dragUpGestureCallback
    }
    
    var body: some View {
        ZStack(content: content)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, alignment: .center) {
                // this VStack/Spacer()/ignoresSafeArea thing prevents the keyboard from pushing the bar up
                VStack {
                    Spacer()
                    tabBar
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
            .environment(\.tabNavigationSelectionHashValue, navigationSelection.hashValue)
            .onPreferenceChange(FancyTabItemPreferenceKey<Selection>.self) {
                self.tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                self.tabItems = $0
            }
    }
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                ForEach(tabItemKeys, id: \.hashValue) { key in
                    tabItems[key]?.label()
                        .accessibilityElement(children: .combine)
                    // IDK how to get the "Tab: 1 of 5" VO working natively so here's a janky solution
                        .accessibilityLabel("Tab \(key.index) of \(tabItems.count.description)")
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    // high priority to prevent conflict with long press/drag
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    /// If user tapped on tab that's already selected.
                                    if key.hashValue == selection.hashValue {
                                        navigationSelection = TabSelection._tabBarNavigation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            self.navigationSelection = key
                                        }
                                    }
                                    
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
            .background(.thinMaterial)
        }
        .accessibilityElement(children: .contain)    }
}
