//
//  Sidebar Header.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI
import CachedAsyncImage

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
                    CachedAsyncImage(url: bannerUrl) { image in
                        image.centerCropped()
                    } placeholder: {
                        ProgressView()
                    }.frame(height: 200)
                }
            }
            VStack {
                if bannerURL != nil {
                    Spacer().frame(height: 110)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        CommunitySidebarHeaderAvatar(imageUrl: avatarUrl)
                        
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
        VStack {
            CommunitySidebarHeader(title: "TestCommunityWithLongName", subtitle: "@testcommunity@longnamedomain.website",
                                   avatarSubtext: .constant("Created 3 days ago"),
                                   bannerURL: URL(string: "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp"),
                                   avatarUrl: URL(string: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp"),
                                   label1: "Label 1",
                                   label2: "Label 2")
            CommunitySidebarHeader(title: "Test", subtitle: "@test@test.come",
                                   avatarSubtext: .constant("Created 3 days ago"),
                                   bannerURL: URL(string: "https://vlemmy.net/pictrs/image/719b61b3-8d8e-4aec-9f15-17be4a081f97.jpeg?format=webp"),
                                   avatarUrl: URL(string: "https://vlemmy.net/pictrs/image/190f2d6a-ac38-448d-ae9b-f6d751eb6e69.png?format=webp"),
                                   label1: "Label 1",
                                   label2: "Label 2")
            Spacer()
        }
    }
}
