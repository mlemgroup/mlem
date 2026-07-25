//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Actions
import MlemMiddleware
import SwiftUI

/// Renders an interaction bar.
///
/// This view makes several layout assumptions:
/// - There will be no padding applied to this view
/// - This view will always appear at the bottom of its visual container
/// - The visual container of this view will have a padding of standardSpacing
struct InteractionBarView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(CommentTreeTracker.self) var commentTreeTracker: CommentTreeTracker?

    @Environment(\.self) var environment
    @Environment(\.communityContext) var communityContext
    @Environment(\.reportContext) var reportContext

    enum Content {
        case post(Post)
        case comment(Comment)
        case notification(Comment, InboxNotification)

        var inner: AnyObject {
            switch self {
            case let .post(post): post
            case let .comment(comment): comment
            case let .notification(_, notification): notification
            }
        }
    }
    
    private let content: Content
    private let configuration: any NewInteractionBarConfiguration

    private var leading: [EnrichedWidget] {
        .init(
            appState: appState,
            navigation: navigation,
            content: content,
            items: configuration.interactionBar.leading,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
    }

    private var trailing: [EnrichedWidget] {
        .init(
            appState: appState,
            navigation: navigation,
            content: content,
            items: configuration.interactionBar.trailing,
            commentTreeTracker: commentTreeTracker,
            communityContext: communityContext,
            reportContext: reportContext
        )
    }

    private func wrapEnrichedWidgets(_ widgets: [EnrichedWidget]) -> [EnrichedWidgetWrapper] {
        widgets.map {
            .init(
                widget: $0,
                viewId: $0.viewId(
                    entityId: ObjectIdentifier(content.inner).hashValue,
                    environment: environment
                )
            )
        }
    }

    private let readouts: [Readout]
    
    init(
        post: Post,
        configuration: PostBarConfiguration,
    ) {
        self.content = .post(post)
        self.configuration = configuration
        let associatedReadouts = configuration.interactionBar.all.reduce(into: Set<ReadoutType>()) { result, widget in
            result.formUnion(widget.associatedReadouts(context: post))
        }
        self.readouts = configuration.interactionBar.readouts.compactMap { readout in
            post.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }
    
    init(
        comment: Comment,
        configuration: CommentBarConfiguration,
    ) {
        self.content = .comment(comment)
        self.configuration = configuration
        let associatedReadouts = configuration.interactionBar.all.reduce(into: Set<ReadoutType>()) { result, widget in
            result.formUnion(widget.associatedReadouts(context: comment))
        }
        self.readouts = configuration.interactionBar.readouts.compactMap { readout in
            comment.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }
    
    init(
        comment: Comment,
        notification: InboxNotification,
        configuration: ReplyBarConfiguration
    ) {
        self.content = .notification(comment, notification)
        self.configuration = configuration
        let associatedReadouts = configuration.interactionBar.all.reduce(into: Set<ReadoutType>()) { result, widget in
            result.formUnion(widget.associatedReadouts(context: comment))
        }
        self.readouts = configuration.interactionBar.readouts.compactMap { readout in
            comment.readout(type: readout, showColor: !associatedReadouts.contains(readout))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(wrapEnrichedWidgets(leading), id: \.viewId, content: widgetView)
                .fixedSize(horizontal: true, vertical: false)
            InfoStackView(readouts: readouts)
                .frame(maxWidth: .infinity, alignment: infoStackAlignment)
                .padding(.horizontal, Constants.main.standardSpacing)
            ForEach(wrapEnrichedWidgets(trailing), id: \.viewId, content: widgetView)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(height: Constants.main.barIconHitbox)
        .geometryGroup()
    }
    
    var infoStackAlignment: Alignment {
        switch (leading.isEmpty, trailing.isEmpty) {
        case (true, false): .leading
        case (false, true): .trailing
        default: .center
        }
    }
    
    @ViewBuilder
    private func widgetView(_ widget: EnrichedWidgetWrapper) -> some View {
        switch widget.widget {
        case let .action(action):
            actionView(action)
        case let .counter(counter):
            counterView(counter)
        }
    }
    
    @ViewBuilder
    private func counterView(_ counter: Counter) -> some View {
        let paddingEdges: Edge.Set = {
            if counter.leadingAction == nil { return .leading }
            if counter.trailingAction == nil { return .trailing }
            return []
        }()
        
        HStack(spacing: 0) {
            if let leadingAction = counter.leadingAction?.createAction(content.inner) {
                actionView(leadingAction)
            }
            Text(counter.value?.description ?? "")
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(counter.value ?? 0)))
                .animation(.default, value: counter.value)
                .foregroundStyle(.themedPrimary)
                .padding(paddingEdges, Constants.main.standardSpacing)
                
            if let trailingAction = counter.trailingAction?.createAction(content.inner) {
                actionView(trailingAction)
            }
        }
    }
    
    @ViewBuilder
    private func actionView(_ action: Actions.Action) -> some View {
        let label = action.createLabel(environment: environment)
        InteractionBarBasicButton(action: action)
            .popupAnchor()
            .accessibilityLabel(label.title)
            .accessibilityAction(.default) {
                action.execute(environment: environment)
            }
            .buttonStyle(.empty)
            .disabled(label.visibility != .enabled)
            .popupAnchor()
    }
}

private struct InteractionBarBasicButton: View {
    @Environment(\.self) var environment
    
    let action: Actions.Action
    
    var body: some View {
        Button {
            action.execute(environment: environment)
        } label: {
            let label = action.createLabel(environment: environment)
            InteractionBarActionLabelView(label)
                .opacity(label.visibility == .enabled ? 1 : 0.5)
        }
    }
}

// Necessary because ForEach requires a property for the ID
private struct EnrichedWidgetWrapper {
    let widget: EnrichedWidget
    let viewId: Int
}

private enum EnrichedWidget {
    case action(Actions.Action)
    case counter(Counter)
    
    func viewId(entityId: Int, environment: EnvironmentValues) -> Int {
        var hasher = Hasher()
        switch self {
        case let .action(action):
            hasher.combine(1)
            hasher.combine(entityId)
            let label = action.createLabel(environment: environment)
            hasher.combine(label.title)
            hasher.combine(label.prominent)
            hasher.combine((action as? BasicAction)?.disabled)
        case let .counter(counter):
            // If `counter.value` is included in this, the fancy `.numericText()` transition
            // won't work. In theory, you *do* need to include `counter.value` if you want a
            // view update to happen when it changes... but one occurs anyway without doing that,
            // so I'm hoping it'll be fine? The inclusion of `action.isOn` above is definitely
            // needed. - Sjmarf 2024-06-15
            hasher.combine(2)
            hasher.combine(counter.leadingAction?.key)
            hasher.combine(counter.trailingAction?.key)
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
        content: InteractionBarView.Content,
        items: [InteractionBarItem],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: Community?,
        reportContext: Report?
    ) {
        switch content {
        case let .post(post):
            self.init(
                appState: appState,
                navigation: navigation,
                post: post,
                items: items,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext,
                reportContext: reportContext
            )
        case let .comment(comment):
            self.init(
                appState: appState,
                navigation: navigation,
                comment: comment,
                items: items,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext,
                reportContext: reportContext
            )
        case let .notification(comment, notification):
            self.init(
                appState: appState,
                navigation: navigation,
                comment: comment,
                notification: notification,
                items: items
            )
        }
    }

    init(
        appState: AppState,
        navigation: NavigationLayer,
        post: Post,
        items: [InteractionBarItem],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: Community?,
        reportContext: Report?
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(seed):
                if let action = seed.createAction(post) {
                    return .action(action)
                } else {
                     return nil
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
        comment: Comment,
        items: [InteractionBarItem],
        commentTreeTracker: CommentTreeTracker?,
        communityContext: Community?,
        reportContext: Report?
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(seed):
                if let action = seed.createAction(comment) {
                    return .action(action)
                } else {
                     return nil
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
        navigation: NavigationLayer,
        comment: Comment,
        notification: InboxNotification,
        items: [InteractionBarItem]
    ) {
        self = items.compactMap { item in
            switch item {
            case let .action(seed):
                if let action = seed.createAction(comment) {
                    return .action(action)
                } else {
                     return nil
                }
            case let .counter(counter):
                if let counter = comment.counter(appState: appState, type: counter) {
                    return .counter(counter)
                }
            }
            return nil
        }
    }
}
