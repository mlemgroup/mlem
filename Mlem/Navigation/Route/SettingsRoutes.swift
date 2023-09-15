//
//  SettingsRoutes.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import Foundation

enum SettingsRoute: Hashable {
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

enum AboutSettingsRoute: Hashable {
    case contributors
    case privacyPolicy(Document)
    case eula(Document)
    case licenses
}

enum LicensesSettingsRoute: Hashable {
    case licenseDocument(Document)
}
