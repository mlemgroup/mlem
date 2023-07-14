//
//  Easter Rewards.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Foundation

typealias IconId = String
typealias EasterFlag = String

enum RewardType {
    case icon(iconName: String, iconId: IconId)
}

let easterReward: [EasterFlag: [RewardType]] = [
    "login:beehaw.org": [
        .icon(iconName: "Mlemhaw", iconId: "Mlemhaw By Clays"),
        .icon(iconName: "Beehaw Community", iconId: "Beehaw Community By Aaron Schneider")
    ]
]

let easterDependentIcons: [IconId: EasterFlag] = [
    "Mlemhaw By Clays": "login:beehaw.org",
    "Beehaw Community By Aaron Schneider": "login:beehaw.org"
]
