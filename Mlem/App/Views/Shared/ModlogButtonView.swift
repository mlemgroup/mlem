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
    
    init(community: any Community) {
        self.target = .community(.init(community))
    }
    
    init(instance: any Instance) {
        self.target = .instance(.init(wrappedValue: instance))
    }
    
    var body: some View {
        NavigationLink(.modlog(target)) {
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
