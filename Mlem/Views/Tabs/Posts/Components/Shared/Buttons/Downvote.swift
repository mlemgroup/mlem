//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Downvote_Button: View {
    var body: some View {
        Button(action: {
            print("Downvoted")
        }, label: {
            Image(systemName: "arrow.down")
        })
    }
}

struct Downvote_Button_Previews: PreviewProvider {
    static var previews: some View {
        Downvote_Button()
    }
}
