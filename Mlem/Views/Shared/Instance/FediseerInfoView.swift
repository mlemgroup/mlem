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
        ScrollView {
            subHeading("The Fediseer", systemImage: Icons.fediseer, color: .indigo)
            Text("The Fediseer is a service that instance administrators use to identify spam instances. Additionally, it provides a platform for instance administrators to express their approval or disapproval of other instances.")
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
            subHeading("Guarantees", systemImage: Icons.fediseerGuarantee, color: .green)
            Text("If an instance is \"guaranteed\", it is known as definitely not spam. This doesn't mean that an instance that isn't guaranteed is definitely spam - rather, it is unknown whether an unguaranteed instance is spam or not.\n\nAn instance can be guaranteed by any other guaranteed instance. This forms a chain of instances who guarantee one another, which is known as the \"Chain of Trust\". The Chain of Trust starts at the Fediseer itself, which guarantees several of the largest instances.\n\nA guarantee can be revoked by the guarantor at any time - if this happens, the instance returns to a \"not guaranteed\" state, and any instances it may have guaranteed also return to a \"not guaranteed\" state.\n\nOnce an instance has been guaranteed, they are able to express their approval or disapproval of other instances using endorsements, hesitations and censures.")
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
            subHeading("Endoresements", systemImage: Icons.fediseerEndorsement, color: .teal)
            Text("An endorsement signifies that an instance approves of another instance. It is completely subjective, and a reason does not have to be given.")
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
            subHeading("Censures", systemImage: Icons.fediseerCensure, color: .red)
            Text("A censure signifies that an instance disapproves of another instance. Like an endorsement, it is completely subjective and a reason does not have to be given.")
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
            subHeading("Hesitations", systemImage: Icons.fediseerHesitation, color: .yellow)
            Text("A hesitation signifies that an instance mistrusts another instance. It is a milder version of a censure.")
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
            subHeading("More Info", systemImage: "book.fill", color: .blue)
            Link(destination: URL(string: "https://fediseer.com/faq/eng")!) {
                Label("Fediseer FAQ", systemImage: "questionmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            Link(destination: URL(string: "https://liberapay.com/Fediseer/")!) {
                Label("Donate to the Fediseer", systemImage: "dollarsign.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func subHeading(_ title: String, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.title2)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            Divider()
        }
        .padding(.top, 20)
    }
}
// swiftlint:enable line_length
