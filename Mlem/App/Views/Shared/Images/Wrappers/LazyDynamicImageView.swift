//
//  LazyDynamicImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-23.
//

import Foundation
import SwiftUI

struct LazyDynamicImageView: View {
    @State var activeUrl: URL?
    
    let url: URL?
    let maxSize: CGFloat?
    let showError: Bool
    let cornerRadius: CGFloat
    
    init(
        url: URL?,
        maxSize: CGFloat? = nil,
        showError: Bool = true,
        cornerRadius: CGFloat = Constants.main.mediumItemCornerRadius
    ) {
        self.url = url
        self.maxSize = maxSize
        self.showError = showError
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        DynamicImageView(url: activeUrl)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("Setting activeUrl")
                    activeUrl = url
                }
            }
    }
}
