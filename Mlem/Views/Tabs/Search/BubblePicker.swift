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
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { type in
                    Button {
                        selected = type
                        hapticManager.play(haptic: .gentleInfo, priority: .low)
                    } label: {
                        AnyView(labelBuilder(type))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .foregroundStyle(selected == type ? .white : .primary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .background(
                                Group {
                                    if selected == type {
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
                }
            }
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    BubblePicker(
        SearchTab.allCases,
        selected: .constant(.communities)
    ) {
        Text($0.label)
    }
}
