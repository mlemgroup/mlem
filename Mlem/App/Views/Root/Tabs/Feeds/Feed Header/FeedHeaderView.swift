//
//  FeedHeaderView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation
import SwiftUI

struct FeedHeaderView: View {
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    let feedDescription: FeedDescription
    let actions: [any Action]
    let subtitle: String
    let showDropdownBadge: Bool
    
    init(
        feedDescription: FeedDescription,
        actions: [any Action] = .init(),
        customSubtitle: String? = nil,
        showDropdownBadge: Bool = false
    ) {
        assert(
            !showDropdownBadge || actions.isEmpty,
            "showDropdownBadge (\(showDropdownBadge)) cannot be true if actions (count: \(actions.count)) is 0!"
        )
        
        self.feedDescription = feedDescription
        self.actions = actions
        self.subtitle = customSubtitle ?? feedDescription.subtitle
        self.showDropdownBadge = showDropdownBadge
    }
    
    var body: some View {
        Menu {
            ForEach(actions, id: \.id) {
                MenuButton(action: $0)
            }
        } label: {
            content
        }
        .buttonStyle(.plain)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: AppConstants.standardSpacing) {
                FeedIconView(feedDescription: feedDescription, size: 44)
                    .padding(.leading, AppConstants.standardSpacing)
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: AppConstants.halfSpacing) {
                        Text(feedDescription.label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .fontWeight(.semibold)
                        
                        if !actions.isEmpty {
                            Image(systemName: Icons.dropdown)
                                .foregroundStyle(palette.secondary)
                                .overlay(alignment: .topTrailing) {
                                    if showDropdownBadge {
                                        Circle()
                                            .frame(width: 6, height: 6)
                                            .foregroundStyle(palette.warning)
                                    }
                                }
                        }
                    }
                    .font(.title2)
                        
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(palette.secondary)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, AppConstants.halfSpacing)
            .padding(.bottom, tilePosts ? 0 : AppConstants.standardSpacing)
            
            if !tilePosts {
                Divider()
            }
        }
    }
}
