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
    @State private var navigationSelection: NavigationSelection = TabSelection._tabBarNavigation
    @State private var __tempNavigationSelection: Int = -1
    @State private var __tempToggle: Bool = false
    
    private let content: () -> Content
    
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    var dragUpGestureCallback: (() -> Void)?
    
    init(selection: Binding<Selection>,
         dragUpGestureCallback: (() -> Void)? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
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
                self.tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                self.tabItems = $0
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
    
    /// This gesture drives the tab bar navigation behaviour (e.g. tap to go back).
    private let tapOnceToNavigate = TapGesture(count: 1)
    /// This gesture ensures that `tapOnceToNavigate` gesture only ever fires once, no matter the tap count. For example, user may accidentally tap more than once, in which case we only ever want to register that as a single "tapped once" event, after tapping ends.
    ///
    /// Since the `count` for this gesture is ridiculously high, it is *guaranteed* (famous last words) to fail. On failure, `tapOnceToNavigate` will succeed.
    private let tapToNavigateMaxCount = TapGesture(count: 999999)
        
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
                            tapToNavigateMaxCount
                                .onEnded {
                                    print("uhhh, user hit max tap count, this is really not supposed to happen.")
                                }
                                .exclusively(
                                    before: tapOnceToNavigate
                                        .onEnded {
                                            print("tapped once")
                                            /// If user tapped on tab that's already selected.
                                            if key.hashValue == selection.hashValue {
                                                navigationSelection = TabSelection._tabBarNavigation
                                                
                                                __tempNavigationSelection = key.index
                                                __tempToggle.toggle()
                                            }
                                            
                                            selection = key
                                        }
                                )
                        )
                }
            }
            .onChange(of: self.__tempToggle) { _ in
                navigationSelection = TabSelection(index: __tempNavigationSelection)!
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
