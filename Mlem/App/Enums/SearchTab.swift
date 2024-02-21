//
//  SearchTab.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

enum SearchTab: String, CaseIterable, Identifiable {
    case topResults, communities, users, instances
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .topResults:
            return "Top Results"
        default:
            return rawValue.capitalized
        }
    }
    
    static var homePageCases: [SearchTab] = [.communities, .users, .instances]
}
