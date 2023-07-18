//
//  AnotherTabView.swift
//
//  Created by Christian on 21.07.22.
//

import SwiftUI

struct AnotherTabView<Content: View>: View {
	@Binding var selection: AnotherTabItem
	
	let content: Content
	
	@State private var items: [AnotherTabItem] = []
    @State private var itemLabels: [AnotherTabItem: AnotherTabItemLabelBuilder] = [:]
	
	init(selection: Binding<AnotherTabItem>, @ViewBuilder content: () -> Content) {
		self._selection = selection
		self.content = content()
	}
	
	var body: some View {
//		VStack(alignment: .center, spacing: 0) {
//			ZStack(alignment: .center) {
//				content
//			}
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//            AnotherTabViewTabBarView(items: items, itemLabels: itemLabels, selectedItem: $selection)
//		}
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    
                    AnotherTabViewTabBarView(items: items, itemLabels: itemLabels, selectedItem: $selection)
                }
            }
        .onPreferenceChange(AnotherTabViewItemsPreferencesKey.self) { newItems in
			self.items = newItems
		}
        .onPreferenceChange(AnotherTabItemLabelPrefKey.self) { newLabels in
            self.itemLabels = newLabels
        }
    }
}
