//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

struct SearchTabPicker: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var selected: SearchTab
    
    // This ensures that the bubble is layered below the text at all times. There may be cleaner way to do this?
    
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SearchTab.allCases, id: \.self) { type in
                Button {
                    selected = type
                    hapticManager.play(haptic: .gentleInfo, priority: .low)
                } label: {
                    Text(type.label)
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
                                        // .matchedGeometryEffect(id: "bubble", in: animation)
                                        // This prevents matchedGeometryEffect from changing the opacity
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        )
                }
                    .buttonStyle(EmptyButtonStyle())
            }
        }
        .animation(.spring(duration: 0.2, bounce: 0.4), value: selected)
    }
}
