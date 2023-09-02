//
//  Community Link.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation
import SwiftUI

private let clipOptOut = ["beehaw.org"]

func shouldClipAvatar(community: APICommunity) -> Bool {
    guard let hostString = community.actorId.host else {
        return true
    }
    
    return !clipOptOut.contains(hostString)
}

func shouldClipAvatar(url: URL?) -> Bool {
    guard let hostString = url?.host else {
        return true
    }
    
    return !clipOptOut.contains(hostString)
}

struct CommunityLinkView: View {
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    let extraText: String?
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system setting
    
    init(
        community: APICommunity,
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
        NavigationLink(value: community) {
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
