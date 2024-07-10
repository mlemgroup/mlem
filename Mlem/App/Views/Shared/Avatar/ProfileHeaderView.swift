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
    var blockedOverride: Bool?
    
    init<T: Profile1Providing>(_ profilable: T?, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.type = T.avatarType
        self.blockedOverride = blockedOverride
    }
    
    init(_ profilable: any Profile1Providing, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.type = Swift.type(of: profilable).avatarType
        self.blockedOverride = blockedOverride
    }
    
    init(_ profilable: (any Profile1Providing)?, type: AvatarType, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.type = type
        self.blockedOverride = blockedOverride
    }
    
    var body: some View {
        VStack(spacing: AppConstants.standardSpacing) {
            AvatarBannerView(profilable, type: type)
            Button {
                (profilable as? any CommunityOrPersonStub)?.copyFullNameWithPrefix()
            } label: {
                VStack(spacing: AppConstants.halfSpacing) {
                    HStack {
                        Text(profilable?.displayName_ ?? profilable?.name ?? "")
                        if blockedOverride ?? profilable?.blocked ?? false {
                            Image(systemName: Icons.hide)
                                .foregroundStyle(palette.secondary)
                        }
                    }
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
        if let instance = profilable as? any Instance3Providing {
            return "\(instance.host ?? "") • \(instance.version)"
        }
        return (profilable as? any CommunityOrPersonStub)?.fullNameWithPrefix ?? profilable?.host ?? ""
    }
}
