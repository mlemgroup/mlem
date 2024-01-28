//
//  Easter Rewards.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Foundation

enum IconId: String {
    case beehawCommunity = "icon.aaron.beehaw"
    case mlemhaw = "icon.clays.beehaw"
}

enum EasterFlag: Codable, Hashable {
    case login(host: RecognizedLemmyInstances)
}

enum RewardType: Notifiable {
    case icon(iconName: String, iconId: IconId)
}

let easterReward: [EasterFlag: [RewardType]] = [
    .login(host: .beehaw): [
        .icon(iconName: "Mlemhaw", iconId: .mlemhaw),
        .icon(iconName: "Beehaw Community", iconId: .beehawCommunity)
    ]
]

let easterDependentIcons: [IconId: EasterFlag] = [
    .mlemhaw: .login(host: .beehaw),
    .beehawCommunity: .login(host: .beehaw)
]
