//
//  Avatar View.swift
//  Mlem
//
//  Created by David Bureš on 06.05.2023.
//

import SwiftUI
import CachedAsyncImage

struct AvatarView: View {

    let avatarLink: URL
    var overridenSize: CGFloat = 15

    var body: some View {
        CachedAsyncImage(url: avatarLink, urlCache: AppConstants.urlCache) { phase in
            if let avatar = phase.image { /// Success
                avatar
                    .resizable()
                    .frame(width: overridenSize, height: overridenSize, alignment: .center)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color .secondarySystemBackground, style: StrokeStyle(lineWidth: 2))
                    )
            } else if phase.error != nil { /// Failure
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: overridenSize, height: overridenSize, alignment: .center)
                    .clipShape(Circle())
            } else { /// Placeholder
                ProgressView()
                    .frame(width: overridenSize, height: overridenSize, alignment: .center)
            }
        }
    }
}
