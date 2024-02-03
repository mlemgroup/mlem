//
//  EndorsementView.swift
//  Mlem
//
//  Created by Sam Marfleet on 03/02/2024.
//

import SwiftUI

struct FediseerOpinionView: View {
    let opinion: any FediseerOpinion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let model = opinion.instanceModel {
                    NavigationLink(value: AppRoute.instance(model)) { title }
                    .buttonStyle(.plain)
                } else {
                    title
                }
                Spacer()
            }
            .foregroundStyle(type(of: opinion).color)
            .padding(.horizontal)
            .padding(.vertical, 10)
            if let reason = opinion.formattedReason {
                divider
                MarkdownView(text: reason, isNsfw: false)
                    .padding(.trailing)
                    .padding(.vertical, 10)
            }
            if let evidence = opinion.evidence {
                divider
                MarkdownView(text: evidence, isNsfw: false)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .font(.callout)
    }
    
    @ViewBuilder
    var title: some View {
        Image(systemName: type(of: opinion).systemImage)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
        Text(opinion.domain)
            .fontWeight(.semibold)
    }
    
    @ViewBuilder
    var divider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(height: 2)
            .foregroundStyle(Color(uiColor: .systemGroupedBackground))
    }
}
