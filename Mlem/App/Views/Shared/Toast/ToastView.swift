//
//  ToastView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastView: View {
    @Environment(Palette.self) var palette
    @Environment(\.colorScheme) var colorScheme
    
    let toast: Toast
    @State private var isExpanded: Bool = false
    @State private var didUndo: Bool = false
    
    // These symbols only have a single hierarchical layer, so we render it as `.secondary`
    static let dimmedSymbols: Set<String> = [Icons.blockFill]
    
    var body: some View {
        HStack {
            switch toast.type {
            case let .basic(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                color: color,
                duration: _
            ):
                regularView(
                    title: title,
                    subtitle: subtitle,
                    systemImage: systemImage,
                    imageColor: color
                )
            case let .undoable(
                title: title,
                systemImage: systemImage,
                successSystemImage: successSystemImage,
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
                    regularView(
                        title: title ?? (didUndo ? "Undone!" : "Undo"),
                        subtitle: title == nil ? nil : (didUndo ? "Undone!" : "Tap to Undo"),
                        systemImage: didUndo ? (successSystemImage ?? Icons.successCircleFill) : (systemImage ?? Icons.undoCircleFill),
                        imageColor: color,
                        subtitleColor: Palette.main.accent
                    )
                    .contentShape(.rect)
                }
                .buttonStyle(EmptyButtonStyle())
            case let .error(details):
                errorView(details)
            case let .loading(title):
                HStack {
                    ProgressView()
                        .tint(palette.secondary)
                        .padding(.leading)
                    Text(title)
                        .padding(.horizontal, 30)
                }
            case let .account(account):
                accountView(account)
            }
        }
        .frame(height: isExpanded ? nil : 47)
        .frame(maxHeight: isExpanded ? 230 : nil)
        .background((colorScheme == .dark ? Palette.main.secondaryBackground : Palette.main.background).opacity(0.5))
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 25))
        .shadow(color: .black.opacity(0.1), radius: 5)
        .shadow(color: .black.opacity(0.1), radius: 1)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func regularView(
        title: String,
        subtitle: String?,
        systemImage: String?,
        imageColor: Color,
        subtitleColor: Color = .secondary
    ) -> some View {
        HStack(spacing: AppConstants.doubleSpacing) {
            if let systemImage {
                image(systemImage, color: imageColor)
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
                } else {
                    Text(title)
                        .lineLimit(1)
                        .frame(minWidth: 80)
                }
            }
            .padding(.trailing, AppConstants.doubleSpacing)
        }
        .frame(minWidth: 167)
    }
    
    @ViewBuilder
    func accountView(_ account: any Account) -> some View {
        HStack(spacing: AppConstants.doubleSpacing) {
            CircleCroppedImageView(account, showProgress: false)
                .frame(height: 27)
                .padding(.leading, 10)
            Text(account.nickname)
                .lineLimit(1)
                .frame(minWidth: 80)
                .padding(.trailing, AppConstants.doubleSpacing)
        }
        .frame(minWidth: 167)
    }
    
    @ViewBuilder
    func errorView(_ details: ErrorDetails) -> some View {
        Button {
            if details.error != nil {
                withAnimation(.bouncy(duration: 0.2)) {
                    isExpanded = true
                    toast.shouldTimeout = false
                }
            }
        } label: {
            VStack(spacing: 0) {
                HStack {
                    image(details.systemImage ?? Icons.errorCircleFill, color: palette.negative)
                    
                    Text(details.title ?? "Error")
                        .frame(minWidth: 100)
                        .padding(isExpanded ? [] : [.trailing])
                        .frame(maxWidth: isExpanded ? .infinity : nil)
                    
                    if isExpanded {
                        CloseButtonView(size: 28, callback: {
                            toast.kill()
                        })
                        .padding(.trailing, 10)
                    }
                }
                .contentShape(.rect)
                .frame(height: 47)
                VStack(alignment: .leading, spacing: 0) {
                    if isExpanded {
                        ScrollView {
                            Text(details.errorText)
                                .foregroundStyle(.red)
                                .padding(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button("Copy", systemImage: Icons.copy) {
                            if let text = details.error?.localizedDescription {
                                UIPasteboard.general.string = text
                            }
                        }
                        .font(.caption)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(Palette.main.negative)
                        .padding(AppConstants.standardSpacing)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .leading)
                .background(isExpanded ? Palette.main.negative.opacity(0.15) : .clear)
            }
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
    @ViewBuilder
    func image(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .fontWeight(.semibold)
            .symbolRenderingMode(.hierarchical)
            // Don't use palette here! - Sjmarf
            .foregroundStyle(ToastView.dimmedSymbols.contains(systemName) ? .secondary : .primary)
            .foregroundStyle(color)
            .frame(width: 27)
            .padding([.leading], AppConstants.standardSpacing)
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
        ToastView(
            .undoable(
                title: "Unfavorited Community",
                systemImage: "star.slash.fill",
                callback: {},
                color: .blue
            )
        )
        ToastView(.error(.init()))
        ToastView(.success("Really super long text"))
    }
    .environment(Palette.main)
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
