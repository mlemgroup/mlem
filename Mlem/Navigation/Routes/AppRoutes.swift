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

struct RouteWrapper: Equatable, Hashable {
    let wrappedValue: any ActorIdentifiable
    
    static func == (lhs: RouteWrapper, rhs: RouteWrapper) -> Bool {
        return lhs.wrappedValue.actorId == rhs.wrappedValue.actorId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.actorId)
    }
    
    init(_ wrappedValue: any ActorIdentifiable) {
        self.wrappedValue = wrappedValue
    }
}


enum AppRoute: Routable {
    case instance(String? = nil, InstanceModel? = nil)
    
    case userProfile(UserModel, communityContext: CommunityModel? = nil)
    
    case postLinkWithContext(PostLinkWithContext)
    // case newPostLinkWithContext(NewPostLinkWithContext)
    case lazyLoadPostLinkWithContext(LazyLoadPostLinkWithContext)
    
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
        case let value as UserModel:
            return .userProfile(value)
        case let value as PostLinkWithContext:
            return .postLinkWithContext(value)
        case let value as LazyLoadPostLinkWithContext:
            return .lazyLoadPostLinkWithContext(value)
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
