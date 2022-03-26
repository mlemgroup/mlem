//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Upvote_Button: View {
    var body: some View {
        Button(action: {
            print("Upvoted")
        }, label: {
            Image(systemName: "arrow.up")
        })
    }
}

struct Upvote_Button_Previews: PreviewProvider {
    static var previews: some View {
        Upvote_Button()
    }
}
