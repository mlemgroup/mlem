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
    @State var isShowingButtonText: Bool
    @State var customText: String?

    var body: some View
    {
        Button {
            showShareSheet(URLtoShare: urlToShare)
            print("Shared")
        } label: {
            if !isShowingButtonText {
                Image(systemName: "square.and.arrow.up")
            }
            else {
                if let customText {
                    Label(customText, systemImage: "square.and.arrow.up")
                }
                else {
                    Label("Share…", systemImage: "square.and.arrow.up")
                }
            }
        }
        .foregroundColor(.primary)
    }
}
