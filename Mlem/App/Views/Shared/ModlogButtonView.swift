//
//  ModlogButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct ModlogButtonView: View {
    let target: ModlogView.InitialTarget
    
    init(community: Community) {
        self.target = .community(community)
    }
    
    init(instance: Instance) {
        self.target = .instance(instance)
    }
    
    var body: some View {
        NavigationLink(.modlog(target, targetPerson: nil, moderatorPerson: nil)) {
            FormChevron {
                Label {
                    Text("Modlog")
                } icon: {
                    Image(icon: .lemmy.modlog)
                        .foregroundStyle(.themedSecondary)
                }
            }
            .padding(.vertical, Constants.main.halfSpacing)
            .padding(.horizontal, 15)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .buttonStyle(.empty)
    }
}
