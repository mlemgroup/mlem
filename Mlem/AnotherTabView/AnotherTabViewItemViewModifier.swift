//
//  AnotherTabViewItemViewModifier.swift
//
//  Created by Christian on 21.07.22.
//

import Foundation
import SwiftUI

struct AnotherTabViewItemViewModifier: ViewModifier {
	let item: AnotherTabItem
	
	let selectedItem: AnotherTabItem
	
	func body(content: Content) -> some View {
		content
			.opacity(selectedItem == item ? 1 : 0)
			.preference(key: AnotherTabViewItemsPreferencesKey.self, value: [item])
	}
}

extension View {
	func anotherTabItem(_ item: AnotherTabItem, selectedItem: AnotherTabItem) -> some View {
		modifier(AnotherTabViewItemViewModifier(item: item, selectedItem: selectedItem))
	}
}
