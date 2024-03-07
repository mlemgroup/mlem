//
//  Community Link.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation
import SwiftUI

struct CommunityLinkView: View {
    let community: CommunityModel
    let serverInstanceLocation: ServerInstanceLocation
    let extraText: String?
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system setting
    
    @available(*, deprecated, message: "Provide a CommunityModel rather than an APICommunity.")
    init(
        community: APICommunity,
        serverInstanceLocation: ServerInstanceLocation = .bottom,
        overrideShowAvatar: Bool? = nil,
        extraText: String? = nil
    ) {
        self.init(
            community: CommunityModel(from: community),
            serverInstanceLocation: serverInstanceLocation,
            overrideShowAvatar: overrideShowAvatar,
            extraText: extraText
        )
    }
    
    init(
        community: CommunityModel,
        serverInstanceLocation: ServerInstanceLocation = .bottom,
        overrideShowAvatar: Bool? = nil,
        extraText: String? = nil
    ) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.extraText = extraText
        self.overrideShowAvatar = overrideShowAvatar
    }

    var body: some View {
        // NavigationLink(value: community) {
        NavigationLink(.community(community)) {
            HStack {
                CommunityLabelView(
                    community: community,
                    serverInstanceLocation: serverInstanceLocation,
                    overrideShowAvatar: overrideShowAvatar
                )
                Spacer()
                if let text = extraText {
                    Text(text)
                }
            }
        }
    }
}
