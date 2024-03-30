//
//  PurgeButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct PurgeButtonView: View {
    var body: some View {
        Image(systemName: Icons.purge)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .padding(AppConstants.standardSpacing)
            .contentShape(Rectangle())
    }
}
