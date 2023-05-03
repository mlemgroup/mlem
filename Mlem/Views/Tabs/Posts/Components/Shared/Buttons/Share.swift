//
//  Share.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Share_Button: View
{
    let urlToShare: String

    var body: some View
    {
        Button(action: {
            showShareSheet(URLasString: urlToShare)
            print("Shared")
        }, label: {
            Image(systemName: "square.and.arrow.up")
        })
    }
}
