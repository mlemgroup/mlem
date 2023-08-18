//
//  SettingsRoutes.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import Foundation

enum SettingsRoute: Hashable, Codable {
    case accountsPage(onboarding: Bool)
    case general
    case accessibility
    case appearance
    case contentFilters
    case about
    case advanced
}

enum AppearanceSettingsRoute: Hashable, Codable {
    case theme
    case appIcon
    case posts
    case comments
    case communities
    case users
    case tabBar
}

enum CommentSettingsRoute: Hashable, Codable {
    case layoutWidget
}

enum PostSettingsRoute: Hashable, Codable {
    case customizeWidgets
}
