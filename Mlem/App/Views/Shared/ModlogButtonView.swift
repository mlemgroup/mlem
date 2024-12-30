//
//  ModlogButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogButtonView: View {
    @Environment(Palette.self) private var palette
    
    let community: (any Community)?
    
    var body: some View {
        NavigationLink(.modlog(community: community)) {
            FormChevron {
                Label {
                    Text("Modlog")
                } icon: {
                    Image(systemName: Icons.modlog)
                        .foregroundStyle(palette.secondary)
                }
            }
            .padding(.vertical, Constants.main.halfSpacing)
            .padding(.horizontal, 15)
            .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .buttonStyle(.empty)
    }
}
