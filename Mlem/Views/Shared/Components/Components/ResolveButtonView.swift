//
//  ResolveButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct ResolveButtonView: View {
    let resolved: Bool
    
    var body: some View {
        Image(systemName: Icons.resolve)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(resolved ? .green : .clear))
            .padding(AppConstants.standardSpacing)
            .contentShape(Rectangle())
    }
}
