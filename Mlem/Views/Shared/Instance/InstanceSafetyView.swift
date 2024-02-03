//
//  InstanceSafetyView.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

struct InstanceSafetyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let instance: InstanceModel
    let fediseerData: FediseerData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { guarantorView }
            .padding(.top, 16)
            
            Text("Learn more...")
                .font(.footnote)
                .foregroundStyle(.blue)
                .padding(.leading, 6)
                .padding(.top, 7)
                .padding(.bottom, 30)
            
            opinionsView
            if colorScheme == .light {
                Divider()
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    @ViewBuilder
    var opinionsView: some View {
        VStack(spacing: 14) {
            let opinionTypes = FediseerOpinionType.allCases.sorted { fediseerData.numberOf($0) > fediseerData.numberOf($1) }
            ForEach(opinionTypes, id: \.self) { opinionType in
                switch opinionType {
                case .endorsement:
                    endorsementsView
                case .hesitation:
                    hesitationsView
                case .censure:
                    censuresView
                }
            }
        }
    }
    
    @ViewBuilder
    var guarantorView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if fediseerData.instance.guarantor != nil {
                    Label("Guaranteed", systemImage: Icons.fediseerGuarantee)
                        .foregroundStyle(.green)
                } else if fediseerData.censures?.isEmpty ?? true {
                    Label("Not Guaranteed", systemImage: Icons.fediseerUnguarantee)
                        .foregroundStyle(.secondary)
                } else {
                    Label("Censured", systemImage: Icons.fediseerCensure)
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .fontWeight(.semibold)
            .font(.title2)
            Text(summaryCaption)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal)
    }

    var summaryCaption: String {
        if let guarantor = fediseerData.instance.guarantor {
            return "\(instance.name) is guaranteed by \(guarantor)."
        } else if fediseerData.censures?.isEmpty ?? true {
            return "This instance is not part of the Fediseer Chain of Trust."
        } else {
            return "This instance is viewed very negatively by one or more trusted instances."
        }
    }
    
    @ViewBuilder
    var endorsementsView: some View {
        let endorsements = fediseerData.topEndorsements.prefix(5)
        if !endorsements.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                opinionSubheading(
                    title: "Endorsements",
                    caption: "\(instance.name) is endorsed by ^[\(fediseerData.instance.endorsements) instance](inflect: true)."
                )
                ForEach(endorsements, id: \.domain) { endorsement in
                    section { FediseerOpinionView(opinion: endorsement) }
                        .padding(.bottom, 16)
                }
            }
        }
    }
    
    @ViewBuilder
    var hesitationsView: some View {
        if let hesitations = fediseerData.hesitations?.prefix(5) {
            if !hesitations.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    opinionSubheading(
                        title: "Hesitations",
                        caption: "\(instance.name) is hesitated on by ^[\(hesitations.count) instance](inflect: true)."
                    )
                    ForEach(hesitations, id: \.domain) { hesitation in
                        section { FediseerOpinionView(opinion: hesitation) }
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var censuresView: some View {
        if let censures = fediseerData.censures?.prefix(5) {
            if !censures.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    opinionSubheading(
                        title: "Censures",
                        caption: "\(instance.name) is censured by ^[\(censures.count) instance](inflect: true)."
                    )
                    ForEach(censures, id: \.domain) { censure in
                        section { FediseerOpinionView(opinion: censure) }
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func section(_ title: String? = nil, spacing: CGFloat = 5, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title {
                subHeading(title)
            }
            VStack(alignment: .leading, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
        }
    }
    
    @ViewBuilder
    func opinionSubheading(title: String, caption: LocalizedStringKey, route: AppRoute? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                subHeading(title)
                Spacer()
                if let route {
                    NavigationLink("See All", value: route)
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                        .padding(.trailing, 6)
                }
            }
            footnote(caption)
                .padding(.top, 3)
                .padding(.leading, 6)
                .padding(.bottom, 8)
        }
    }
    @ViewBuilder
    func subHeading(_ title: String) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.title2)
        }
        .fontWeight(.semibold)
        .padding(.leading, 6)
    }
    
    @ViewBuilder
    func footnote(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
