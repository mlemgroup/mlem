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
    
    let label: () -> AnyView
	
	func body(content: Content) -> some View {
		content
			.opacity(selectedItem == item ? 1 : 0)
			.preference(key: AnotherTabViewItemsPreferencesKey.self, value: [item])
            .preference(key: AnotherTabItemLabelPrefKey.self,
                        value: [item: AnotherTabItemLabelBuilder(id: item, label: { AnyView(label()) })])
	}
}

extension View {
    func anotherTabItem(_ item: AnotherTabItem, selectedItem: AnotherTabItem, label: @escaping () -> AnyView) -> some View {
        modifier(AnotherTabViewItemViewModifier(item: item, selectedItem: selectedItem, label: label))
	}
}
