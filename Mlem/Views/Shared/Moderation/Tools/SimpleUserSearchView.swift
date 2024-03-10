//
//  SimpleUserSearchView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import Dependencies
import Foundation
import SwiftUI

/// Simple search view for finding a user. Takes in an optional filter to apply to user results and a callback, which will be activated when a user is tapped with the selected user.
struct SimpleUserSearchView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.dismiss) var dismiss
    
    @State var searchText: String = ""
    @State var users: [UserModel] = .init()
    
    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    let resultsFilter: (UserModel) -> Bool
    let callback: (UserModel) -> Void
    
    init(
        resultsFilter: @escaping (UserModel) -> Bool = { _ in true },
        callback: @escaping (UserModel) -> Void
    ) {
        self.resultsFilter = resultsFilter
        self.callback = callback
    }
    
    var body: some View {
        NavigationStack { // needed for .navigationTitle, .searchable to work in nested sheet
            content
                .searchable(text: $searchModel.searchText) // TODO: 2.0 add isPresented: $isSearching (iOS 17 exclusive)
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
                                    .filter(resultsFilter)
                            } catch {
                                errorHandler.handle(error)
                            }
                        }
                    }
                }
                .navigationTitle("Search for User")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", role: .destructive) {
                            dismiss()
                        }
                        .tint(.red)
                    }
                }
        }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(users, id: \.uid) { user in
                    UserListRow(user, complications: [.instance, .date, .posts, .comments], navigationEnabled: false)
                        .onTapGesture {
                            callback(user)
                            dismiss()
                        }
                    Divider()
                }
            }
        }
    }
}
