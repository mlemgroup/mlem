//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import Dependencies
import SwiftUI

enum DividerPlacement {
    case top, bottom
}

struct BubblePicker<Value: Identifiable & Equatable & Hashable>: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var selected: Value
    let tabs: [Value]
    let dividers: [DividerPlacement]
    @ViewBuilder let labelBuilder: (Value) -> any View
    
    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        withDividers: [DividerPlacement] = .init(),
        @ViewBuilder labelBuilder: @escaping (Value) -> any View
    ) {
        self._selected = selected
        self.tabs = tabs
        self.dividers = withDividers
        self.labelBuilder = labelBuilder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dividers.contains(.top) {
                Divider()
            }
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
                    HStack(spacing: -AppConstants.doubleSpacing) {
                        ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                            bubbleButton(index: index, tab: tab, scrollProxy: scrollProxy)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            if dividers.contains(.bottom) {
                Divider()
            }
        }
    }
    
    @ViewBuilder
    func bubbleButton(index: Int, tab: Value, scrollProxy: ScrollViewProxy) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, priority: .low)
            withAnimation {
                scrollProxy.scrollTo(index)
            }
        } label: {
            AnyView(labelBuilder(tab))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .foregroundStyle(selected == tab ? .white : .primary)
                .font(.subheadline)
                .fontWeight(.semibold)
                .background(
                    Group {
                        if selected == tab {
                            Capsule()
                                .fill(.blue)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                )
                .padding(AppConstants.standardSpacing)
                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: selected)
                .contentShape(Rectangle())
        }
        .buttonStyle(EmptyButtonStyle())
        .id(index)
    }
}

#Preview {
    BubblePicker(
        InstanceViewTab.allCases,
        selected: .constant(.about)
    ) {
        Text($0.label)
    }
}
