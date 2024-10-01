//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import MlemMiddleware
import SwiftUI

struct InteractionBarView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    private let leading: [EnrichedWidget]
    private let trailing: [EnrichedWidget]
    private let readouts: [Readout]
    
    init(
        post: any Post1Providing,
        configuration: PostBarConfiguration,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil
    ) {
        self.leading = .init(
            post: post,
            items: configuration.leading,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext
        )
        self.trailing = .init(
            post: post,
            items: configuration.trailing,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext
        )
        self.readouts = configuration.readouts.map { post.readout(type: $0) }
    }
    
    init(
        comment: any Comment1Providing,
        configuration: CommentBarConfiguration,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil
    ) {
        self.leading = .init(
            comment: comment,
            items: configuration.leading,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext
        )
        self.trailing = .init(
            comment: comment,
            items: configuration.trailing,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext
        )
        self.readouts = configuration.readouts.map { comment.readout(type: $0) }
    }
    
    init(reply: any Reply1Providing, configuration: ReplyBarConfiguration) {
        self.leading = .init(reply: reply, items: configuration.leading)
        self.trailing = .init(reply: reply, items: configuration.trailing)
        self.readouts = configuration.readouts.map { reply.readout(type: $0) }
    }

    var body: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            ForEach(leading, id: \.viewId, content: widgetView)
            InfoStackView(readouts: readouts, showColor: false)
                .frame(maxWidth: .infinity, alignment: infoStackAlignment)
                .padding(infoStackPaddingEdges, -Constants.main.doubleSpacing)
            ForEach(trailing, id: \.viewId, content: widgetView)
        }
        .geometryGroup()
    }
    
    var infoStackAlignment: Alignment {
        switch (leading.isEmpty, trailing.isEmpty) {
        case (true, false): .leading
        case (false, true): .trailing
        default: .center
        }
    }
    
    var infoStackPaddingEdges: Edge.Set {
        switch (leading.isEmpty, trailing.isEmpty) {
        case (true, false): .trailing
        case (false, true): .leading
        default: .horizontal
        }
    }
    
    @ViewBuilder
    private func widgetView(_ widget: EnrichedWidget) -> some View {
        switch widget {
        case let .action(action):
            actionView(action)
        case let .counter(counter):
            counterView(counter)
        }
    }
    
    @ViewBuilder
    private func counterView(_ counter: Counter) -> some View {
        HStack {
            if let leadingAction = counter.leadingAction {
                actionView(leadingAction)
            }
            Text(counter.value?.description ?? "")
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(counter.value ?? 0)))
                .animation(.default, value: counter.value)
                .foregroundStyle(palette.primary)
                
            if let trailingAction = counter.trailingAction {
                actionView(trailingAction)
            }
        }
    }
    
    @ViewBuilder
    private func actionView(_ action: any Action) -> some View {
        Group {
            if let action = action as? ShareAction {
                Button {
                    navigation.shareInfo = .init(action)
                } label: {
                    InteractionBarActionLabelView(action.appearance)
                }
            } else {
                if let action = action as? ActionGroup {
                    Menu {
                        ForEach(action.children, id: \.id) { child in
                            MenuButton(action: child)
                        }
                    } label: {
                        InteractionBarActionLabelView(action.appearance)
                            .opacity(action.disabled ? 0.5 : 1)
                    }
                    .onTapGesture {}
                } else if let action = action as? BasicAction {
                    Button {
                        action.callback?()
                    } label: {
                        InteractionBarActionLabelView(action.appearance)
                            .opacity(action.disabled ? 0.5 : 1)
                    }
                }
            }
        }
        .accessibilityLabel(action.appearance.label)
        .accessibilityAction(.default) {
            (action as? BasicAction)?.callback?()
        }
        .buttonStyle(EmptyButtonStyle())
        .disabled({
            if let action = action as? BasicAction {
                return action.callback == nil
            } else {
                return false
            }
        }())
        .popupAnchor()
    }
}

private enum EnrichedWidget {
    case action(any Action)
    case counter(Counter)
    
    var viewId: Int {
        var hasher = Hasher()
        switch self {
        case let .action(action):
            hasher.combine(1)
            hasher.combine(action.id)
            hasher.combine(action.appearance.isOn)
            hasher.combine((action as? BasicAction)?.disabled)
        case let .counter(counter):
            // If `counter.value` is included in this, the fancy `.numericText()` transition
            // won't work. In theory, you *do* need to include `counter.value` if you want a
            // view update to happen when it changes... but one occurs anyway without doing that,
            // so I'm hoping it'll be fine? The inclusion of `action.isOn` above is definitely
            // needed. - Sjmarf 2024-06-15
            hasher.combine(2)
            hasher.combine(counter.leadingAction?.id)
            hasher.combine(counter.trailingAction?.id)
            hasher.combine((counter.leadingAction as? BasicAction)?.disabled)
            hasher.combine((counter.trailingAction as? BasicAction)?.disabled)
        }
        return hasher.finalize()
    }
}

extension [EnrichedWidget] {
    init(
        post: any Post1Providing,
        items: [PostBarConfiguration.Item],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: (any CommunityStubProviding)?
    ) {
        self = items.map { item in
            switch item {
            case let .action(action):
                return .action(
                    post.action(
                        type: action,
                        commentTreeTracker: commentTreeTracker,
                        communityContext: communityContext
                    )
                )
            case let .counter(counter):
                return .counter(
                    post.counter(
                        type: counter,
                        commentTreeTracker: commentTreeTracker
                    )
                )
            }
        }
    }
    
    init(
        comment: any Comment1Providing,
        items: [CommentBarConfiguration.Item],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: (any CommunityStubProviding)?
    ) {
        self = items.map { item in
            switch item {
            case let .action(action):
                return .action(
                    comment.action(
                        type: action,
                        commentTreeTracker: commentTreeTracker,
                        communityContext: communityContext
                    )
                )
            case let .counter(counter):
                return .counter(
                    comment.counter(
                        type: counter,
                        commentTreeTracker: commentTreeTracker
                    )
                )
            }
        }
    }
    
    init(
        reply: any Reply1Providing,
        items: [ReplyBarConfiguration.Item]
    ) {
        self = items.map { item in
            switch item {
            case let .action(action):
                return .action(reply.action(type: action))
            case let .counter(counter):
                return .counter(reply.counter(type: counter))
            }
        }
    }
}
