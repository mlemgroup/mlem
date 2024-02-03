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
            
            let endorsements = fediseerData.topEndorsements.prefix(5)
            if !endorsements.isEmpty {
                
                HStack(spacing: 0) {
                    subHeading("Endorsements")
                    Spacer()
                    if fediseerData.instance.endorsements > 5 {
                        Button("See All") { }
                            .foregroundStyle(.blue)
                            .buttonStyle(.plain)
                            .padding(.trailing, 6)
                    }
                }
                
                footnote("\(instance.name) received \(fediseerData.instance.endorsements) endorsements.")
                    .padding(.top, 3)
                    .padding(.leading, 6)
                    .padding(.bottom, 8)
                
                ForEach(endorsements, id: \.domain) { endorsement in
                    section { EndorsementView(endorsement: endorsement) }
                        .padding(.bottom, 16)
                }
            }
            
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
    var guarantorView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if fediseerData.instance.guarantor != nil {
                    Label("Guaranteed", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Label("Not Guaranteed", systemImage: "xmark.seal.fill")
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
            return "\(instance.name) was admitted to the Fediseer Chain of Trust by \(guarantor)."
        } else {
            return "This instance is not part of the Fediseer Chain of Trust."
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
    func subHeading(_ title: String) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.title2)
        }
        .fontWeight(.semibold)
        .padding(.leading, 6)
    }
    
    @ViewBuilder
    func footnote(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
