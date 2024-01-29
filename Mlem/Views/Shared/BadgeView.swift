//
//  BadgeView.swift
//  Mlem
//
//  Created by Sjmarf on 15/01/2024.
//

import SwiftUI

enum BadgeError: Error {
    case invalidDomain
}

// https://shields.io/badges

struct BadgeView: View {
    var label: String
    var message: String?
    var color: BadgeColor?
    
    enum LogoType { case bundle(String), system(String) }
    var logo: LogoType?
    
    struct BadgeColor {
        let background: Color
        let outline: Color
        let text: Color
        
        init(_ background: Color, text: Color) {
            self.background = background
            self.outline = background
            self.text = text
        }
        
        init(_ background: Color, outline: Color, text: Color) {
            self.background = background
            self.outline = outline
            self.text = text
        }
        
        static let gray: BadgeColor = .init(Color(uiColor: .systemGray5), outline: Color(uiColor: .systemGray4), text: .primary)
    }
    
    // The badges support any CSS named color, and also the colors listed at the link. I don't know how we would support all named CSS colors, so instead I'm only supporting the basic ones and hoping that they specify hex instead for more obscure colors
    // https://www.npmjs.com/package/badge-maker#colors
    
    static let colorNameMap: [String: BadgeColor] = [
        "green": .init(.green, text: .white),
        "brightgreen": .init(.green, text: .white),
        "yellow": .init(.yellow, text: .black),
        "yelllowgreen": .init(.yellow, text: .black),
        "orange": .init(.orange, text: .systemBackground),
        "red": .init(.red, text: .white),
        "blue": .init(.blue, text: .white),
        "gray": .gray,
        "grey": .gray,
        "lightgray": .gray,
        "lightgrey": .gray,
        "success": .init(.green, text: .white),
        "important": .init(.orange, text: .systemBackground),
        "critical": .init(.red, text: .white),
        "informational": .init(.blue, text: .white),
        "inactive": .gray,
        "pink": .init(.pink, text: .white),
        "purple": .init(.purple, text: .white),
        "cyan": .init(.cyan, text: .white),
        "mint": .init(.mint, text: .white),
        "teal": .init(.teal, text: .white),
        "black": .init(.black, outline: Color(uiColor: .systemGray3), text: .white),
        "white": .init(Color(uiColor: .white), outline: Color(uiColor: .systemGray4), text: .black),
        "indigo": .init(.indigo, text: .white),
        "brown": .init(.brown, text: .white)
    ]
    
    init(url: URL) {
        self.label = "Unsupported Badge"
        if let host = url.host(), host == "img.shields.io" {
            let path = url.pathComponents
            decodeBadgeType(path)
            decodeLabel(path[2])
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                if let parameters = components.queryItems {
                    for parameter in parameters {
                        switch parameter.name {
                        case "logo":
                            if let value = parameter.value {
                                decodeLogo(name: value)
                            }
                        case "color":
                            if let value = parameter.value {
                                decodeColor(value)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    init(label: String, message: String?, color: BadgeColor) {
        self.label = label
        self.message = message
        self.color = color
    }
    
    mutating func decodeBadgeType(_ path: [String]) {
        switch path[1] {
        case "mastodon":
            label = "Follow on Mastodon"
            color = .init(Color(hex: "6364FF"), text: .white)
            logo = .bundle("mastodon.logo")
        case "discord":
            label = "Join Discord Server"
            color = .init(Color(hex: "5865F2"), text: .white)
            logo = .bundle("discord.logo")
        case "matrix":
            label = "Join Matrix Room"
            color = .init(.black, outline: .white, text: .white)
            logo = .bundle("matrix.logo")
        case "github":
            label = "Github"
            color = .init(.black, outline: .white, text: .white)
            logo = .bundle("github.logo")
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
            decodeColor(String(parts[2]))
        } else if parts.count == 2 {
            label = String(parts[0])
            decodeColor(String(parts[1]))
        }
    }
    
    mutating func decodeColor(_ text: String) {
        if color == nil {
            color = BadgeView.colorNameMap[text]
            if color == nil {
                color = .init(Color(hex: text), text: .primary)
            }
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
    
    var body: some View {
        HStack(spacing: 7) {
            Group {
                switch logo {
                case let .bundle(name):
                    Image(name)
                case let .system(systemName):
                    Image(systemName: systemName)
                case nil:
                    EmptyView()
                }
                Text(label)
                    .padding(.vertical, 3)
            }
            .foregroundStyle(message != nil ? .primary : (color?.text ?? .primary))
            if let message {
                Text(message)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 7)
                    .foregroundStyle(color?.text ?? .primary)
                    .background(color?.background ?? .secondarySystemBackground)
            }
        }
        .padding(.leading, 7)
        .padding(.trailing, message == nil ? 7 : 0)
        .background(message == nil ? color?.background : .clear)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                .stroke(color?.outline ?? .secondary, lineWidth: 1)
        }
    }
}

#Preview("Variants") {
    ScrollView {
        let text = """
            ![](https://img.shields.io/badge/label_only-blue)
            ![](https://img.shields.io/badge/hex_color-c48462)
            ![](https://img.shields.io/badge/label-and%20message-green)
            ![](https://img.shields.io/badge/label_and_logo-gray?logo=github)
            [![](https://img.shields.io/badge/with-link-pink)](https://lemmy.ml/c/mlemapp)
            ![](https://img.shields.io/badge/label-message_and_logo-gray?logo=mastodon)
            ![](https://img.shields.io/github/contributors/mlemgroup/mlem)
            ![](https://img.shields.io/mastodon/follow/110952393950540579?domain=https%3A%2F%2Fmastodon.world&style=flat-square&logo=mastodon&color=6364FF)
            ![](https://img.shields.io/discord/1120387349864534107?style=flat-square&logo=discord&color=565EAE)
            ![](https://img.shields.io/matrix/lemmy.world_general%3Amatrix.org?style=flat-square&logo=matrix&color=blue)
            ![](https://img.shields.io/lemmy/support%40lemmy.world?style=flat-square&logo=lemmy&label=support@lemmy.world&color=pink)
        """
        MarkdownView(text: text, isNsfw: false)
            .padding()
    }
}

#Preview("Colors") {
    ScrollView {
        LazyVGrid(
            columns: .init(repeating: GridItem(.adaptive(minimum: 200, maximum: .infinity)), count: 2),
            alignment: .leading, spacing: 10
        ) {
            ForEach(Array(BadgeView.colorNameMap.keys).sorted(by: >), id: \.self) { key in
                BadgeView(label: "Color", message: key, color: BadgeView.colorNameMap[key]!)
            }
        }
        .padding()
    }
}
