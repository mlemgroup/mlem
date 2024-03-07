//
//  AddModView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-05.
//

import Dependencies
import Foundation
import SwiftUI

struct AddModView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @Environment(\.dismiss) var dismiss

    @Binding var community: CommunityModel
    @State var user: UserModel?
    
    @State var isSearchingCommunity: Bool = false
    @State var isSearchingUser: Bool = false

    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    var body: some View {
        content
            .navigationTitle("Add Moderator")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isSearchingUser) {
                SimpleUserSearchView(
                    resultsFilter: { !community.isModerator($0.userId) },
                    callback: { user in
                        self.user = user
                    }
                )
            }
    }
    
    var content: some View {
        Form {
            Section("Community") {
                Button {
                    isSearchingCommunity = true
                } label: {
                    CommunityLabelView(community: community, serverInstanceLocation: .bottom)
                }
            }
            
            Section("User") {
                Button {
                    isSearchingUser = true
                } label: {
                    if let user {
                        UserLabelView(user: user, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                    } else {
                        Text("Search")
                            .foregroundColor(.accentColor) // mock proper button style
                    }
                }
                .buttonStyle(.plain) // prevent UserLabelView from displaying blue text
            }
            
            if let user {
                Button("Confirm") {
                    confirmAddModerator(user: user)
                }
            }
        }
    }
    
    func confirmAddModerator(user: UserModel) {
        Task {
            await community.updateModStatus(of: user.userId, to: true) { newCommunity in
                community = newCommunity
            }
            await notifier.add(.success("Modded \(user.name ?? "user")"))
            dismiss()
        }
    }
}
