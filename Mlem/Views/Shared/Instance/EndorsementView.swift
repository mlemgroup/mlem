//
//  EndorsementView.swift
//  Mlem
//
//  Created by Sam Marfleet on 03/02/2024.
//

import SwiftUI

struct EndorsementView: View {
    let endorsement: FediseerEndorsement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let model = endorsement.instanceModel {
                    NavigationLink(value: AppRoute.instance(model)) { title }
                    .buttonStyle(.plain)
                } else {
                    title
                }
                Spacer()
            }
            .foregroundStyle(.teal)
            .padding(.horizontal)
            .padding(.vertical, 10)
            if let reason = endorsement.formattedReason {
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(height: 2)
                    .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                MarkdownView(text: reason, isNsfw: false)
                    .padding(.trailing)
                    .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .font(.callout)
    }
    
    @ViewBuilder
    var title: some View {
        Image(systemName: "signature")
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
        Text(endorsement.domain)
            .fontWeight(.semibold)
    }
}
