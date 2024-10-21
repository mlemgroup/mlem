//
//  FediseerOpinionListView.swift
//  Mlem
//
//  Created by Sjmarf on 04/02/2024.
//

import MlemMiddleware
import SwiftUI

struct FediseerOpinionListView: View {
    @Environment(Palette.self) var palette

    let instance: any InstanceStubProviding
    let opinionType: FediseerOpinionType
    let fediseerData: FediseerData
    
    var body: some View {
        FancyScrollView {
            VStack(spacing: 16) {
                let items = fediseerData.opinions(ofType: opinionType).sorted {
                    $0.reason != nil && $1.reason == nil
                }
                
                ForEach(items, id: \.domain) { opinion in
                    FediseerOpinionView(opinion: opinion)
                        .background(palette.secondaryGroupedBackground)
                        .cornerRadius(Constants.main.standardSpacing)
                }
            }
            .padding(16)
        }
        .background(palette.groupedBackground)
        .navigationTitle(opinionType.label)
    }
}
