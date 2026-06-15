//
//  AccountAgeVisibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-04-23.
//

import SwiftUI

struct AccountAgeVisibilitySettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.palette) var palette
    
    @Setting(\.person_ageVisibility) var accountAgeVisibility
    
    var body: some View {
        Form {
            previewSection
            Section {
                Text("Choose whether to show a user's account age next to their username.")
                    .multilineTextAlignment(.center)
            }
            Picker("Show Account Age", selection: $accountAgeVisibility) {
                ForEach(AccountAgeFlairVisibility.allCases, id: \.self) { visibility in
                    Text(visibility.label)
                        .tag(visibility)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .contentMargins(.top, 16)
        .navigationTitle("Show Account Age")
    }
    
    @ViewBuilder
    var previewSection: some View {
        Section {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 16,
                    bottomLeading: 0,
                    bottomTrailing: UIDevice.isIos26 ? 26 : 10,
                    topTrailing: 0
                )
            )
            .fill(.themedTertiaryGroupedBackground)
            .strokeBorder(colorScheme == .light ? .themedSecondaryGroupedBackground : .clear, lineWidth: 2)
            .frame(height: 100)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 0) {
                    CircleCroppedImageView(url: nil, frame: 30, fallback: .personAvatar)
                        .opacity(0.8)
                    HStack(spacing: 5) {
                        Image(icon: .lemmy.newAccountFlair)
                            .symbolVariant(.fill)
                            .imageScale(.small)
                        Text(flairString)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 10)
                    .foregroundStyle(.themedAccountAgeColor(0))
                    labelText
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.themedSecondary)
                        .opacity(0.8)
                        .mask {
                            LinearGradient(colors: [.black, .black.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                        }
                        .offset(y: -1)
                }
                .padding([.top, .leading], 20)
                .font(.title2)
            }
            .padding([.top, .leading], 20)
            .listRowInsets(.init())
        }
    }
    
    var flairString: String {
        let components = DateComponents(day: 5)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: components) ?? ""
    }
    
    var labelText: Text {
        let string = String(
            localized: "john@example.com",
            // swiftlint:disable:next line_length
            comment: "Translate \"john\" into the equivalent placeholder name in your language, and \"example.com\" into a suitable example domain for your locale. The placeholder name should be as short as possible, as this string is displayed in contexts where there may not be much space horizontally."
        )
        let parts = string.split(separator: "@")
        guard parts.count == 2 else {
            assertionFailure()
            return Text(string)
        }
        return Text(parts[0]) + Text(verbatim: "@\(parts[1])").foregroundColor(palette.label.tertiary)
    }
}

enum AccountAgeFlairVisibility: String, Codable, CaseIterable {
    case always, newAccountsOnly, never
    
    var label: LocalizedStringResource {
        switch self {
        case .always:
            "Always"
        case .newAccountsOnly:
            "For New Accounts Only"
        case .never:
            "Never"
        }
    }
}
