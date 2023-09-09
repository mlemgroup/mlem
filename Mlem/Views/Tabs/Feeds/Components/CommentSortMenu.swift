//
//  CommentSortMenu.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023
//

import SwiftUI
import Dependencies

struct CommentSortMenu: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @Binding var isPresented: Bool
    @Binding var selected: CommentSortType

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                sortOption(.hot)
                sortOption(.new)
                sortOption(.old)
                sortOption(.top)
            }
            Spacer()
        }
        .padding(20)
        .presentationDetents([.height(300)])
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    @ViewBuilder
    private func sortOption(_ sortType: CommentSortType) -> some View {
        Button {
            isPresented = false
            selected = sortType
        } label: {
            Label(sortType.label, systemImage: sortType.iconName)
        }
        .buttonStyle(SortMenuButtonStyle(isSelected: sortType == selected))
        .accessibilityLabel(sortType.description)
        .accessibilityHint("Double-tap to select")
    }
}
