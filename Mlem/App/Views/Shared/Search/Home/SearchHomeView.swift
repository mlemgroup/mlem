//
//  SearchHomeView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-14.
//

import SwiftUI

struct SearchHomeView: View {
    @Environment(\.navigation) var navigation
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30)
            topRow
            Text("Browse")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                .padding(.bottom, -4)
            browseGrid
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    var topRow: some View {
        HStack(spacing: 16) {
            Button("Saved", icon: .lemmy.saved) {
                navigation?.push(.savedFeed)
            }
            Button("History", icon: .general.time) {
                navigation?.push(.historyFeed)
            }
        }
        .buttonStyle(CapsuleButtonStyle())
    }
    
    @ViewBuilder
    var browseGrid: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            GridButton(title: "Communities")
            GridButton(title: "Users")
            GridButton(title: "Instances")
            GridButton(title: "Communities")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, -4)
    }
}

private struct GridButton: View {
    let title: LocalizedStringResource
    
    var body: some View {
        ZStack {
            Text(title)
                .foregroundStyle(.themedContrastingLabel)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
        }
        .aspectRatio(5 / 3, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(.red)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 4)
    }
}

private struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.themedAccent)
            .padding(.vertical, 10)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .background(.themedSecondaryGroupedBackground, in: .capsule)
            .symbolVariant(.fill)
    }
}
