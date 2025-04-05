//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import MlemMiddleware
import SwiftUI

struct InteractionBarView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    private let leading: [EnrichedWidget]
    private let trailing: [EnrichedWidget]
    private let readouts: [Readout]
    
    init(
        appState: AppState,
        post: any Post1Providing,
        configuration: PostBarConfiguration,
        navigation: NavigationLayer,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil,
        reportContext: Report? = nil
    ) {
        self.leading = .init(
            appState: appState,
            navigation: navigation,
            post: post,
            items: configuration.leading,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
        self.trailing = .init(
            appState: appState,
            navigation: navigation,
            post: post,
            items: configuration.trailing,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
        var associatedReadouts = configuration.all.reduce(into: Set<PostBarConfiguration.ReadoutType>(), { result, widget in
            result.formUnion(widget.associatedReadouts(context: post))
        })
        self.readouts = configuration.readouts.compactMap { readout in
            post.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }
    
    init(
        appState: AppState,
        navigation: NavigationLayer,
        comment: any Comment1Providing,
        configuration: CommentBarConfiguration,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil,
        reportContext: Report?
    ) {
        self.leading = .init(
            appState: appState,
            navigation: navigation,
            comment: comment,
            items: configuration.leading,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
        self.trailing = .init(
            appState: appState,
            navigation: navigation,
            comment: comment,
            items: configuration.trailing,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
        var associatedReadouts = configuration.all.reduce(into: Set<CommentBarConfiguration.ReadoutType>(), { result, widget in
            result.formUnion(widget.associatedReadouts(context: comment))
        })
        self.readouts = configuration.readouts.compactMap { readout in
            comment.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }
    
    init(
        appState: AppState,
        reply: any Reply1Providing,
        configuration: ReplyBarConfiguration
    ) {
        self.leading = .init(appState: appState, reply: reply, items: configuration.leading)
        self.trailing = .init(appState: appState, reply: reply, items: configuration.trailing)
        var associatedReadouts = configuration.all.reduce(into: Set<ReplyBarConfiguration.ReadoutType>(), { result, widget in
            result.formUnion(widget.associatedReadouts(context: reply))
        })
        self.readouts = configuration.readouts.compactMap { readout in
            reply.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }

    var body: some View {
        HStack(spacing: Constants.main.doubleSpacing) {
            ForEach(leading, id: \.viewId, content: widgetView)
                .fixedSize(horizontal: true, vertical: false)
            InfoStackView(readouts: readouts)
                .frame(maxWidth: .infinity, alignment: infoStackAlignment)
                .padding(infoStackPaddingEdges, -Constants.main.doubleSpacing)
            ForEach(trailing, id: \.viewId, content: widgetView)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(height: Constants.main.barIconSize)
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
                .foregroundStyle(.themedPrimary)
                
            if let trailingAction = counter.trailingAction {
                actionView(trailingAction)
            }
        }
    }
    
    @ViewBuilder
    private func actionView(_ action: any Action) -> some View {
        Group {
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
                InteractionBarBasicButton(action: action)
                    .popupAnchor()
            }
        }
        .accessibilityLabel(action.appearance.label)
        .accessibilityAction(.default) {
            (action as? BasicAction)?.callback?()
        }
        .buttonStyle(.empty)
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

private struct InteractionBarBasicButton: View {
    @Environment(PopupAnchorModel.self) var popupModel
    
    let action: BasicAction
    
    var body: some View {
        Button {
            action.callbackWithConfirmation(popupModel: popupModel)
        } label: {
            InteractionBarActionLabelView(action.appearance)
                .opacity(action.disabled ? 0.5 : 1)
        }
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
            hasher.combine(action.appearance.isInProgress)
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
        appState: AppState,
        navigation: NavigationLayer,
        post: any Post1Providing,
        items: [PostBarConfiguration.Item],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: (any CommunityStubProviding)?,
        reportContext: Report?
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(action):
                if let action = post.action(
                    appState: appState,
                    navigation: navigation,
                    type: action,
                    commentTreeTracker: commentTreeTracker,
                    communityContext: communityContext,
                    reportContext: reportContext
                ) {
                    return .action(action)
                }
            case let .counter(counter):
                if let counter = post.counter(appState: appState, type: counter, commentTreeTracker: commentTreeTracker) {
                    return .counter(counter)
                }
            }
            return nil
        }
    }
    
    init(
        appState: AppState,
        navigation: NavigationLayer,
        comment: any Comment1Providing,
        items: [CommentBarConfiguration.Item],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: (any CommunityStubProviding)?,
        reportContext: Report?
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(action):
                if let action = comment.action(
                    appState: appState,
                    type: action,
                    navigation: navigation,
                    commentTreeTracker: commentTreeTracker,
                    communityContext: communityContext,
                    reportContext: reportContext
                ) {
                    return .action(action)
                }
            case let .counter(counter):
                if let counter = comment.counter(
                    appState: appState,
                    type: counter,
                    commentTreeTracker: commentTreeTracker
                ) {
                    return .counter(counter)
                }
            }
            return nil
        }
    }
    
    init(
        appState: AppState,
        reply: any Reply1Providing,
        items: [ReplyBarConfiguration.Item]
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(action):
                if let action = reply.action(appState: appState, type: action) {
                    return .action(action)
                }
            case let .counter(counter):
                if let counter = reply.counter(appState: appState, type: counter) {
                    return .counter(counter)
                }
            }
            return nil
        }
    }
}
