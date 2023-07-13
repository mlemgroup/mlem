//
//  Contributors View.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import SwiftUI
import NukeUI

struct ContributorsView: View {

    @State var contributor: Contributor

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            LazyImage(url: contributor.avatarLink) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else if state.error != nil {
                    Color.red
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)
                        .overlay { Image(systemName: "exclamationmark.triangle") }
                        .clipShape(Circle())
                } else {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            }

            VStack(alignment: .center, spacing: 5) {
                Text(contributor.name)
                    .bold()
                Text(contributor.reasonForAcknowledgement)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}
