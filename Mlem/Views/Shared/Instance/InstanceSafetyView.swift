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
    
    @State var showingInfoSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section { guarantorView }
                .padding(.top, 16)
            
            HStack {
                Button("Learn more...") { showingInfoSheet = true }
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
            .foregroundStyle(.blue)
            .padding(.horizontal, 6)
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
        .sheet(isPresented: $showingInfoSheet) {
            NavigationStack {
                FediseerInfoView()
                    .toolbar {
                        CloseButtonView()
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
                        let route: AppRoute = .instanceFediseerOpinionList(instance, data: fediseerData, type: opinionType)
                        opinionSubheading(
                            title: opinionType.label,
                            count: items.count,
                            route: items.count > 5 ? route : nil
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
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppConstants.largeItemCornerRadius)
        }
    }
    
    @ViewBuilder
    func opinionSubheading(title: String, count: Int, route: AppRoute? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                (Text(title) + Text(" (\(count))").foregroundColor(.secondary))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                if let route {
                    NavigationLink("See All", value: route)
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 6)
    }
}
