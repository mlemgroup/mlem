//
//  ExpectedMediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-22.
//

import MlemMiddleware
import SwiftUI
import Foundation

struct ExpectedMedia: View {
    let url: ExpectedValue<URL?>
    
    var body: some View {
        ZStack {
            if let resolved = url.value as? URL {
                MediaView.largeImage(url: resolved, shouldBlur: false)
                    .transition(.scale)
            }
        }
        .animation(.snappy, value: url.value == nil)
    }
}
