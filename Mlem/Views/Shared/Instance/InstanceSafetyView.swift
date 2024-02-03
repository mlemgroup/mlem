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
    let fediseerData: FediseerInstance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { guarantorView }
            .padding(.top, 16)
            
            Text("Learn more...")
                .font(.footnote)
                .foregroundStyle(.blue)
                .padding(.leading, 6)
                .padding(.top, 5)
                .padding(.bottom, 30)
            
            HStack(spacing: 0) {
                subHeading("Endorsements")
                Spacer()
                Button("See All") { }
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                    .padding(.trailing, 6)
            }
            footnote("\(instance.name) received 5 endorsements from other instances.")
                .padding(.top, 3)
                .padding(.leading, 6)
                .padding(.bottom, 6)
            
            section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "signature")
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text("lemmy.ml")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .foregroundStyle(.teal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(height: 2)
                        .foregroundStyle(Color(uiColor: .systemGroupedBackground))
                    Text("Well moderated, friendly")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity)
                .font(.callout)
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
                if fediseerData.guarantor != nil {
                    Label("Guaranteed", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.indigo)
                } else {
                    Label("Unguaranteed", systemImage: "xmark.seal.fill")
                }
            }
            .fontWeight(.semibold)
            .font(.title2)
            Text(summaryCaption)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
    }
    
    var summaryCaption: String {
        if let guarantor = fediseerData.guarantor {
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
