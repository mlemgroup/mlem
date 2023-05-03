//
//  Decoded Storage.swift
//  Mlem
//
//  Created by David Bureš on 01.04.2022.
//

import Foundation

class DecodedPostStorage: ObservableObject
{
    @Published var storedDecodedPosts: [Post]

    init()
    {
        storedDecodedPosts = [Post]()
    }
}
