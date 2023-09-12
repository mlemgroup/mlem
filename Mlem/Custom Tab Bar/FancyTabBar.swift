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
    /// Keeps track of tab "re-selected" state.
    @State private var navigationSelection: NavigationSelection
    @State private var __tempNavigationSelection: Int = -1
    /// We only toggle this to trigger an `onChange` event.
    @State private var __navigationSelectionSignal: Bool = false
    
    private let content: () -> Content
    
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    var dragUpGestureCallback: (() -> Void)?
    
    init(
        selection: Binding<Selection>,
        dragUpGestureCallback: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self._navigationSelection = .init(wrappedValue: selection.wrappedValue)
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
                .accessibilitySortPriority(-1)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
            .environment(\.tabNavigationSelectionHashValue, navigationSelection.hashValue)
            .onPreferenceChange(FancyTabItemPreferenceKey<Selection>.self) {
                tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                tabItems = $0
            }
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
                                    /// Emit "re-selected tab" event, if user tapped on tab that's already selected.
                                    if key.hashValue == selection.hashValue {
                                        /// Set to placeholder value.
                                        /// Previous implementation used `DispatchQueue.asyncAfter` to set this to its actual value, but that caused bugs when performing UI changes on scroll views. [2023.08]
                                        navigationSelection = TabSelection._tabBarNavigation
                                        /// Keep track of new selection for use in `onChange` handler.
                                        __tempNavigationSelection = key.index
                                        /// Trigger `onChange` event.
                                        __navigationSelectionSignal.toggle()
                                    }
                                    
                                    selection = key
                                }
                        )
                }
            }
            /// Workaround for issue where setting `navigationSelection` inside a `Dispatch.asyncAfter` block caused issues when performing programmatic scrolling. [2023.08]
            .onChange(of: __navigationSelectionSignal) { _ in
                if let newTabSelection = TabSelection(index: __tempNavigationSelection) {
                    navigationSelection = newTabSelection
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
