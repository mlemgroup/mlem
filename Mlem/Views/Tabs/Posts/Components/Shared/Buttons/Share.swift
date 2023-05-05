//
//  Share.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ShareButton: View
{
    @State var urlToShare: URL

    var body: some View
    {
        Button(action: {
            showShareSheet(URLtoShare: urlToShare)
            print("Shared")
        }, label: {
            Image(systemName: "square.and.arrow.up")
        })
    }
}
