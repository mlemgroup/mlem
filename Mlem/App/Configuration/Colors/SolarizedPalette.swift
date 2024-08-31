//
//  SolarizedPalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-29.
//

import Foundation
import SwiftUI

// See https://ethanschoonover.com/solarized/ for details
// TODO: I'd love to do this in LAB space, but that involves some ugly manual CGColor work
private let base03: Color = .init(red: 0.0, green: 0.16862745098039217, blue: 0.21176470588235294)
private let base02: Color = .init(red: 0.027450980392156862, green: 0.21176470588235294, blue: 0.25882352941176473)
private let base01: Color = .init(red: 0.34509803921568627, green: 0.43137254901960786, blue: 0.4588235294117647)
private let base00: Color = .init(red: 0.396078431372549, green: 0.4823529411764706, blue: 0.5137254901960784)
private let base0: Color = .init(red: 0.5137254901960784, green: 0.5803921568627451, blue: 0.5882352941176471)
private let base1: Color = .init(red: 0.5764705882352941, green: 0.6313725490196078, blue: 0.6313725490196078)
private let base2: Color = .init(red: 0.9333333333333333, green: 0.9098039215686274, blue: 0.8352941176470589)
private let base3: Color = .init(red: 0.9921568627450981, green: 0.9647058823529412, blue: 0.8901960784313725)
private let yellow: Color = .init(red: 0.7098039215686275, green: 0.5372549019607843, blue: 0.0)
private let orange: Color = .init(red: 0.796078431372549, green: 0.29411764705882354, blue: 0.08627450980392157)
private let red: Color = .init(red: 0.8627450980392157, green: 0.19607843137254902, blue: 0.1843137254901961)
private let magenta: Color = .init(red: 0.8274509803921568, green: 0.21176470588235294, blue: 0.5098039215686274)
private let violet: Color = .init(red: 0.4235294117647059, green: 0.44313725490196076, blue: 0.7686274509803922)
private let blue: Color = .init(red: 0.14901960784313725, green: 0.5450980392156862, blue: 0.8235294117647058)
private let cyan: Color = .init(red: 0.16470588235294117, green: 0.6313725490196078, blue: 0.596078431372549)
private let green: Color = .init(red: 0.5215686274509804, green: 0.6, blue: 0.0)

extension ColorPalette {
    static let solarized: ColorPalette = .init(
        primary: .init(light: base00, dark: base0),
        secondary: .init(light: base0, dark: base01),
        tertiary: .init(light: base1, dark: base01),
        background: .init(light: base3, dark: base03),
        secondaryBackground: .init(light: base2, dark: base02),
        tertiaryBackground: .init(light: base2, dark: base02),
        groupedBackground: .init(light: base2, dark: base02),
        secondaryGroupedBackground: .init(light: base3, dark: base03),
        tertiaryGroupedBackground: .init(light: base2, dark: base02),
        thumbnailBackground: base0,
        positive: cyan,
        negative: red,
        warning: red,
        caution: orange,
        upvote: blue,
        downvote: red,
        save: cyan,
        read: violet,
        favorite: blue,
        selectedInteractionBarItem: base3,
        administration: violet,
        moderation: green,
        federatedFeed: blue,
        localFeed: violet,
        subscribedFeed: red,
        inbox: violet,
        accent: blue,
        neutralAccent: base0,
        colorfulAccents: [orange, violet, blue, cyan, magenta, green, cyan],
        commentIndentColors: [red, orange, yellow, cyan, blue, violet]
    )
}
