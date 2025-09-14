//
//  SearchHomeView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-14.
//

import ComponentViews
import Icons
import SwiftUI
import Theming

struct SearchHomeView: View {
    @Environment(\.navigation) var navigation
    @Environment(\.palette) var palette
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Visit Again")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            topRow
            
            Text("Browse")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, -4)
            browseList
                .padding(.top, 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    var topRow: some View {
        VStack {
            NavigationLink(.savedFeed) {
                FormChevron {
                    HStack(spacing: 15) {
                        Image(icon: .lemmy.savedFeed)
                            .symbolVariant(.fill)
                            .foregroundStyle(.white)
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .padding(10)
                            .background(.themedSavedFeed.gradient(palette: palette), in: .circle)
                        Text("Saved")
                        
                        Spacer()
                    }
                }
            }
            .buttonStyle(.empty)
        }
        .padding(10)
        .background(.themedBackground, in: .rect(cornerRadius: 25))
    }
    
    @ViewBuilder
    var browseList: some View {
        HStack(alignment: .center, spacing: UIDevice.isPad ? 30 : 0) {
            ListRowButton(
                title: "Communities",
                icon: .lemmy.community,
                destination: .topCommunities,
                color: .themedCommunityAccent
            )
            
            if !UIDevice.isPad {
                Spacer()
            }
            
            ListRowButton(
                title: "Users",
                icon: .lemmy.person,
                destination: .topPeople,
                color: .themedPersonAccent
            )
            
            if !UIDevice.isPad {
                Spacer()
            }
            
            ListRowButton(
                title: "Instances",
                icon: .lemmy.instance,
                destination: .topInstances,
                color: .themedColorfulAccent(1)
            )
            
            if UIDevice.isPad {
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var browseGrid: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            GridButton(title: "Top Communities", color: .themedCommunityAccent)
            GridButton(title: "Trending Communities", color: .themedColorfulAccent(0))
            GridButton(title: "Users", color: .themedPersonAccent)
            GridButton(title: "Instances", color: .themedColorfulAccent(1))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, -4)
    }
}

private struct ListRowButton: View {
    @Environment(\.navigation) var navigation
    @Environment(\.palette) var palette
    
    let title: LocalizedStringResource
    let icon: Icon
    let destination: NavigationPage
    let color: ThemedColor
    
    var body: some View {
        Button {
            navigation?.push(destination)
        } label: {
            VStack {
                Image(icon: icon)
                    .resizable()
                    .foregroundStyle(.white)
                    .symbolVariant(.fill)
                    .padding(20)
                    .background(color.gradient(palette: palette), in: .circle)
                    .frame(width: 80, height: 80)
                Text(title)
                    .fontWeight(.semibold)
                    .font(.subheadline)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct GridButton: View {
    @Environment(\.palette) var palette
    
    let title: LocalizedStringResource
    let color: ThemedColor
    
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
        .background(color.resolve(with: palette).gradient)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 4)
        .onTapGesture {}
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
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
