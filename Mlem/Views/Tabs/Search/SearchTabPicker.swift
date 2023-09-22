//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

struct SearchTabPicker: View {
    @Binding var selected: SearchTab
    
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SearchTab.allCases, id: \.self) { type in
                Button {
                    selected = type
                } label: {
                    Text(type.label)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .foregroundStyle(selected == type ? .white : .primary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .zIndex(2)
                        .background(
                            Group {
                                if selected == type {
                                    Capsule()
                                        .fill(.blue)
                                        .matchedGeometryEffect(id: "bubble", in: animation)
                                        // This prevents matchedGeometryEffect from changing the opacity
                                        .transition(.scale(scale: 1))
                                }
                            }
                        )
                }
                    .buttonStyle(EmptyButtonStyle())
            }
        }
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
