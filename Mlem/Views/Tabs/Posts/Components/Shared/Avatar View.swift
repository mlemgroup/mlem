//
//  Avatar View.swift
//  Mlem
//
//  Created by David Bureš on 06.05.2023.
//

import SwiftUI
import CachedAsyncImage

struct AvatarView: View {
    
    @State var avatarLink: URL
    
    var body: some View {
        CachedAsyncImage(url: avatarLink)
        { phase in
            if let avatar = phase.image
            { /// Success
                avatar
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
                    .clipShape(Circle())
            }
            else if phase.error != nil
            { /// Failure
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
                    .clipShape(Circle())
            }
            else
            { /// Placeholder
                ProgressView()
                    .frame(width: 15, height: 15, alignment: .center)
            }
        }
    }
}
