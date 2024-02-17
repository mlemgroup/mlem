//
//  AppRoutes.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

/// Possible routes for navigation links in `Mlem.app`.
///
/// For simple (i.e. linear) navigation flows, you may wish to define a separate set of routes. For example, see `OnboardingRoutes`.
///


enum AppRoute: Routable {
    
    case instance(any InstanceStubProviding)
    case community(any CommunityStubProviding)
    case person(any PersonStubProviding, communityContext: (any Community)? = nil)
    case post(any PostStubProviding)
    
    // MARK: - Settings

    case settings(SettingsPage)
    case aboutSettings(AboutSettingsPage)
    case appearanceSettings(AppearanceSettingsPage)
    case commentSettings(CommentSettingsPage)
    case postSettings(PostSettingsPage)
    case licenseSettings(LicensesSettingsPage)
    
    
    // swiftlint:disable cyclomatic_complexity
    static func makeRoute(_ value: some Hashable) throws -> AppRoute {
        switch value {
        case let value as any InstanceStubProviding:
            return .instance(value)
        case let value as any CommunityStubProviding:
            return .community(value)
        case let value as any PersonStubProviding:
            return .person(value)
        case let value as any PostStubProviding:
            return .post(value)
        case let value as SettingsPage:
            return .settings(value)
        case let value as AboutSettingsPage:
            return .aboutSettings(value)
        case let value as AppearanceSettingsPage:
            return .appearanceSettings(value)
        case let value as CommentSettingsPage:
            return .commentSettings(value)
        case let value as PostSettingsPage:
            return .postSettings(value)
        case let value as LicensesSettingsPage:
            return .licenseSettings(value)
        case let value as Self:
            /// Value is an enum case of type `Self` with either no associated value or pre-populated associated value.
            return value
        default:
            throw RoutableError.routeNotConfigured(value: value)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}


extension AppRoute: Equatable, Hashable {
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.community(comm1), .community(comm2)):
            return comm1.actorId == comm2.actorId
        case let (.person(comm1, community1), .person(comm2, community2)):
            return comm1.actorId == comm2.actorId && community1?.actorId == community2?.actorId
        case let (.post(post1), .post(post2)):
            return post1.actorId == post2.actorId
        case let (.settings(value1), .settings(value2)):
            return value1 == value2
        case let (.aboutSettings(value1), .aboutSettings(value2)):
            return value1 == value2
        case let (.appearanceSettings(value1), .appearanceSettings(value2)):
            return value1 == value2
        case let (.commentSettings(value1), .commentSettings(value2)):
            return value1 == value2
        case let (.postSettings(value1), .postSettings(value2)):
            return value1 == value2
        case let (.licenseSettings(value1), .licenseSettings(value2)):
            return value1 == value2
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .instance(let instance):
            hasher.combine(instance.actorId)
        case .community(let community):
            hasher.combine(community.actorId)
        case .person(let person, let communityContext):
            hasher.combine(person.actorId)
            hasher.combine(communityContext?.actorId)
        case .post(let post):
            hasher.combine(post.actorId)
        case .settings(let value):
            hasher.combine(value)
        case .aboutSettings(let value):
            hasher.combine(value)
        case .appearanceSettings(let value):
            hasher.combine(value)
        case .commentSettings(let value):
            hasher.combine(value)
        case .postSettings(let value):
            hasher.combine(value)
        case .licenseSettings(let value):
            hasher.combine(value)
        }
    }
}
