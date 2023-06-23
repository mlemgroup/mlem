//
//  Sidebar Header.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI
import CachedAsyncImage

struct CommunitySidebarHeader : View {
    @State var communityDetails: GetCommunityResponse
    
    var body: some View {
        ZStack(alignment: .top) {
            // Banner
            VStack {
                if let bannerUrl = communityDetails.communityView.community.banner {
                    CachedAsyncImage(url: bannerUrl) { image in
                        image.centerCropped()
                    } placeholder: {
                        ProgressView()
                    }.frame(height: 200)
                }
            }
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 110)
                        CommunitySidebarHeaderAvatar(imageUrl: communityDetails.communityView.community.icon)
                        
                        HStack {
                            Text("Created \(communityDetails.communityView.community.published.getRelativeTime(date: Date.now))")
                        }.foregroundColor(.gray)
                        
                    }.padding([.leading])
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Spacer().frame(height: 170)
                        HStack {
                            CommunitySidebarHeaderLabel("\(communityDetails.communityView.counts.subscribers) Subscribers")
                        }
                        Spacer().frame(height: 20)
                        
                        Text(communityDetails.communityView.community.name).font(.title).bold().lineLimit(1)
                        if let communityHost = communityDetails.communityView.community.actorId.host() {
                            Text("@\(communityDetails.communityView.community.name)@\(communityHost)")
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        else {
                            Text("@\(communityDetails.communityView.community.name)")
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        
                    }.padding([.trailing])
                }
            }
        }
    }
}

