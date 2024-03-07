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
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var community: CommunityModel?
    @State var user: UserModel?
    
    @State var isSearchingCommunity: Bool = false
    @State var isSearchingUser: Bool = false

    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    // if present, these context bindings will pre-populate the relevant field and prevent it from being modified; upon confirm, any present bindings will be updated.
    var communityBinding: Binding<CommunityModel>?
    var userBinding: Binding<UserModel>?
    
    let canChangeCommunity: Bool
    let canChangeUser: Bool
    
    // TODO: 2.0 get rid of bindings and just update the models
    init(community: Binding<CommunityModel>?, user: Binding<UserModel>?) {
        self.communityBinding = community
        self.userBinding = user
        
        if let community {
            self._community = .init(wrappedValue: community.wrappedValue)
        }
        if let user {
            self._user = .init(wrappedValue: user.wrappedValue)
        }
        
        self.canChangeCommunity = community == nil
        self.canChangeUser = user == nil
    }
    
    var body: some View {
        content
            .navigationTitle("Add Moderator")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isSearchingUser) {
                SimpleUserSearchView(
                    resultsFilter: { !(community?.isModerator($0.userId) ?? true) },
                    callback: { user in
                        self.user = user
                    }
                )
            }
            .sheet(isPresented: $isSearchingCommunity) {
                SimpleCommunitySearchView(
                    defaultItems: siteInformation.myUser?.moderatedCommunities,
                    resultsFilter: { community in
                        // admin can add mod to any community
                        if siteInformation.myUser?.isAdmin ?? false {
                            return true
                        }
                        // users can only add mod to communities they moderate
                        return siteInformation.moderatedCommunities.contains(community.communityId)
                    },
                    callback: { community in
                        self.community = community
                    }
                )
            }
    }
    
    var content: some View {
        Form {
            Section("Community") {
                Button {
                    assert(community != nil || canChangeCommunity, "Community nil but cannot be changed!")
                    if canChangeCommunity {
                        isSearchingCommunity = true
                    }
                } label: {
                    if let community {
                        CommunityLabelView(community: community, serverInstanceLocation: .bottom)
                    } else {
                        Text("Search")
                            .foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Section("User") {
                Button {
                    assert(user != nil || canChangeUser, "User nil but cannot be changed!")
                    if canChangeUser {
                        isSearchingUser = true
                    }
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
            
            if let community, let user {
                Button("Confirm") {
                    confirmAddModerator(community: community, user: user)
                }
            }
        }
    }
    
    func confirmAddModerator(community: CommunityModel, user: UserModel) {
        Task {
            await community.updateModStatus(of: user.userId, to: true) { newCommunity in
                if let communityBinding {
                    communityBinding.wrappedValue = newCommunity
                }
                // TODO: update user
            }
            await notifier.add(.success("Modded \(user.name ?? "user")"))
            dismiss()
        }
    }
}
