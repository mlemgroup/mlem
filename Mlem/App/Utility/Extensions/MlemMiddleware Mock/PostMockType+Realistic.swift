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
        case showerThoughtPizza
        
        var id: Int {
            switch self {
            case .yorkshireDales: 0
            case .meguroRiver: 1
            case .showerThoughtPizza: 2
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
            case .showerThoughtPizza: .init(
                    localized: "post.3.title",
                    // swiftlint:disable:next line_length
                    defaultValue: "During a nuclear explosion, there is a certain distance of the radius where all the frozen supermarket pizzas are cooked to perfection.",
                    table: "PreviewLocalizable"
                )
            }
        }
        
        var content: String? {
            switch self {
            case .yorkshireDales: nil
            case .meguroRiver: nil
            case .showerThoughtPizza: nil
            }
        }
        
        var linkUrl: URL? {
            switch self {
            case .yorkshireDales: .init(string: "mlempreview://image/image.yorkshire_dales")
            case .meguroRiver: .init(string: "mlempreview://image/image.meguro_river")
            case .showerThoughtPizza: nil
            }
        }
        
        var creator: PersonMockType.Realistic {
            switch self {
            case .yorkshireDales: .commanderGoose
            case .meguroRiver: .anteSocial45
            case .showerThoughtPizza: .billyDaFish
            }
        }
        
        var community: CommunityMockType.Realistic {
            switch self {
            case .yorkshireDales: .nature
            case .meguroRiver: .pics
            case .showerThoughtPizza: .showerThoughts
            }
        }
    }
}
