//
//  ShieldsBadgeView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import Foundation

extension ShieldsBadgeView {
    enum LogoType { case bundle(String), system(String) }
    
    mutating func decodeBadgeType(_ path: [String]) {
        switch path[1] {
        case "mastodon":
            label = .init(localized: "Follow on Mastodon")
            logo = .bundle("mastodon.logo")
        case "discord":
            label = .init(localized: "Join Discord Server")
            logo = .bundle("discord.logo")
        case "matrix":
            label = .init(localized: "Join Matrix Room")
            logo = .bundle("matrix.logo")
        case "github":
            label = "GitHub"
            logo = .bundle("github.logo")
        case "opencollective":
            label = "OpenCollective"
        case "liberapay":
            label = "LiberaPay"
        case "mozilla-observatory":
            label = .init(localized: "Mozilla Observatory")
        case "lemmy":
            label = path[2]
        default:
            break
        }
    }
    
    mutating func decodeLabel(_ text: String) {
        let parts = text.replacingOccurrences(of: "_", with: " ").split(separator: "-")
        if parts.count == 3 {
            label = String(parts[0])
            message = String(parts[1])
        } else if parts.count == 2 {
            label = String(parts[0])
        }
    }
    
    mutating func decodeLogo(name: String) {
        switch name {
        case "github":
            logo = .bundle("github.logo")
        case "matrix":
            logo = .bundle("matrix.logo")
        case "mastodon":
            logo = .bundle("mastodon.logo")
        case "discord":
            logo = .bundle("discord.logo")
        case "lemmy":
            logo = .bundle("lemmy.logo")
        default:
            break
        }
    }
}
