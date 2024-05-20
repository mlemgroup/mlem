//
//  ToastView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let toast: Toast
    @State private var isExpanded: Bool = false
    @State private var didUndo: Bool = false
    
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
                        title: title ?? "Undo",
                        subtitle: title == nil ? nil : "Tap to Undo",
                        systemImage: didUndo ? "checkmark.circle.fill" : (systemImage ?? "arrow.uturn.backward.circle.fill"),
                        imageColor: color,
                        subtitleColor: .blue
                    )
                    .contentShape(.rect)
                }
                .buttonStyle(EmptyButtonStyle())
            case let .error(details):
                errorView(details)
            case let .user(user):
                HStack {
                    AvatarView(user.wrappedValue.stub, showLoadingPlaceholder: false)
                        .frame(height: 28)
                        .padding(.leading, 10)
                    Text(user.wrappedValue.nickname ?? user.wrappedValue.name)
                        .frame(minWidth: 100)
                        .padding(.trailing)
                }
            }
        }
        .frame(height: isExpanded ? nil : 47)
        .frame(maxHeight: isExpanded ? 230 : nil)
        .background(colorScheme == .dark ? Palette.main.secondaryBackground : Palette.main.background
        )
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
        HStack {
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
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(subtitleColor)
                    }
                } else {
                    Text(title)
                }
            }
            .frame(minWidth: 100)
            .padding(.trailing)
        }
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
                    image(details.systemImage ?? "exclamationmark.circle.fill", color: .red)
                    
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
                            Text(details.error?.localizedDescription ?? "")
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
                        .tint(.red)
                        .padding(10)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .leading)
                .background(isExpanded ? .red.opacity(0.15) : .clear)
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
            .foregroundStyle(color)
            .padding([.vertical, .leading], 10)
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
    }
}
