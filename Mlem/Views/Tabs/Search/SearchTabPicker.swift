//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

enum SearchTab: String, CaseIterable {
    case topResults, communities, users
    
    var label: String {
        switch self {
        case .topResults:
            return "Top Results"
        default:
            return rawValue.capitalized
        }
    }
    
    static var homePageCases: [SearchTab] = [.communities, .users]
}

struct SearchTabPicker: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var selected: SearchTab
    var tabs: [SearchTab] = SearchTab.allCases
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { type in
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
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        )
                        .animation(.spring(response: 0.15, dampingFraction: 0.825), value: selected)
                }
                    .buttonStyle(EmptyButtonStyle())
            }
        }
    }
}
