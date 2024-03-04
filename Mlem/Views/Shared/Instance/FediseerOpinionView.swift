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
        VStack(alignment: .leading, spacing: 10) {
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
            divider
            if let reason = opinion.formattedReason {
                MarkdownView(text: reason, isNsfw: false)
                    .padding(.trailing)
            } else {
                Text("No reason given")
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.leading)
            }
            if let evidence = opinion.evidence {
                divider
                MarkdownView(text: evidence, isNsfw: false)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
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
