//
//  Sidebar Header.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI

struct CommunitySidebarHeader: View {
    var title: String
    var subtitle: String
    @Binding var avatarSubtext: String
    var avatarSubtextClicked: (() -> Void)?
    
    var bannerURL: URL?
    var avatarUrl: URL?
    
    var label1: String?
    var label2: String?
    
    var body: some View {
        ZStack(alignment: .top) {
            // Banner
            VStack {
                if let bannerUrl = bannerURL {
                    CachedImage(
                        url: bannerUrl,
                        shouldExpand: false,
                        fixedSize: CGSize(width: UIScreen.main.bounds.width, height: 200),
                        contentMode: .fill
                    ).frame(width: UIScreen.main.bounds.width)
                }
            }
            VStack {
                if bannerURL != nil {
                    Spacer().frame(height: 110)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        CommunitySidebarHeaderAvatar(
                            shouldClipAvatar: shouldClipAvatar(url: avatarUrl),
                            imageUrl: avatarUrl
                        )
                        
                        Button {
                            if let callback = avatarSubtextClicked {
                                callback()
                            }
                        } label: {
                            HStack {
                                Text(avatarSubtext).minimumScaleFactor(0.01)
                            }.foregroundColor(.gray)
                        }
                        
                    }.padding([.leading])

                    Spacer()

                    VStack(alignment: .trailing) {
                        Spacer().frame(height: 60)
                        HStack {
                            if let label = label1 {
                                CommunitySidebarHeaderLabel(label)
                            }
                            if let label = label2 {
                                CommunitySidebarHeaderLabel(label)
                            }
                        }.frame(height: 16)
                        Spacer().frame(height: 20)

                        Text(title)
                            .font(.title)
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        Text(subtitle)
                            .font(.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                    }.padding([.trailing])
                }
            }
        }
    }
}

struct SidebarHeaderPreview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                CommunitySidebarHeader(
                    title: "TestCommunityWithLongName",
                    subtitle: "@testcommunity@longnamedomain.website",
                    avatarSubtext: .constant("Created 3 days ago"),
                    bannerURL: URL(string: "https://picsum.photos/seed/mlem-banner/2001/300"),
                    avatarUrl: URL(string: "https://picsum.photos/seed/mlem-avatar/200"),
                    label1: "Label 1",
                    label2: "Label 2"
                )
                Divider()
                CommunitySidebarHeader(
                    title: "Test",
                    subtitle: "@test@test.come",
                    avatarSubtext: .constant("Created 3 days ago"),
                    bannerURL: URL(string: "https://picsum.photos/seed/mlem-banner/200/300"),
                    avatarUrl: URL(string: "https://picsum.photos/seed/mlem-avatar/200"),
                    label1: "Label 1",
                    label2: "Label 2"
                )
                Divider()
                CommunitySidebarHeader(
                    title: "Test With No Avatar",
                    subtitle: "@test@test.come",
                    avatarSubtext: .constant("Created 3 days ago"),
                    bannerURL: URL(string: "https://picsum.photos/seed/mlem-banner/200/300"),
                    avatarUrl: nil,
                    label1: "Label 1",
                    label2: "Label 2"
                )
                Divider()
                CommunitySidebarHeader(
                    title: "Test With No Banner",
                    subtitle: "@test@test.come",
                    avatarSubtext: .constant("Created 3 days ago"),
                    bannerURL: nil,
                    avatarUrl: URL(string: "https://picsum.photos/seed/mlem-avatar/200"),
                    label1: "Label 1",
                    label2: "Label 2"
                )
                Divider()
                CommunitySidebarHeader(
                    title: "Test With No Banner or Avatar",
                    subtitle: "@test@test.come",
                    avatarSubtext: .constant("Created 3 days ago"),
                    bannerURL: nil,
                    avatarUrl: nil,
                    label1: "Label 1",
                    label2: "Label 2"
                )
                Spacer()
            }
        }
    }
}
