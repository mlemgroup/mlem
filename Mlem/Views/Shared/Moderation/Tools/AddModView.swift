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
    
    let community: CommunityModel
    
    @State var searchText: String = ""
    @State var users: [UserModel] = .init()
    
    @StateObject var searchModel: SearchModel = .init(searchTab: .users)
    
    var body: some View {
        content
            .searchable(text: $searchModel.searchText)
            .onReceive(
                searchModel.$searchText
                    .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            ) { newValue in
                if searchModel.previousSearchText != newValue, !newValue.isEmpty {
                    print("hi")
                    Task {
                        do {
                            let results = try await searchModel.performSearch(page: 1)
                            users = results.compactMap { result in
                                result.wrappedValue as? UserModel
                            }
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
            }
            .navigationTitle("Add Moderator")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var content: some View {
        ScrollView {
            VStack {
                ForEach(users, id: \.uid) { user in
                    UserListRow(user)
                }
            }
        }
    }
}
