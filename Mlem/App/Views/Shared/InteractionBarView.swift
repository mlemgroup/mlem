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
    
    init(post: any Post1Providing, configuration: PostBarConfiguration) {
        self.leading = .init(post: post, items: configuration.leading)
        self.trailing = .init(post: post, items: configuration.trailing)
    }

    var body: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            ForEach(leading, id: \.self, content: widgetView)
            Spacer()
            ForEach(trailing, id: \.self, content: widgetView)
        }
        .frame(height: AppConstants.barIconSize)
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
            Text("\(counter.value ?? 0)")
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(counter.value ?? 0)))
                
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
        .buttonStyle(.plain)
//        .transaction { transaction in
//            transaction.disablesAnimations = true
//        }
    }
    
    @ViewBuilder
    private func actionLabelView(_ action: any Action) -> some View {
        Image(systemName: action.barIcon)
            .resizable()
            .fontWeight(.medium)
            .symbolVariant(action.isOn ? .fill : .none)
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .foregroundColor(action.isOn ? palette.selectedInteractionBarItem : palette.primary)
            .background(action.isOn ? action.color : .clear, in: .rect(cornerRadius: AppConstants.tinyItemCornerRadius))
            .contentShape(Rectangle())
    }
}

private enum EnrichedWidget: Hashable {
    case action(any Action)
    case counter(Counter)
    
    var viewId: Int {
        var hasher = Hasher()
        switch self {
        case let .action(action):
            hasher.combine(action.color)
        case let .counter(counter):
            // Hashing needs to be done this way for the value `.contentTransition` to work
            hasher.combine(counter.leadingAction?.barIcon)
            hasher.combine(counter.trailingAction?.barIcon)
        }
        return hasher.finalize()
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .action(action):
            hasher.combine(action.id)
        case let .counter(counter):
            // Hashing needs to be done this way for the value `.contentTransition` to work
            hasher.combine(counter.leadingAction?.barIcon)
            hasher.combine(counter.value)
            hasher.combine(counter.trailingAction?.barIcon)
        }
    }
    
    static func == (lhs: EnrichedWidget, rhs: EnrichedWidget) -> Bool {
        lhs.hashValue == rhs.hashValue
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
