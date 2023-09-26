//
//  SettingsRoutes.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import Foundation

enum SettingsRoute: Routable {
    case accountsPage
    case general
    case accessibility
    case appearance
    case contentFilters
    case about
    case advanced

    case aboutPage(AboutSettingsRoute)
    case appearancePage(AppearanceSettingsRoute)
    case commentPage(CommentSettingsRoute)
    case postPage(PostSettingsRoute)
    case licensesPage(LicensesSettingsRoute)
    
    static func makeRoute<V>(_ value: V) throws -> SettingsRoute where V: Hashable {
        switch value {
        case let value as AboutSettingsRoute:
            return try .aboutPage(AboutSettingsRoute.makeRoute(value))
        case let value as AppearanceSettingsRoute:
            return try .appearancePage(AppearanceSettingsRoute.makeRoute(value))
        case let value as CommentSettingsRoute:
            return try .commentPage(CommentSettingsRoute.makeRoute(value))
        case let value as PostSettingsRoute:
            return try .postPage(PostSettingsRoute.makeRoute(value))
        case let value as LicensesSettingsRoute:
            return try .licensesPage(LicensesSettingsRoute.makeRoute(value))
        case let value as Self:
            /// Value is an enum case of type `Self` with either no associated value or pre-populated associated value.
            return value
        default:
            throw RoutableError.routeNotConfigured(value: value)
        }
    }
}

enum AppearanceSettingsRoute: Routable, Codable {
    case theme
    case appIcon
    case posts
    case comments
    case communities
    case users
    case tabBar
}

enum CommentSettingsRoute: Routable, Codable {
    case layoutWidget
}

enum PostSettingsRoute: Routable, Codable {
    case customizeWidgets
}

enum AboutSettingsRoute: Routable {
    case contributors
    case privacyPolicy(Document)
    case eula(Document)
    case licenses
    
    static func makeRoute<V>(_ value: V) throws -> AboutSettingsRoute where V: Hashable {
        switch value {
        case let value as Document:
            //            return .privacyPolicy(value)
            return .eula(value)
        case let value as Self:
            /// Value is an enum case of type `Self` with either no associated value or pre-populated associated value.
            return value
        default:
            throw RoutableError.routeNotConfigured(value: value)
        }
    }
}

enum LicensesSettingsRoute: Routable {
    case licenseDocument(Document)
    
    static func makeRoute<V>(_ value: V) throws -> LicensesSettingsRoute where V: Hashable {
        switch value {
        case let value as Document:
            return .licenseDocument(value)
        default:
            throw RoutableError.routeNotConfigured(value: value)
        }
    }
}
