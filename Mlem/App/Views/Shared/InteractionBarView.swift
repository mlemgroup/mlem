//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import MlemMiddleware
import SwiftUI

struct InteractionBarView: View {
    @Environment(Palette.self) var palette
    
    private let leading: [EnrichedWidget]
    private let trailing: [EnrichedWidget]
    private let readouts: [Readout]
    
    init(post: any Post1Providing, configuration: PostBarConfiguration) {
        self.leading = .init(post: post, items: configuration.leading)
        self.trailing = .init(post: post, items: configuration.trailing)
        self.readouts = configuration.readouts.map { post.readout(type: $0) }
    }

    var body: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            ForEach(leading, id: \.viewId, content: widgetView)
            InfoStackView(readouts: readouts, showColor: false)
                .frame(maxWidth: .infinity, alignment: infoStackAlignment)
            ForEach(trailing, id: \.viewId, content: widgetView)
        }
        .frame(height: AppConstants.barIconSize)
    }
    
    var infoStackAlignment: Alignment {
        switch (leading.isEmpty, trailing.isEmpty) {
        case (true, false):
            .leading
        case (false, true):
            .trailing
        default:
            .center
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
                
            if let trailingAction = counter.trailingAction {
                actionView(trailingAction)
            }
        }
    }
    
    @ViewBuilder
    private func actionView(_ action: any Action) -> some View {
        Button {
            (action as? BasicAction)?.callback?()
        } label: {
            actionLabelView(action)
        }
        .accessibilityLabel(action.label)
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
    }
    
    @ViewBuilder
    private func actionLabelView(_ action: any Action) -> some View {
        let isOn = ((action as? BasicAction)?.disabled ?? false) ? false : action.isOn
        Image(systemName: action.barIcon)
            .resizable()
            .fontWeight(.medium)
            .symbolVariant(isOn ? .fill : .none)
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .foregroundColor(isOn ? palette.selectedInteractionBarItem : palette.primary)
            .background(isOn ? action.color : .clear, in: .rect(cornerRadius: AppConstants.tinyItemCornerRadius))
            .contentShape(Rectangle())
            .opacity(((action as? BasicAction)?.disabled ?? false) ? 0.5 : 1)
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
            hasher.combine(action.isOn)
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
    init(post: any Post1Providing, items: [PostBarConfiguration.Item]) {
        self = items.map { item in
            switch item {
            case let .action(action):
                return .action(post.action(type: action))
            case let .counter(counter):
                return .counter(post.counter(type: counter))
            }
        }
    }
}
