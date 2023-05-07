//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserView: View
{
    @State var user: User

    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading) {
                if let bannerLink = user.bannerLink
                {
                    GeometryReader { proxy in
                        AsyncImage(url: bannerLink) { banner in
                            banner
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: self.getHeightForHeaderImage(proxy), alignment: .center)
                                .clipped()
                                .offset(x: 0, y: self.getOffsetForHeaderImage(proxy))
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .frame(height: 300)
                }
                else
                {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                [.blue, .cyan, .pink, .purple, .indigo].randomElement()!,
                                [.blue, .cyan, .pink, .purple, .indigo].randomElement()!]),
                            startPoint: [.bottomTrailing, .bottomLeading].randomElement()!, endPoint: [.topTrailing, .topLeading].randomElement()!))
                        .frame(width: UIScreen.main.bounds.width, height: 300, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 10) {
                        
                        if let avatarLink = user.avatarLink
                        {
                            AvatarView(avatarLink: avatarLink, overridenSize: 100)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            if let displayName = user.displayName
                            {
                                Text(displayName)
                            }
                            else
                            {
                                Text(user.name)
                            }
                            
                            Text(user.actorID.absoluteString.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "www.", with: ""))
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat
    {
        geometry.frame(in: .global).minY
    }
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat
    {
        let offset = getScrollOffset(geometry)
        
        if offset > 0
        {
            return -offset
        }
        
        return 0
    }
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat
    {
        let offset = getScrollOffset(geometry)
        
        let imageHeight = geometry.size.height
        
        if offset > 0
        {
            return imageHeight + offset
        }
        
        return imageHeight
    }
}
