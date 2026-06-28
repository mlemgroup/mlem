//
//  ToastView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import ComponentViews
import Icons
import SwiftUI
import Theming

struct ToastView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let toast: Toast
    @State private var isExpanded: Bool = false
    @State private var didUndo: Bool = false
    
    // These symbols only have a single hierarchical layer, so we render it as `.secondary`
    static let dimmedSymbols: Set<Icon> = [.lemmy.block]
    
    // These symbols need `.symbolVariant(.circle.fill)` applied to render properly
    static let circledSymbols: Set<Icon> = [
        .general.success,
        .general.error,
        .general.failure,
        .general.undo,
        .lemmy.notification,
        .lemmy.enableNotifications,
        .lemmy.disableNotifications
    ]
    
    var body: some View {
        HStack {
            switch toast.type {
            case let .basic(
                title: title,
                subtitle: subtitle,
                icon: icon,
                color: color,
                duration: _
            ):
                regularView(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    imageColor: color
                )
            case let .undoable(
                title: title,
                icon: icon,
                successIcon: successIcon,
                callback: callback,
                color: color
            ):
                Button {
                    if !didUndo {
                        didUndo = true
                        callback()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            toast.kill()
                        }
                    }
                } label: {
                    let icon = didUndo ? (successIcon ?? .general.success) : (icon ?? .general.undo)
                    regularView(
                        title: title ?? (didUndo ? .init(localized: "Undone!") : .init(localized: "Undo")),
                        subtitle: title == nil ? nil : (didUndo ? .init(localized: "Undone!") : .init(localized: "Tap to Undo")),
                        icon: icon,
                        imageColor: color,
                        subtitleColor: .themedAccent
                    )
                    .symbolVariant(ToastView.circledSymbols.contains(icon) ? .circle.fill : .none)
                    .contentShape(.rect)
                }
                .buttonStyle(.empty)
            case let .error(details):
                errorView(details)
            case let .loading(title):
                loadingView(title)
            case let .account(account):
                accountView(account)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxHeight: isExpanded ? 230 : nil)
        .background((colorScheme == .dark ? ThemedColor.themedSecondaryBackground : ThemedColor.themedBackground).opacity(0.5))
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 25))
        .shadow(color: .black.opacity(0.1), radius: 5)
        .shadow(color: .black.opacity(0.1), radius: 1)
        .padding(.horizontal, isExpanded ? 10 : 50)
    }
    
    @ViewBuilder
    func regularView(
        title: String,
        subtitle: String?,
        icon: Icon?,
        imageColor: ThemedColor,
        subtitleColor: ThemedColor = .themedSecondary
    ) -> some View {
        HStack(spacing: Constants.main.doubleSpacing) {
            if let icon {
                image(icon, color: imageColor)
                    .symbolVariant(ToastView.circledSymbols.contains(icon) ? .circle.fill : .none)
                    .contentTransition(.symbolEffect(.replace, options: .speed(4)))
            }
            Group {
                if let subtitle {
                    VStack(spacing: 1) {
                        Text(title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .contentTransition(.opacity)
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(subtitleColor)
                            .contentTransition(.opacity)
                    }
                    .frame(minWidth: 80)
                    .padding(.vertical, 5)
                } else {
                    Text(title)
                        .lineLimit(1)
                        .frame(minWidth: 80)
                }
            }
            .padding(icon == nil ? .horizontal : .trailing, Constants.main.doubleSpacing)
        }
        .frame(minWidth: 157)
        .padding(icon == nil ? .vertical : [], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func accountView(_ account: any Account) -> some View {
        HStack(spacing: Constants.main.doubleSpacing) {
            CircleCroppedImageView(account, frame: 27, showProgress: false)
                .padding([.vertical, .leading], Constants.main.standardSpacing)
            Text(account.nickname)
                .lineLimit(1)
                .frame(minWidth: 80)
                .padding(.trailing, Constants.main.doubleSpacing)
        }
        .frame(minWidth: 157)
    }
    
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func errorView(_ details: ErrorDetails) -> some View {
        Button {
            if details.error != nil {
                withAnimation(.bouncy(duration: 0.2)) {
                    isExpanded = true
                    toast.shouldTimeout = false
                }
            }
        } label: {
            let icon = details.icon ?? .general.error
            VStack(spacing: 0) {
                HStack {
                    image(icon, color: .themedNegative)
                        .symbolVariant(ToastView.circledSymbols.contains(icon) ? .circle.fill : .none)
                    
                    Text(details.title ?? .init(localized: "Error"))
                        .frame(minWidth: 100)
                        .padding(isExpanded ? [] : [.trailing])
                        .frame(maxWidth: isExpanded ? .infinity : nil)
                    
                    if isExpanded {
                        Button("Close", icon: .general.close) {
                            toast.kill()
                        }
                        .labelStyle(.iconOnly)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.themedSecondary)
                        .foregroundStyle(.secondary)
                        .font(.title)
                        .padding(.trailing, 10)
                    }
                }
                .contentShape(.rect)
                VStack(alignment: .leading, spacing: 0) {
                    if isExpanded {
                        ScrollView {
                            Text(details.errorText())
                                .foregroundStyle(.red)
                                .padding(8)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button("Copy", icon: .general.copy) {
                            UIPasteboard.general.string = details.errorText()
                        }
                        .font(.caption)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(.themedNegative)
                        .padding(Constants.main.standardSpacing)
                    }
                }
                .frame(maxHeight: isExpanded ? .infinity : 0, alignment: .leading)
                .background(.themedNegative.opacity(isExpanded ? 0.15 : 0))
            }
        }
        .buttonStyle(.empty)
    }
    
    @ViewBuilder
    func loadingView(_ title: String) -> some View {
        HStack(spacing: Constants.main.doubleSpacing) {
            ProgressView()
                .tint(.themedSecondary)
                .frame(width: 22, height: 22)
                .padding([.vertical, .leading], Constants.main.standardSpacing)
            Text(title)
                .frame(minWidth: 80)
                .padding(.trailing, Constants.main.doubleSpacing)
        }
        .frame(minWidth: 152)
    }
    
    @ViewBuilder
    func image(_ icon: Icon, color: ThemedColor) -> some View {
        Image(icon: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .fontWeight(.semibold)
            .symbolVariant(.fill)
            .symbolRenderingMode(.hierarchical)
            // Don't use palette here! - Sjmarf
            .foregroundStyle(ToastView.dimmedSymbols.contains(icon) ? .secondary : .primary)
            .foregroundStyle(color)
            .frame(width: 27)
            .padding([.vertical, .leading], Constants.main.standardSpacing)
    }
}

extension ToastView {
    init(_ type: ToastType) {
        self.init(toast: .init(type: type, location: .top))
    }
}

#Preview {
    VStack {
        ToastView(.success())
        ToastView(.failure())
        ToastView(.undoable(callback: {}))
        ToastView(.error(.init()))
        ToastView(.success(String("Really super long text")))
    }
    .background {
        VStack(spacing: 0) {
            Color.clear
            HStack(spacing: 0) {
                Color.red
                Color.blue
            }
        }
    }
}
