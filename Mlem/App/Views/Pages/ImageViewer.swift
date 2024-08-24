//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    let url: URL
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = nil
        self.url = components.url!
    }
    
    var body: some View {
        Text("HI")
//        ZoomableContainer {
//            DynamicImageView(url: url)
//                .padding(Constants.main.standardSpacing)
//        }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButtonView()
                }
            }
            .onAppear {
                print("DEBUGT opened \(NSDate().timeIntervalSince1970)\n")
            }
    }
}
