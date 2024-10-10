//
//  CommunityListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import MlemMiddleware
import SwiftUI

struct CommunityListRow<Content2: View>: View {
    typealias Content = CommunityListRowBody<Content2>
    
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    let community: any Community
    let content: Content

    init(
        _ community: any Community,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        @ViewBuilder content: @escaping () -> Content2
    ) {
        self.community = community
        self.content = .init(community, complications: complications, showBlockStatus: showBlockStatus, content: content)
    }
    
    init(
        _ community: any Community,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil
    ) where Content2 == EmptyView {
        self.community = community
        self.content = .init(community, complications: complications, showBlockStatus: showBlockStatus, readout: readout)
    }
    
    var body: some View {
        Button {
            navigation.push(.community(community))
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(palette.secondaryGroupedBackground)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { community.menuActions(navigation: navigation) }
        .quickSwipes(community.swipeActions(behavior: .standard))
    }
}
