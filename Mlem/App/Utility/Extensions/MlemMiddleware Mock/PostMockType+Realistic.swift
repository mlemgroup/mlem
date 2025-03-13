//
//  PostMockType+Realistic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation

extension PostMockType {
    enum Realistic: CaseIterable, Identifiable {
        case yorkshireDales
        case meguroRiver
        
        var id: Int {
            switch self {
            case .yorkshireDales: 0
            case .meguroRiver: 1
            }
        }
        
        var title: String {
            switch self {
            case .yorkshireDales: .init(
                    localized: "post.1.title",
                    defaultValue: "The Yorkshire Dales, England",
                    table: "PreviewLocalizable"
                )
            case .meguroRiver: .init(
                    localized: "post.2.title",
                    defaultValue: "Meguro River, Matsuno, Japan",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var content: String? {
            switch self {
            case .yorkshireDales: nil
            case .meguroRiver: nil
            }
        }
        
        var linkUrl: URL? {
            switch self {
            case .yorkshireDales: .init(string: "mlempreview://image/image.yorkshire_dales")
            case .meguroRiver: .init(string: "mlempreview://image/image.meguro_river")
            }
        }
        
        var creator: PersonMockType.Realistic {
            switch self {
            case .yorkshireDales: .commanderGoose
            case .meguroRiver: .anteSocial45
            }
        }
        
        var community: CommunityMockType.Realistic {
            switch self {
            case .yorkshireDales: .nature
            case .meguroRiver: .pics
            }
        }
    }
}
