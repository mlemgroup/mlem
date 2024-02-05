//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

struct BubblePicker<Value: Identifiable & Equatable & Hashable>: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var selected: Value
    let tabs: [Value]
    @ViewBuilder let labelBuilder: (Value) -> any View
    
    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        @ViewBuilder labelBuilder: @escaping (Value) -> any View
    ) {
        self._selected = selected
        self.tabs = tabs
        self.labelBuilder = labelBuilder
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
                HStack(spacing: -2*AppConstants.postAndCommentSpacing) {
                    ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                        Button {
                            selected = tab
                            hapticManager.play(haptic: .gentleInfo, priority: .low)
                            withAnimation {
                                proxy.scrollTo(index)
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
                                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: selected)
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(EmptyButtonStyle())
                        .padding(.horizontal, AppConstants.postAndCommentSpacing)
                        .id(index)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
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
