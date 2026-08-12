//
//  CommentInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

struct CommentBarConfiguration:
    Codable,
    InteractionBarConfiguration,
    SwipeActionConfiguration,
    ContextMenuConfiguration {

    var savedContextMenu: [ActionSeed]?
    var savedSwipes: ActionSeedSwipeConfiguration?
    var savedInteractionBar: InteractionBarActions?
    var savedPinnedInteractionBarItems: Set<InteractionBarItem>?

    static var defaultInteractionBar: InteractionBarActions {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save), .action(.reply)],
            readouts: [.created, .comment]
        )
    }

    static var defaultPinnedInteractionBarItems: Set<InteractionBarItem> {
        [
            .counter(.score),
            .counter(.upvote),
            .counter(.downvote),
            .counter(.reply),
            .action(.upvote),
            .action(.downvote),
            .action(.save),
            .action(.reply),
            .action(.share)
        ]
    }

    static var defaultSwipes: ActionSeedSwipeConfiguration {
        .init(leading: [.downvote, .upvote], trailing: [.save, .reply])
    }

    static var defaultContextMenu: [ActionSeed] {
        [.selectText, .share, .blockCreator, .report, .edit, .delete, .remove, .banCreator, .resolveReport]
    }

    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage { .commentBarWidgetPicker(configuration) }
    
    init() {}    

    // swiftlint:disable:next function_body_length
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let contextMenuKeys = try container.decodeIfPresent([String].self, forKey: .savedContextMenu) {
            let allActions = Self.availableActions.all
            self.savedContextMenu = contextMenuKeys.compactMap { key in allActions.first(where: {$0.key == key}) }
        } else {
            self.savedContextMenu = nil
        }

        let pinnedItems = try container.decodeIfPresent([RawInteractionBarItem].self, forKey: .pinnedInteractionBarItems) 
        if let pinnedItems {
            self.savedPinnedInteractionBarItems = Set(pinnedItems.compactMap {
                .init(raw: $0, availableActions: Self.availableActions.all)
            })
        } else if let availableWidgets = try container.decodeIfPresent(Set<LegacyItem>.self, forKey: .availableWidgets) {
            self.savedPinnedInteractionBarItems = Set(availableWidgets.map { .init(legacy: $0) })
        } else {
            self.savedPinnedInteractionBarItems = nil
        }

        let interactionBarContainer = try? container.nestedContainer(
            keyedBy: InteractionBarActions.CodingKeys.self,
            forKey: .interactionBar
        )
        if let interactionBarContainer {
            self.savedInteractionBar = try .init(from: interactionBarContainer, availableActions: Self.availableActions.all)
        } else {
            let leading = try container.decodeIfPresent([LegacyItem].self, forKey: .leading) ?? [.counter(.score)]
            let trailing = try container.decodeIfPresent([LegacyItem].self, forKey: .trailing) ?? [.action(.save), .action(.reply)]
            let readouts = try container.decodeIfPresent([ReadoutType].self, forKey: .readouts) ?? [.created, .comment]

            let bar = InteractionBarActions(
                leading: leading.map { .init(legacy: $0) },
                trailing: trailing.map { .init(legacy: $0) },
                readouts: readouts
            )

            if bar == Self.defaultInteractionBar {
                self.savedInteractionBar = nil
            } else {
                self.savedInteractionBar = bar
            }
        }

        let swipeConfigurationContainer = try? container.nestedContainer(
            keyedBy: ActionSeedSwipeConfiguration.CodingKeys.self,
            forKey: .swipes
        )
        if let swipeConfigurationContainer {
            self.savedSwipes = try .init(from: swipeConfigurationContainer, availableActions: Self.availableActions.all)
        } else {
            // Convert from Mlem 2.4 -> 2.5 format
            let leadingSwipes = try container.decodeIfPresent([LegacyActionType].self, forKey: .leadingSwipes) ?? [.upvote, .downvote]
            let trailingSwipes = try container.decodeIfPresent([LegacyActionType].self, forKey: .trailingSwipes) ?? [.save, .reply]

            let swipes = ActionSeedSwipeConfiguration(
                leading: leadingSwipes.map(\.actionSeed),
                trailing: trailingSwipes.map(\.actionSeed)
            )

            if swipes == Self.defaultSwipes {
                self.savedSwipes = nil
            } else {
                self.savedSwipes = swipes
            }
        }
    }
    
    enum CodingKeys: CodingKey {
        case savedContextMenu
        case swipes
        case interactionBar
        case pinnedInteractionBarItems

        // Used for conversion from Mlem 2.4 -> 2.5 format
        case leadingSwipes
        case trailingSwipes

        // Used for conversion from Mlem 2.5 -> 2.6 format
        case availableWidgets
        case leading
        case trailing
        case readouts
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.savedContextMenu, forKey: .savedContextMenu)
        try container.encode(self.savedSwipes, forKey: .swipes)
        try container.encode(self.savedInteractionBar, forKey: .interactionBar)
        try container.encode(self.pinnedInteractionBarItems, forKey: .pinnedInteractionBarItems)
    }

    static var availableActions: ActionSeedSections { .init(sections: [
            [
                .upvote,
                .downvote,
                .save,
                .reply,
                .selectText,
                .share,
                .createImage,
                .toggleNotifications,
                .translate,
                .report,
                .edit,
                .delete
            ],
            [
                .collapse,
                .collapseParent,
                .collapseToTop
            ],
            [
                .blockCreator,
                .copyAuthorName,
                .openCreatorModlog,
                .sendCreatorMessage
            ],
            [
                .viewVotes,
                .remove,
                .banCreator,
                .purge,
                .purgeCreator,
                .resolveReport
            ]
        ])
    }
}
