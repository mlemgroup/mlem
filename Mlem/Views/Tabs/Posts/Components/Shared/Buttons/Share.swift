//
//  Share.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Share_Button: View {
    var body: some View {
        Button(action: {
            print("Shared")
        }, label: {
            Image(systemName: "square.and.arrow.up")
        })
    }
}

struct Share_Button_Previews: PreviewProvider {
    static var previews: some View {
        Share_Button()
    }
}
