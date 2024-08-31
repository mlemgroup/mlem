//
//  DraculaPalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-31.
//

import Foundation
import SwiftUI

// source: https://draculatheme.com/contribute#color-palette
private let _darkBackground: Color = .init(red: 0.07843137255, green: 0.07450980392, blue: 0.1215686275)
private let _background: Color = .init(red: 0.1568627450980392, green: 0.16470588235294117, blue: 0.21176470588235294)
private let _secondaryBackground: Color = .init(red: 0.26666666666666666, green: 0.2784313725490196, blue: 0.35294117647058826)
private let _primary: Color = .init(red: 0.9725490196078431, green: 0.9725490196078431, blue: 0.9490196078431372)
private let _secondary: Color = .init(red: 0.3843137254901961, green: 0.4470588235294118, blue: 0.6431372549019608)
private let _cyan: Color = .init(red: 0.5450980392156862, green: 0.9137254901960784, blue: 0.9921568627450981)
private let _green: Color = .init(red: 0.3137254901960784, green: 0.9803921568627451, blue: 0.4823529411764706)
private let _orange: Color = .init(red: 1.0, green: 0.7215686274509804, blue: 0.4235294117647059)
private let _pink: Color = .init(red: 1.0, green: 0.4745098039215686, blue: 0.7764705882352941)
private let _purple: Color = .init(red: 0.7411764705882353, green: 0.5764705882352941, blue: 0.9764705882352941)
private let _red: Color = .init(red: 1.0, green: 0.3333333333333333, blue: 0.3333333333333333)
private let _yellow: Color = .init(red: 0.9450980392156862, green: 0.9803921568627451, blue: 0.5490196078431373)

extension ColorPalette {
    static let dracula: ColorPalette = .init(
        supportedModes: .dark,
        primary: _primary,
        secondary: _secondary,
        tertiary: _secondary,
        background: _background,
        secondaryBackground: _secondaryBackground,
        tertiaryBackground: _secondaryBackground,
        groupedBackground: _darkBackground,
        secondaryGroupedBackground: _background,
        tertiaryGroupedBackground: _secondaryBackground,
        thumbnailBackground: _secondaryBackground,
        positive: _green,
        negative: _red,
        warning: _red,
        caution: _orange,
        upvote: _cyan,
        downvote: _red,
        save: _green,
        read: _purple,
        favorite: _cyan,
        selectedInteractionBarItem: .white,
        administration: _purple,
        moderation: _pink,
        federatedFeed: _pink,
        localFeed: _purple,
        subscribedFeed: _red,
        inbox: _purple,
        accent: _purple,
        neutralAccent: _secondaryBackground,
        colorfulAccents: [_orange, _pink, _cyan, _green, _purple, _red, _yellow],
        commentIndentColors: [_cyan, _green, _orange, _pink, _purple, _red]
    )
}
