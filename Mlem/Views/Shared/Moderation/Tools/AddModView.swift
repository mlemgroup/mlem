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
    @State var isSubmitting: Bool = false

    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    // if present, these context bindings will pre-populate the relevant field and prevent it from being modified; upon confirm, any present bindings will be updated.
    var communityBinding: Binding<CommunityModel>?
    var userBinding: Binding<UserModel>?
    
    let canChangeCommunity: Bool
    let canChangeUser: Bool
    
    // TODO: 2.0 get rid of bindings and just update the models implicitly at cache layer when add mod call returns
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
            .progressOverlay(isPresented: $isSubmitting)
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
                        // filter out communities that the user already moderates
                        if user?.moderatedCommunities?.contains(community) ?? false {
                            return false
                        }
                        
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let community, let user {
                            confirmAddModerator(community: community, user: user)
                        } else {
                            assertionFailure("Confirm enabled but community or user nil!")
                        }
                    } label: {
                        Image(systemName: Icons.send)
                    }
                    .disabled(user == nil || community == nil)
                }
            }
    }
    
    var content: some View {
        Form {
            Section("Community") {
                Button {
                    isSearchingCommunity = true
                } label: {
                    HStack {
                        if let community {
                            CommunityLabelView(community: community, serverInstanceLocation: .bottom)
                        } else {
                            Text("No community selected")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if canChangeCommunity {
                            Image(systemName: Icons.search)
                        }
                    }
                }
                .disabled(!canChangeCommunity)
                .buttonStyle(.borderless)
            }
            
            Section("User") {
                Button {
                    isSearchingUser = true
                } label: {
                    HStack {
                        if let user {
                            UserLabelView(user: user, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No user selected")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if canChangeUser {
                            Image(systemName: Icons.search)
                        }
                    }
                }
                .disabled(!canChangeUser)
            }
        }
    }
    
    func confirmAddModerator(community: CommunityModel, user: UserModel) {
        isSubmitting = true
        
        Task {
            let result = await community.updateModStatus(of: user.userId, to: true) { newCommunity in
                communityBinding?.wrappedValue = newCommunity
                userBinding?.wrappedValue.addModeratedCommunity(newCommunity)
            }
            
            if result {
                // introduce delay to give sheet time to disappear before notification pops
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Task {
                        await notifier.add(.success("Modded \(user.name ?? "user")"))
                    }
                }
                dismiss()
            } else {
                isSubmitting = false
            }
        }
    }
}
