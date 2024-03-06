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
    
    @State var searchText: String = ""
    @State var users: [UserModel] = .init()
    @State var isConfirming: Bool = false
    @State var confirmingUser: UserModel?

    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    var confirmingUserName: String {
        confirmingUser?.name ?? "user"
    }
    
    var body: some View {
        content
            .searchable(text: $searchModel.searchText) // TODO: add isPresented: $isSearching for iOS 17
            .onReceive(
                searchModel.$searchText
                    .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            ) { newValue in
                if searchModel.previousSearchText != newValue, !newValue.isEmpty {
                    Task {
                        do {
                            let results = try await searchModel.performSearch(page: 1)
                            users = results
                                .compactMap { $0.wrappedValue as? UserModel }
                                .filter { !community.isModerator($0.userId) }
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
            }
            .alert(
                "Add \(confirmingUserName) as moderator of \(community.name)?",
                isPresented: $isConfirming,
                presenting: confirmingUser
            ) { user in
                Button("Cancel", role: .cancel) {
                    isConfirming = false
                }
                    
                Button("Confirm") {
                    confirmAddModerator(user: user)
                }
                .keyboardShortcut(.defaultAction)
            }
            .navigationTitle("Add Moderator")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(users, id: \.uid) { user in
                    UserListRow(user, complications: [.instance, .date, .posts, .comments], navigationEnabled: false)
                        .onTapGesture {
                            confirmingUser = user
                            isConfirming = true
                        }
                    Divider()
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
