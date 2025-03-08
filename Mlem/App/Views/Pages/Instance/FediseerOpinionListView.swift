//
//  FediseerOpinionListView.swift
//  Mlem
//
//  Created by Sjmarf on 04/02/2024.
//

import MlemMiddleware
import SwiftUI

struct FediseerOpinionListView: View {
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
                }
            }
            .padding(16)
        }
        .background(.themedGroupedBackground)
        .navigationTitle(opinionType.label)
    }
}
