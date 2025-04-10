//
//  AccountNicknameFieldView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-02.
//

import SwiftUI

struct AccountNicknameFieldView: View {
    @Environment(AppState.self) var appState
    
    @Setting(\.tab_profile_labelType) var tabProfileLabelType

    @State var nickname: String

    init() {
        self.nickname = AppState.main.firstAccount.storedNickname ?? ""
    }
    
    var body: some View {
        Section("Nickname") {
            TextField(
                "Nickname",
                text: $nickname,
                prompt: Text(appState.firstAccount.name)
            )
            .onSubmit {
                AppState.main.firstAccount.setNickname(nickname)
            }
        } footer: {
            if tabProfileLabelType == .nickname {
                Text("The name shown in the account switcher and tab bar.")
            } else {
                Text("The name shown in the account switcher.")
            }
        }
    }
}
