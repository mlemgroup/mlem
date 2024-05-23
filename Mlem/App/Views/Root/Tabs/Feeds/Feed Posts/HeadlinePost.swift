//
//  HeadlinePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct HeadlinePost: View {
    let post: any Post1Providing
    
    var body: some View {
        Text("Headlie post")
    }
    
    var content: some View {}
}
