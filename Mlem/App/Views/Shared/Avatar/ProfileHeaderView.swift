//
//  ProfileHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import SwiftUI

struct ProfileHeaderView: View {
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    
    var profilable: (any Profile1Providing)?
    var type: AvatarType
    
    init<T: Profile1Providing>(_ profilable: T?) {
        self.profilable = profilable
        self.type = T.avatarType
    }
    
    init(_ profilable: any Profile1Providing) {
        self.profilable = profilable
        self.type = Swift.type(of: profilable).avatarType
    }
    
    init(_ profilable: (any Profile1Providing)?, type: AvatarType) {
        self.profilable = profilable
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: AppConstants.standardSpacing) {
            AvatarBannerView(profilable, type: type)
            Button {
                (profilable as? any CommunityOrPersonStub)?.copyFullNameWithPrefix()
            } label: {
                VStack(spacing: AppConstants.halfSpacing) {
                    Text(profilable?.displayName_ ?? profilable?.name ?? "")
                        .font(.title)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(palette.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
    
    var subtitle: String {
        (profilable as? any CommunityOrPersonStub)?.fullNameWithPrefix ?? profilable?.actorId.host() ?? ""
    }
}
