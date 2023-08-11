//
//  Easter Rewards.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Foundation

enum IconId: String {
    case beehawCommunity = "Beehaw Community By Aaron Schneider"
    case mlemhaw = "Mlemhaw By Clays"
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
