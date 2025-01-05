//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import SwiftUI

struct TabBarSettingsView: View {
    @Environment(AppState.self) var appState
    
    @Setting(\.tabProfileLabelType) var profileTabLabel: ProfileTabLabel
    @Setting(\.tabProfileShowAvatar) var showUserAvatar: Bool
    
    var account: any Account {
        appState.firstAccount
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ForEach(ProfileTabLabel.allCases, id: \.self) { item in
                        VStack(spacing: 10) {
                            if account.avatar != nil, showUserAvatar {
                                CircleCroppedImageView(account, frame: 42)
                            } else {
                                Image(systemName: Icons.personCircle)
                                    .resizable()
                                    .frame(width: 42, height: 42)
                            }
                            Group {
                                switch item {
                                case .nickname:
                                    Text(account.nickname)
                                case .instance:
                                    Text(account.host ?? "Instance")
                                case .anonymous:
                                    Text("Profile")
                                }
                            }
                            .font(.footnote)
                            Checkbox(isOn: profileTabLabel == item)
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            profileTabLabel = item
                        }
                    }
                }
            }
            Section {
                Toggle("Show Avatar", isOn: $showUserAvatar)
            }
        }
        .navigationTitle("Tab Bar")
    }
}

enum ProfileTabLabel: String, Codable, CaseIterable {
    case nickname, instance, anonymous
}
