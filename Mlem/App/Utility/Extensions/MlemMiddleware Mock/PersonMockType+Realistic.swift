//
//  PersonMockType+Realistic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

extension PersonMockType {
    // These values are localized for use in marketing material (e.g. preview images on the App Store)
    enum Realistic: CaseIterable, Identifiable {
        case flowerTail
        case commanderGoose
        case billyDaFish
        case grt38
        case anteSocial45
        
        var id: Int {
            switch self {
            case .flowerTail: 0
            case .commanderGoose: 1
            case .billyDaFish: 2
            case .grt38: 3
            case .anteSocial45: 4
            }
        }
        
        var name: String {
            switch self {
            case .flowerTail: .init(
                    localized: "person.1.name",
                    defaultValue: "flowertail",
                    table: "PreviewLocalizable"
                )
            case .commanderGoose: .init(
                    localized: "person.2.name",
                    defaultValue: "CommanderGoose",
                    table: "PreviewLocalizable"
                )
            case .billyDaFish: .init(
                    localized: "person.3.name",
                    defaultValue: "BillyDAFISH",
                    table: "PreviewLocalizable"
                )
            case .grt38: .init(
                    localized: "person.4.name",
                    defaultValue: "Grt38",
                    table: "PreviewLocalizable"
                )
            case .anteSocial45: .init(
                    localized: "person.5.name",
                    defaultValue: "ante_social_58",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var displayName: String {
            switch self {
            case .flowerTail: .init(
                    localized: "person.1.displayName",
                    defaultValue: "Flowertail",
                    table: "PreviewLocalizable"
                )
            case .commanderGoose: .init(
                    localized: "person.2.displayName",
                    defaultValue: "Commander Goose",
                    table: "PreviewLocalizable"
                )
            case .billyDaFish: .init(
                    localized: "person.3.displayName",
                    defaultValue: "BillyDAFISH",
                    table: "PreviewLocalizable"
                )
            case .grt38: .init(
                    localized: "person.4.displayName",
                    defaultValue: "Grt38",
                    table: "PreviewLocalizable"
                )
            case .anteSocial45: .init(
                    localized: "person.5.displayName",
                    defaultValue: "AnteSocial",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var description: String? {
            switch self {
            case .flowerTail: nil
            case .commanderGoose: .init(
                    localized: "person.2.description",
                    defaultValue: "HONK",
                    table: "PreviewLocalizable"
                )
            case .billyDaFish: nil
            case .grt38: nil
            case .anteSocial45: nil
            }
        }
        
        var avatar: URL? {
            switch self {
            case .flowerTail: .init(string: "mlempreview://image/pfp.flowers")
            case .commanderGoose: .init(string: "mlempreview://image/pfp.goose")
            case .billyDaFish: .init(string: "mlempreview://image/pfp.fish")
            case .grt38: .init(string: "mlempreview://image/pfp.firework")
            case .anteSocial45: nil
            }
        }
        
        var banner: URL? {
            switch self {
            case .flowerTail: nil
            case .commanderGoose: nil
            case .billyDaFish: nil
            case .grt38: nil
            case .anteSocial45: nil
            }
        }
        
        var matrixUserId: String? {
            switch self {
            case .flowerTail: nil
            case .commanderGoose: nil
            case .billyDaFish: nil
            case .grt38: nil
            case .anteSocial45: nil
            }
        }
        
        var isBot: Bool {
            switch self {
            default: false
            }
        }
    }
}
