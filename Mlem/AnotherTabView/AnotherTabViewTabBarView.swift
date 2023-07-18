//
//  AnotherTabViewTabBarView.swift
//
//  Created by Christian on 21.07.22.
//

import SwiftUI

struct AnotherTabViewTabBarView: View {
	static let vPadding: CGFloat = 16
	static let fontSize: CGFloat = 18
	
	let items: [AnotherTabItem]
    let itemLabels: [AnotherTabItem: AnotherTabItemLabelBuilder]
	
	@Binding var selectedItem: AnotherTabItem
	
	@State private var barHeight: CGFloat = 0
	
    var body: some View {
        VStack(spacing: -4) {
            Divider()

            HStack(alignment: .center, spacing: 20) {
                Spacer()

                ForEach(items, id: \.self) { item in
                    tabItemView(item)
                        .id(item.rawValue)
                        .onTapGesture {
                            switchTo(item)
                        }
                }

                Spacer()
            }
        }
		.onPreferenceChange(AnotherTabViewTabBarViewHeightPrefKey.self, perform: { value in
			barHeight = value
		})
		// .frame(height: barHeight)
        .background(.regularMaterial)
		.ignoresSafeArea(edges: .horizontal)
		.ignoresSafeArea(edges: .bottom)
    }

	func switchTo(_ item: AnotherTabItem) {
		selectedItem = item
	}
	
	func tabItemView(_ item: AnotherTabItem) -> some View {
		let barHeight = (2*Self.vPadding) + Self.fontSize
	
        return itemLabels[item]?.label()
        
//		return Text(item.title)
//			.padding(.vertical, Self.vPadding)
//			.foregroundColor(foregroundColorFor(item))
//			.font(.system(size: Self.fontSize, weight: .regular, design: .rounded))
//			.preference(key: AnotherTabViewTabBarViewHeightPrefKey.self, value: barHeight)
	}
	
	func foregroundColorFor(_ item: AnotherTabItem) -> Color {
		if item == selectedItem {
			return .accentColor
		}
		
		return Color(hue: 0.0, saturation: 0.0, brightness: 0.561, opacity: 1.0)
	}
}

struct AnotherTabViewTabBarViewHeightPrefKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}
