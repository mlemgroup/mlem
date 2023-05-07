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
                    AsyncImage(url: bannerLink) { banner in
                        banner
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 200, alignment: .center)
                    } placeholder: {
                        ProgressView()
                    }

                }
                else
                {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                [.blue, .cyan, .pink, .purple, .indigo].randomElement()!,
                                [.blue, .cyan, .pink, .purple, .indigo].randomElement()!]),
                            startPoint: [.bottomTrailing, .bottomLeading].randomElement()!, endPoint: [.topTrailing, .topLeading].randomElement()!))
                        .frame(width: UIScreen.main.bounds.width, height: 200, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 10) {
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
            }
        }
    }
}
