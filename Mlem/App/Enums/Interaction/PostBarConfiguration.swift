//
//  PostInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

struct PostBarConfiguration: InteractionBarConfiguration, SwipeActionConfiguration {
    var leading: [Item]
    var trailing: [Item]
    var readouts: [ReadoutType]
    var leadingSwipes: [ActionType]
    var trailingSwipes: [ActionType]
    var savedContextMenu: [ActionSeed]?

    private var swipes_: ActionSeedSwipeConfiguration?

    var swipes: ActionSeedSwipeConfiguration {
        get {
            swipes_ ?? Self.defaultSwipes
        }
        set {
            swipes_ = newValue
        }
    }

    static var defaultSwipes: ActionSeedSwipeConfiguration {
        .init(leading: [.downvote, .upvote], trailing: [.save, .reply])
    }

    var availableWidgets: Set<Item>
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage { .postBarWidgetPicker(configuration) }
    
    init(
        leading: [Item],
        trailing: [Item],
        leadingSwipes: [ActionType],
        trailingSwipes: [ActionType],
        readouts: [ReadoutType],
        availableWidgets: Set<Item>,
        savedContextMenu: [ActionSeed]?
    ) {
        self.leading = leading
        self.trailing = trailing
        self.leadingSwipes = leadingSwipes
        self.trailingSwipes = trailingSwipes
        self.readouts = readouts
        self.availableWidgets = availableWidgets
        self.savedContextMenu = savedContextMenu
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leading = try container.decodeIfPresent([Item].self, forKey: .leading) ?? [.counter(.score)]
        self.trailing = try container.decodeIfPresent([Item].self, forKey: .trailing) ?? [.action(.save), .action(.reply)]
        self.readouts = try container.decodeIfPresent([ReadoutType].self, forKey: .readouts) ?? [.created, .comment]

        self.availableWidgets = try container.decodeIfPresent(Set<Item>.self, forKey: .availableWidgets) ??
            .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })

        if let contextMenuKeys = try container.decodeIfPresent([String].self, forKey: .savedContextMenu) {
            let allActions = Self.availableActions.all
            self.savedContextMenu = contextMenuKeys.compactMap { key in allActions.first(where: {$0.key == key}) }
        } else {
            self.savedContextMenu = nil
        }

        self.leadingSwipes = []
        self.trailingSwipes = []

        let swipeConfigurationContainer = try? container.nestedContainer(
            keyedBy: ActionSeedSwipeConfiguration.CodingKeys.self,
            forKey: .swipes
        )
        if let swipeConfigurationContainer {
            self.swipes_ = try .init(from: swipeConfigurationContainer, availableActions: Self.availableActions.all)
        } else {
            // Convert from Mlem 2.4 -> 2.5 format
            let leadingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .leadingSwipes) ?? [.upvote, .downvote]
            let trailingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .trailingSwipes) ?? [.save, .reply]

            self.leadingSwipes = leadingSwipes
            self.trailingSwipes = trailingSwipes

            let swipes = ActionSeedSwipeConfiguration(
                leading: leadingSwipes.map(\.actionSeed),
                trailing: trailingSwipes.map(\.actionSeed)
            )

            if swipes == Self.defaultSwipes {
                self.swipes_ = nil
            } else {
                self.swipes_ = swipes
            }
        }
    }

    enum CodingKeys: CodingKey {
        case leading
        case trailing
        case readouts 
        case availableWidgets
        case savedContextMenu
        case swipes

        // Used for conversion from Mlem 2.4 -> 2.5 format
        case leadingSwipes
        case trailingSwipes
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.leading, forKey: .leading)
        try container.encode(self.trailing, forKey: .trailing)
        try container.encode(self.readouts, forKey: .readouts)
        try container.encode(self.availableWidgets, forKey: .availableWidgets)
        try container.encode(self.savedContextMenu, forKey: .savedContextMenu)
        try container.encode(self.swipes_, forKey: .swipes)
    }
    
    static var `default`: Self {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save), .action(.reply)],
            leadingSwipes: [.upvote, .downvote],
            trailingSwipes: [.save, .reply],
            readouts: [.created, .comment],
            availableWidgets: .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) }),
            savedContextMenu: nil
        )
    }
    
    static var reportDefault_: Self {
        .init(
            leading: [.action(.resolve), .action(.lock)],
            trailing: [.action(.ban), .action(.remove)],
            leadingSwipes: [.upvote, .downvote],
            trailingSwipes: [.save, .reply],
            readouts: [.upvote, .downvote, .created, .comment],
            availableWidgets: .init(ActionType.defaultReportWidgets.map { .action($0) }),
            savedContextMenu: nil
        )
    }

    var contextMenu: [ActionSeed] {
        get {
            savedContextMenu ?? [.selectText, .share, .blockCreator, .report, .edit, .delete, .remove, .banCreator, .resolveReport]
        }
        set {
            savedContextMenu = newValue
        }
    }

    static var availableActions: ActionSeedSections { .init(sections: [
            [
                .upvote,
                .downvote,
                .save,
                .reply,
                .selectText,
                .share,
                .hide,
                .createImage,
                .report,
                .edit,
                .delete
            ],
            [
                .blockCreator,
                .copyAuthorName,
                .openCreatorModlog,
                .sendCreatorMessage
            ],
            [
                .pin,
                .lock,
                .markNsfw,
                .viewVotes,
                .remove,
                .banCreator,
                .purge,
                .purgeCreator,
                .resolveReport
            ]
        ])
    }
    
    static var reportDefault: Self? { .reportDefault_ }
}
