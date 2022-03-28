//
//  Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Foundation

struct Post: Decodable {
    let name: String
    let body: String?
    
    let creator_name: String
    
    let upvotes: Int
    let downvotes: Int
}

class PostData_Decoded: ObservableObject {
    // TODO: Feed WebSocket response here V
    let postRawData = mockData
    private let decoder = JSONDecoder()
    
    @Published var isLoading = false
    @Published var decodedPosts = [Post]()
    
    func decodeRawJSON() {
        do {
            self.decodedPosts = try decoder.decode([Post].self, from: postRawData.data(using: .utf8)!)
        } catch {
            print("Failed to decode: \(error)")
        }
    }

}

/*struct Post: Identifiable {
    let id = UUID()
    
    let link: URL
    let title: String
    
    let type: postTypes
    
    let poster: User
}*/

enum postTypes {
    case text
    case image
    case website
}
