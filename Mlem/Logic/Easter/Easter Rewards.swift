//
//  Easter Rewards.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Foundation

enum IconId: String {
    case beehawCommunity = "Beehaw Community By Aaron Schneider",
         mlemhaw = "Mlemhaw By Clays"
}
typealias EasterFlag = String

enum RewardType {
    case icon(iconName: String, iconId: IconId)
}

let easterReward: [EasterFlag: [RewardType]] = [
    "login:beehaw.org": [
        .icon(iconName: "Mlemhaw", iconId: .mlemhaw),
        .icon(iconName: "Beehaw Community", iconId: .beehawCommunity)
    ]
]

let easterDependentIcons: [IconId: EasterFlag] = [
    .mlemhaw: "login:beehaw.org",
    .beehawCommunity: "login:beehaw.org"
]
