//
//  CounterApperance+StaticValues.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-29.
//

extension CounterAppearance {
    static func score(value: Int = 7, upvoteOn: Bool = false, downvoteOn: Bool = false) -> CounterAppearance {
        .init(
            value: value,
            leading: .upvote(isOn: upvoteOn),
            trailing: .downvote(isOn: downvoteOn),
            label: "Score Counter",
            singleIcon: Icons.scoreCounter
        )
    }
    
    static func upvote(value: Int = 9, isOn: Bool = false) -> CounterAppearance {
        .init(value: value, leading: .upvote(isOn: isOn), trailing: nil, label: "Upvote Counter", singleIcon: Icons.upvoteCounter)
    }
    
    static func downvote(value: Int = 2, isOn: Bool = false) -> CounterAppearance {
        .init(value: value, leading: .downvote(isOn: isOn), trailing: nil, label: "Downvote Counter", singleIcon: Icons.downvoteCounter)
    }
    
    static func reply(value: Int = 3) -> CounterAppearance {
        .init(value: value, leading: .reply(), trailing: nil, label: "Reply Counter", singleIcon: Icons.replyCounter)
    }
}
