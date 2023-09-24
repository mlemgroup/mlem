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
    
    // swiftlint:disable cyclomatic_complexity
    static func makeRoute<V>(_ value: V) -> SettingsRoute? where V: Hashable {
        switch value {
        case let value as Self:
            return value
        case let value as AboutSettingsRoute:
            if let route = AboutSettingsRoute.makeRoute(value) {
                return .aboutPage(route)
            } else {
                return nil
            }
        case let value as AppearanceSettingsRoute:
            if let route = AppearanceSettingsRoute.makeRoute(value) {
                return .appearancePage(route)
            } else {
                return nil
            }
        case let value as CommentSettingsRoute:
            if let route = CommentSettingsRoute.makeRoute(value) {
                return .commentPage(route)
            } else {
                return nil
            }
        case let value as PostSettingsRoute:
            if let route = PostSettingsRoute.makeRoute(value) {
                return .postPage(route)
            } else {
                return nil
            }
        case let value as LicensesSettingsRoute:
            if let route = LicensesSettingsRoute.makeRoute(value) {
                return .licensesPage(route)
            } else {
                return nil
            }
        default:
            print(Self.makeRouteErrorString)
            return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity
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
    
    static func makeRoute<V>(_ value: V) -> AboutSettingsRoute? where V: Hashable {
        switch value {
        case let value as Self:
            return value
        case let value as Document:
            //            return .privacyPolicy(value)
            return .eula(value)
        default:
            print(Self.makeRouteErrorString)
            return nil
        }
    }
}

enum LicensesSettingsRoute: Routable {
    case licenseDocument(Document)
    
    static func makeRoute<V>(_ value: V) -> LicensesSettingsRoute? where V: Hashable {
        switch value {
        case let value as Document:
            return .licenseDocument(value)
        default:
            print(Self.makeRouteErrorString)
            return nil
        }
    }
}
