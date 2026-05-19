//
//  CommunityListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct CommunityListRow<Content2: View>: View {
    typealias Content = CommunityListRowBody<Content2>
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Setting(\.interactionBar_community) var communityActionConfiguration
    
    let community: Community
    let content: Content
    let visitContext: VisitHistory.VisitContext

    init(
        _ community: Community,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        visitContext: VisitHistory.VisitContext = .other,
        @ViewBuilder content: @escaping () -> Content2
    ) {
        self.community = community
        self.content = .init(community, complications: complications, showBlockStatus: showBlockStatus, content: content)
        self.visitContext = visitContext
    }
    
    init(
        _ community: Community,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) where Content2 == EmptyView {
        self.community = community
        self.content = .init(community, complications: complications, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    var body: some View {
        Button {
            navigation.push(.community(community, visitContext: visitContext))
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(.themedSecondaryGroupedBackground)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu(community: community)
        .quickSwipes(community: community, configuration: communityActionConfiguration, leadingBuffer: .standard)
        .popupAnchor()
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment) {
//        ScrollView {
//            ForEach(CommunityMockType.Realistic.allCases) { type in
//                CommunityListRow(
//                    Community2.mock(.realistic(type)),
//                    complications: [.instance],
//                    readout: .subscribers
//                )
//            }
//        }
//        .contentMargins(.horizontal, Constants.main.standardSpacing)
//        .background(.themedGroupedBackground)
//    }
// #endif
