//
//  CounterApperance+StaticValues.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-29.
//

import Actions

extension CounterAppearance {
    static func score(value: Int = 7) -> CounterAppearance {
        .init(
            value: 7,
            leading: ActionSeed.upvote.appearance,
            trailing: ActionSeed.downvote.appearance,
            label: "Score Counter",
            singleIcon: .lemmy.scoreCounter
        )
    }
    
    static func upvote() -> CounterAppearance {
        .init(
            value: 9,
            leading: ActionSeed.upvote.appearance,
            trailing: nil,
            label: "Upvote Counter",
            singleIcon: .lemmy.upvoteCounter
        )
    }
    
    static func downvote() -> CounterAppearance {
        .init(
            value: 2,
            leading: ActionSeed.downvote.appearance,
            trailing: nil,
            label: "Downvote Counter",
            singleIcon: .lemmy.downvoteCounter
        )
    }
    
    static func reply() -> CounterAppearance {
        .init(
            value: 3,
            leading: ActionSeed.reply.appearance,
            trailing: nil,
            label: "Reply Counter",
            singleIcon: .lemmy.replyCounter
        )
    }
}
