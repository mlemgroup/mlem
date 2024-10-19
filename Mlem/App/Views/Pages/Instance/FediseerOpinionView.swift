//
//  EndorsementView.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import LemmyMarkdownUI
import SwiftUI

struct FediseerOpinionView: View {
    @Environment(Palette.self) var palette
    
    let opinion: any FediseerOpinion
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                if let stub = opinion.instanceStub {
                    NavigationLink(.instance(stub)) { title }
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
                Markdown(reason, configuration: .default)
                    .padding(.horizontal)
            } else {
                Text("No reason given")
                    .foregroundStyle(palette.secondary)
                    .italic()
                    .padding(.leading)
            }
            if let evidence = opinion.evidence {
                divider
                Markdown(evidence, configuration: .default)
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
            .foregroundStyle(.secondary) // Don't use palette here
        Text(opinion.domain)
            .fontWeight(.semibold)
    }
    
    @ViewBuilder
    var divider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(height: 2)
            .foregroundStyle(palette.groupedBackground)
    }
}
