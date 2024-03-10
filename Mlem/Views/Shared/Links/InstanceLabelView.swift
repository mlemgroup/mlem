//
//  InstanceLabelView.swift
//  Mlem
//
//  Created by Sjmarf on 10/03/2024.
//

import Foundation
import SwiftUI

struct InstanceLabelView: View {
    let instance: InstanceModel
    
    var body: some View {
        HStack(spacing: AppConstants.largeAvatarSpacing) {
            AvatarView(instance: instance, avatarSize: AppConstants.largeAvatarSize)
                .accessibilityHidden(true)
            
            Text(instance.name)
                .dynamicTypeSize(.small ... .accessibility1)
                .font(.footnote)
                .bold()
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
