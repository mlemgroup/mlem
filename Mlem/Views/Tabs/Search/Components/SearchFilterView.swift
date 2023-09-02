//
//  SearchFilterView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct SearchFilterView: View {
    
    @EnvironmentObject var searchModel: SearchModel
    
    let filter: SearchFilter
    let active: Bool
    let shouldAnimate: Bool
    
    func toggle() {
        if active {
            searchModel.removeFilter(filter)
            
        } else {
            searchModel.addFilter(filter)
            searchModel.input = ""
        }
    }
    
    var body: some View {
        Button {
            if shouldAnimate {
                withAnimation { toggle() }
            } else {
                toggle()
            }
        } label: {
            HStack {
                HStack {
                    if case .community(let community) = filter {
                        CommunityAvatarView(
                            community: community.community,
                            avatarSize: 16,
                            lineColor: active ? Color.white : Color.secondary
                        )
                    }
                    else if case .user(let user) = filter {
                        UserAvatarView(
                            user: user.person,
                            avatarSize: 16,
                            lineColor: active ? Color.white : Color.secondary
                        )
                    } else {
                        Image(systemName: filter.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 16)
                            .foregroundStyle(active ? .white : .primary)
                    }
                    if active {
                        Text(filter.label)
                    } else {
                        SearchResultTextView(filter.label, highlight: searchModel.input)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .foregroundStyle(active ? .white : .primary)
            }
            .background(
                Group {
                    if active {
                        Capsule()
                            .fill(.blue)
                    } else {
                        Capsule()
                            .fill(Color(.systemGroupedBackground))
                            .overlay {
                                Capsule()
                                    .stroke(.tertiary, lineWidth: 1)
                            }
                    }
                }
            )
        }
        .zIndex(1)
        .buttonStyle(.plain)
    }
}
