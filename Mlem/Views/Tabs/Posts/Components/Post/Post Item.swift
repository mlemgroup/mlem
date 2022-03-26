//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Item: View {
    @State var postName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(postName)
                .font(.subheadline)
            Image("Sleeping Lions")
                .resizable()
                .aspectRatio(contentMode: .fill)
            HStack(alignment: .center) {
                Upvote_Button()
                Downvote_Button()
                Share_Button()
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

