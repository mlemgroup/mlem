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

struct CommentBarConfiguration: InteractionBarConfiguration {
    var leading: [Item]
    var trailing: [Item]
    var readouts: [ReadoutType]
    var leadingSwipes: [ActionType]
    var trailingSwipes: [ActionType]
    var savedContextMenu: [ActionSeed]?

    var availableWidgets: Set<Item>
    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage { .commentBarWidgetPicker(configuration) }
    
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
        self.leadingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .leadingSwipes) ?? [.upvote, .downvote]
        self.trailingSwipes = try container.decodeIfPresent([ActionType].self, forKey: .trailingSwipes) ?? [.save, .reply]
        self.readouts = try container.decodeIfPresent([ReadoutType].self, forKey: .readouts) ?? [.created, .comment]
        self.availableWidgets = try container.decodeIfPresent(Set<Item>.self, forKey: .availableWidgets) ??
            .init(CounterType.defaultWidgets.map { .counter($0) } + ActionType.defaultWidgets.map { .action($0) })
        if let contextMenuKeys = try container.decodeIfPresent([String].self, forKey: .savedContextMenu) {
            let allActions = Self.availableActions.all
            self.savedContextMenu = contextMenuKeys.compactMap { key in allActions.first(where: {$0.key == key}) }
        } else {
            self.savedContextMenu = Self.default.contextMenu
        }
    }

    var contextMenu: [ActionSeed] {
        get {
            savedContextMenu ?? [.selectText, .share, .blockCreator, .report, .edit, .delete, .remove, .banCreator, .resolveReport]
        }
        set {
            savedContextMenu = newValue
        }
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
            leading: [.action(.resolve), .action(.share)],
            trailing: [.action(.ban), .action(.remove)],
            leadingSwipes: [.upvote, .downvote],
            trailingSwipes: [.save, .reply],
            readouts: [.upvote, .downvote, .created, .comment],
            availableWidgets: .init(ActionType.defaultReportWidgets.map { .action($0) }),
            savedContextMenu: nil
        )
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
                .viewVotes,
                .remove,
                .banCreator,
                .purge,
                .purgeCreator,
                .resolveReport
            ]
        ])
    }
    
    static var reportDefault: Self? { reportDefault_ }
}
