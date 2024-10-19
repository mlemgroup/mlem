//
//  FediseerInfoView.swift
//  Mlem
//
//  Created by Sjmarf on 04/02/2024.
//

import SwiftUI

// swiftlint:disable line_length
struct FediseerInfoView: View {
    var body: some View {
        FancyScrollView {
            VStack(alignment: .leading) {
                subHeading("The Fediseer", systemImage: Icons.fediseer, color: .indigo)
                Text("The Fediseer is a service that instance administrators use to identify spam instances and express their approval or disapproval of other instances.")
                    .padding(.horizontal, Constants.main.standardSpacing)
                subHeading("Guarantees", systemImage: Icons.fediseerGuarantee, color: .green)
                Text("If an instance is \"guaranteed\", it is known as definitely not spam. Unguaranteed instances are not necessarily spam; rather, it is unknown whether a non-guaranteed instance is spam or not.\n\nAn instance can be guaranteed by any other guaranteed instance. This forms a chain of guaranteed instances known as the \"Chain of Trust\". The Chain of Trust starts at the Fediseer itself, which guarantees several of the largest instances.\n\nA guarantee can be revoked by the guarantor at any time. If an instance's guarantee is revoked, it returns to a \"not guaranteed\" state along with any instances it guarantees.\n\nOnce an instance has been guaranteed, it is able to express its approval or disapproval of other instances using endorsements, hesitations and censures.")
                    .padding(.horizontal, Constants.main.standardSpacing)
                subHeading("Endorsements", systemImage: Icons.fediseerEndorsement, color: .teal)
                Text("An endorsement signifies that an instance approves of another instance. It is completely subjective, and a reason does not have to be given.")
                    .padding(.horizontal, Constants.main.standardSpacing)
                subHeading("Censures", systemImage: Icons.fediseerCensure, color: .red)
                Text("A censure signifies that an instance disapproves of another instance. Like an endorsement, it is completely subjective and a reason does not have to be given.")
                    .padding(.horizontal, Constants.main.standardSpacing)
                subHeading("Hesitations", systemImage: Icons.fediseerHesitation, color: .yellow)
                Text("A hesitation signifies that an instance mistrusts another instance. It is a milder version of a censure.")
                    .padding(.horizontal, Constants.main.standardSpacing)
                Divider()
                    .padding(.top, 20)
                linkButton(
                    "Fediseer FAQ",
                    systemImage: "questionmark.circle.fill",
                    destination: URL(string: "https://fediseer.com/faq/eng")!
                )
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            CloseButtonView()
        }
    }
    
    @ViewBuilder
    func subHeading(_ title: LocalizedStringResource, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.title2)
            .padding(.horizontal, Constants.main.standardSpacing)
            Divider()
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    func linkButton(_ title: String, systemImage: String, destination: URL) -> some View {
        Link(destination: destination) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                        .fill(Color(uiColor: .secondarySystemFill))
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Constants.main.standardSpacing)
    }
}

// swiftlint:enable line_length
