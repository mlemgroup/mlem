//
//  Website Indicator View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-23.
//

import Foundation
import SwiftUI

struct WebsiteIndicatorView: View {
    var body: some View {
        Circle()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                Image(systemName: Icons.browser)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .fontWeight(.ultraLight)
            }
    }
}
