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
	
	init(selection: Binding<AnotherTabItem>, @ViewBuilder content: () -> Content) {
		self._selection = selection
		self.content = content()
	}
	
	var body: some View {
		VStack(alignment: .center, spacing: 0) {
			ZStack(alignment: .center) {
				content
			}
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AnotherTabViewTabBarView(items: items, selectedItem: $selection)
		}
        .onPreferenceChange(AnotherTabViewItemsPreferencesKey.self) { newItems in
			self.items = newItems
		}
    }
}
