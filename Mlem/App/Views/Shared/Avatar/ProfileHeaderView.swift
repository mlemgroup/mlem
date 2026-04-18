//
//  ProfileHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import Icons
import MlemMiddleware
import SwiftUI

struct ProfileHeaderView: View {
    @Environment(AppState.self) var appState
    
    var profilable: (any ProfileProviding)?
    var fallback: MediaView.Fallback
    var blockedOverride: Bool?
    
    init<T: ProfileProviding>(_ profilable: T?, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.fallback = T.avatarFallback
        self.blockedOverride = blockedOverride
    }
    
    init(_ profilable: any ProfileProviding, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.fallback = Swift.type(of: profilable).avatarFallback
        self.blockedOverride = blockedOverride
    }
    
    init(_ profilable: (any ProfileProviding)?, fallback: MediaView.Fallback, blockedOverride: Bool? = nil) {
        self.profilable = profilable
        self.fallback = fallback
        self.blockedOverride = blockedOverride
    }
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            AvatarBannerView(profilable, fallback: fallback)
            Button {
                (profilable as? any CommunityOrPerson)?.copyFullNameWithPrefix()
            } label: {
                VStack(spacing: Constants.main.halfSpacing) {
                    HStack {
                        Text(profilable?.displayName ?? "")
                            .foregroundStyle(.themedPrimary)
                        if blockedOverride ?? profilable?.blocked.realizedValue ?? false {
                            Image(icon: .general.hide)
                                .foregroundStyle(.themedSecondary)
                        }
                    }
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.themedSecondary)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
    
    var subtitle: String {
        if let instance = profilable as? Instance {
            return "\(instance.host) • \(instance.software.value?.label ?? "")"
        }
        return (profilable as? any CommunityOrPerson)?.fullNameWithPrefix ?? profilable?.host ?? ""
    }
}
