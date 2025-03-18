//
//  CommunityMockType+Realistic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-04.
//

import Foundation

extension CommunityMockType {
    // These values are localized for use in marketing material (e.g. preview images on the App Store)
    enum Realistic: CaseIterable, Identifiable {
        case news
        case pics
        case meIrl
        case technology
        case nature
        case showerThoughts
        
        var id: Int {
            switch self {
            case .news: 0
            case .pics: 1
            case .meIrl: 2
            case .technology: 3
            case .nature: 4
            case .showerThoughts: 5
            }
        }
        
        var name: String {
            switch self {
            case .news: .init(
                    localized: "community.1.name",
                    defaultValue: "news",
                    table: "PreviewLocalizable"
                )
            case .pics: .init(
                    localized: "community.2.name",
                    defaultValue: "pics",
                    table: "PreviewLocalizable"
                )
            case .meIrl: .init(
                    localized: "community.3.name",
                    defaultValue: "me_irl",
                    table: "PreviewLocalizable"
                )
            case .technology: .init(
                    localized: "community.4.name",
                    defaultValue: "technology",
                    table: "PreviewLocalizable"
                )
            case .nature: .init(
                    localized: "community.5.name",
                    defaultValue: "nature",
                    table: "PreviewLocalizable"
                )
            case .showerThoughts: .init(
                    localized: "community.6.name",
                    defaultValue: "showerthoughts",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var displayName: String {
            switch self {
            case .news: .init(
                    localized: "community.1.displayName",
                    defaultValue: "World News",
                    table: "PreviewLocalizable"
                )
            case .pics: .init(
                    localized: "community.2.displayName",
                    defaultValue: "Pics",
                    table: "PreviewLocalizable"
                )
            case .meIrl: .init(
                    localized: "community.3.displayName",
                    defaultValue: "me_irl",
                    table: "PreviewLocalizable"
                )
            case .technology: .init(
                    localized: "community.4.displayName",
                    defaultValue: "Technology",
                    table: "PreviewLocalizable"
                )
            case .nature: .init(
                    localized: "community.5.displayName",
                    defaultValue: "Nature",
                    table: "PreviewLocalizable"
                )
            case .showerThoughts: .init(
                    localized: "community.6.displayName",
                    defaultValue: "Nature",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var description: String? {
            switch self {
            case .news: nil
            case .pics: nil
            case .meIrl: nil
            case .technology: nil
            case .nature: nil
            case .showerThoughts: nil
            }
        }
        
        var avatar: URL? {
            switch self {
            case .news: .init(string: "mlempreview://image/pfp.news")
            case .pics: .init(string: "mlempreview://image/pfp.balloon")
            case .meIrl: .init(string: "mlempreview://image/pfp.person")
            case .technology: .init(string: "mlempreview://image/pfp.circuit")
            case .nature: .init(string: "mlempreview://image/pfp.lakeside")
            case .showerThoughts: .init(string: "mlempreview://image/pfp.shower")
            }
        }
        
        var banner: URL? {
            switch self {
            case .news: nil
            case .pics: nil
            case .meIrl: nil
            case .technology: nil
            case .nature: nil
            case .showerThoughts: .init(string: "mlempreview://image.droplets")
            }
        }
    }
}
