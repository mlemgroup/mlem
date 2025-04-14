//
//  RegistrationApplicationView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-13.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

struct RegistrationApplicationView: View {
    @Environment(\.palette) var palette
    
    let application: RegistrationApplication
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                FullyQualifiedLinkView(application.creator, labelStyle: .medium)
                Spacer()
                EllipsisMenu(size: 24) {
                    application.menuActions()
                }
            }
            Markdown(application.questionResponse, configuration: .default(palette: palette))
            switch application.resolution {
            case .unresolved:
                resolutionButtonsView
            case .approved, .denied:
                resolutionInfoView
            }
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu {
            application.menuActions()
        }
    }
    
    @ViewBuilder
    var resolutionInfoView: some View {
        if let resolver = application.resolver {
            let color: ThemedColor = application.resolution == .approved ? .themedPositive : .themedNegative
            let resolverLabel = resolver.nameTextView(
                showFlairs: false,
                showInstance: true,
                font: .footnote,
                palette: palette,
                nameColor: color,
                instanceColor: color.opacity(0.5)
            )
            Group {
                if case let .denied(reason) = application.resolution {
                    if let reason {
                        Label("Denied by \(resolverLabel): \"\(reason)\"", icon: .general.failure)
                    } else {
                        Label("Denied by \(resolverLabel)", icon: .general.failure)
                            .lineLimit(1)
                    }
                } else {
                    Label("Approved by \(resolverLabel)", icon: .general.success)
                        .lineLimit(1)
                }
            }
            .symbolVariant(.circle.fill)
            .foregroundStyle(color)
            .font(.footnote)
        }
    }
    
    @ViewBuilder
    var resolutionButtonsView: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            Button {
                application.showDenialSheet()
            } label: {
                Image(icon: .general.failure)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.main.standardSpacing)
            }
            .background(.themedTertiaryGroupedBackground)
            .foregroundStyle(.themedNegative)
            .clipShape(.capsule)
            Button {
                application.approve()
            } label: {
                Image(icon: .general.success)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.main.standardSpacing)
            }
            .background(.themedTertiaryGroupedBackground)
            .foregroundStyle(.themedAccent)
            .clipShape(.capsule)
        }
        .font(.subheadline)
        .fontWeight(.semibold)
    }
}
