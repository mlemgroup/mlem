//
//  FediseerOpinionListView.swift
//  Mlem
//
//  Created by Sjmarf on 04/02/2024.
//

import SwiftUI

struct FediseerOpinionListView: View {
    let instance: InstanceModel
    let opinionType: FediseerOpinionType
    let fediseerData: FediseerData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let items = fediseerData.opinions(ofType: opinionType).sorted {
                    $0.reason != nil && $1.reason == nil
                }
                
                ForEach(items, id: \.domain) { opinion in
                    FediseerOpinionView(opinion: opinion)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(opinionType.label)
        .fancyTabScrollCompatible()
    }
}
