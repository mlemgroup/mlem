//
//  Score Style.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation

enum VoteComplexStyle: String, CaseIterable, Identifiable {
    case standard, symmetric
    
    var id: Self { self }
}
