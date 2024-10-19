//
//  InstanceSafetyView.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import MlemMiddleware
import SwiftUI

struct InstanceSafetyView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    let instance: any Instance
    let fediseerData: FediseerData
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { guarantorView }
            HStack {
                Button("Learn more...") {
                    navigation.openSheet(.fediseerInfo)
                }
                .buttonStyle(.plain)
                Spacer()
                if let url = URL(string: "https://gui.fediseer.com/instances/detail/\(instance.name)") {
                    Link(destination: url) {
                        Text("Fediseer GUI")
                        Image(systemName: "arrow.up.forward")
                    }
                }
            }
            .font(.footnote)
            .foregroundStyle(.tint)
            .padding(.horizontal, 6)
            .padding(.top, 7)
            .padding(.bottom, 30)
            
            opinionsView
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    var guarantorView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if fediseerData.instance.guarantor != nil {
                    Label("Guaranteed", systemImage: Icons.fediseerGuarantee)
                        .foregroundStyle(palette.positive)
                } else if fediseerData.censures?.isEmpty ?? true {
                    Label("Not Guaranteed", systemImage: Icons.fediseerUnguarantee)
                        .foregroundStyle(palette.secondary)
                } else {
                    Label("Censured", systemImage: Icons.fediseerCensure)
                        .foregroundStyle(palette.negative)
                }
                Spacer()
            }
            .fontWeight(.semibold)
            .font(.title2)
            Text(summaryCaption)
                .foregroundColor(palette.secondary)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.main.standardSpacing)
        .padding(.horizontal)
    }
    
    var summaryCaption: String {
        if let guarantor = fediseerData.instance.guarantor {
            .init(localized: "\(instance.name) is guaranteed by \(guarantor).")
        } else if fediseerData.censures?.isEmpty ?? true {
            .init(localized: "This instance is not part of the Fediseer Chain of Trust.")
        } else {
            .init(localized: "This instance is viewed very negatively by one or more trusted instances.")
        }
    }
    
    @ViewBuilder
    var opinionsView: some View {
        VStack(spacing: 22) {
            let opinionTypes = FediseerOpinionType.allCases.sorted {
                fediseerData.opinions(ofType: $0).count > fediseerData.opinions(ofType: $1).count
            }
            ForEach(opinionTypes, id: \.self) { opinionType in
                let items = fediseerData.opinions(ofType: opinionType).sorted {
                    $0.reason != nil && $1.reason == nil
                }
                
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        let destination: NavigationPage = .instanceOpinionList(
                            instance,
                            opinionType: opinionType,
                            data: fediseerData
                        )
                        opinionSubheading(
                            title: opinionType.label,
                            count: items.count,
                            destination: items.count > 5 ? destination : nil
                        )
                        ForEach(items.prefix(5), id: \.domain) { item in
                            section { FediseerOpinionView(opinion: item) }
                                .padding(.bottom, 9)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder func section(spacing: CGFloat = 5, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            VStack(alignment: .leading, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity)
            .background(palette.secondaryGroupedBackground)
            .cornerRadius(Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func opinionSubheading(title: String, count: Int, destination: NavigationPage? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                (Text(title) + Text(verbatim: " (\(count))").foregroundColor(palette.secondary))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                if let destination {
                    NavigationLink("See All", destination: destination)
                        .foregroundStyle(.tint)
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 6)
    }
}
