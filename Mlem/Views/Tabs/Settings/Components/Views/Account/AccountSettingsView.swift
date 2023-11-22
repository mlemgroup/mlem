//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import SwiftUI
import Dependencies

struct AccountSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    
    var body: some View {
        Form {
//            if let info = siteInformation.myUserInfo {
//                Text(info.localUserView.localUser.email ?? "No email")
//            } else {
//                Text("No user info")
//            }
        }
        .navigationTitle("Account Settings")
    }
}
