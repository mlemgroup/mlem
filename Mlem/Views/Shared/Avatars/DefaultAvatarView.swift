//
//  DefaultAvatarView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation
import SwiftUI

struct DefaultAvatarView: View {
    let avatarType: AvatarType
    
    var body: some View {
        Image(systemName: avatarType.iconNameFill)
            .resizable()
            .scaledToFill()
            .background(.white)
            .foregroundStyle(Color.gray.gradient)
    }
}
