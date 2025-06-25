//
//  SubscriptionListView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import Icons
import MlemMiddleware
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct SubscriptionListView: View {
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    @Environment(TabReselectTracker.self) var tabReselectTracker
    
    @Setting(\.subscriptions_sort) private var sort
    
    @State var noDetail: Bool = false
    
    var feedOptions: [FeedSelection] {
        FeedSelection.cases(for: appState.firstAccount.accountType)
    }
    
    @State var sectionScroller: Int = 0
    @State var errorDetails: ErrorDetails?
    
    @Weak var form: UICollectionView?
    
    var body: some View {
        content
            .listStyle(.sidebar)
            .navigationTitle("Feeds")
    }
    
    var detailDisplayed: Bool {
        if UIDevice.isPad {
            noDetail ? false : navigation.path.isEmpty
        } else {
            navigation.path.isEmpty
        }
    }
    
    @ViewBuilder
    var content: some View {
        let sections = subscriptions?.visibleSections(sort: sort) ?? []
        
        Form {
            Section {
                ForEach(feedOptions, id: \.hashValue) { feedOption in
                    SubscriptionListNavigationButton(.feeds(feedOption)) {
                        HStack(spacing: 15) {
                            FeedIconView(
                                feedDescription: feedOption.description,
                                size: appState.firstSession is GuestSession ? 36 : 28
                            )
                            VStack(alignment: .leading) {
                                Text(feedOption.description.label)
                                if appState.firstSession is GuestSession {
                                    Text(feedOption.description.subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(.themedSecondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                }
            }
            
            if AccountsTracker.main.isEmpty {
                Section {
                    signedOutInfoView
                        .listRowBackground(Color.clear)
                }
            }
            if let errorDetails {
                Section {
                    ErrorView(errorDetails)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            } else {
                ForEach(sections) { section in
                    SubscriptionListSectionView(section: section, sectionIndicesShown: sectionIndicesShown)
                        .id(section.label)
                }
                .scrollTargetLayout()
            }
        }
        .introspect(.form, on: .iOS(.v17, .v18)) { introspectedForm in
            form = introspectedForm
        }
        .onChange(of: sectionScroller) {
            form?.scrollToItem(at: .init(row: 0, section: sectionScroller), at: .centeredVertically, animated: false)
        }
        .foregroundStyle(.themedPrimary)
        .overlay(alignment: .trailing) {
            if sectionIndicesShown {
                SectionIndexTitles(
                    sections: sections,
                    sectionScroller: $sectionScroller
                )
            }
        }
        .toolbar {
            if !(subscriptions?.communities.isEmpty ?? true) {
                Picker("Sort", selection: $sort) {
                    ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                        Label(String(localized: item.label), systemImage: item.systemImage)
                    }
                }
            }
        }
        .onChange(of: tabReselectTracker.flag) {
            // normal reselect tracker does not work here thanks to NavigationSplitView, so we need to implement a custom one
            if detailDisplayed, tabReselectTracker.flag {
                tabReselectTracker.reset()
                form?.scrollToItem(at: .init(row: 0, section: 0), at: .bottom, animated: true)
            }
        }
        .onChange(of: (appState.firstSession as? UserSession)?.subscriptionListErrorDetails) {
            if let details = (appState.firstSession as? UserSession)?.subscriptionListErrorDetails {
                errorDetails = details
            }
        }
        .scrollIndicators(sectionIndicesShown ? .hidden : .visible)
        .refreshable {
            do {
                try await subscriptions?.refresh()
                errorDetails = nil
            } catch {
                errorDetails = handleErrorWithDetails(error)
            }
        }
        .background(.themedBackground)
    }
    
    @ViewBuilder
    var signedOutInfoView: some View {
        VStack {
            Image(systemName: "list.bullet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(.themedTertiary)
                .padding(.bottom, 5)
            Text("Your subscriptions live here.")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Log in or sign up to view your subscriptions.")
            HStack {
                Button {
                    navigation.openSheet(.logIn(.pickInstance))
                } label: {
                    Text("Log In")
                        .frame(minWidth: 80)
                }
                Button {
                    navigation.openSheet(.signUp())
                } label: {
                    Text("Sign Up")
                        .frame(minWidth: 80)
                }
            }
            .tint(.themedSecondary)
            .buttonStyle(.bordered)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .foregroundStyle(.themedSecondary)
    }
    
    var subscriptions: SubscriptionList? {
        (appState.firstSession as? UserSession)?.subscriptions
    }
    
    var sectionIndicesShown: Bool {
        !UIDevice.isPad && sort == .alphabetical && (subscriptions?.communities.count ?? 0) > 10
    }
}

private struct SubscriptionListSectionView: View {
    let section: SubscriptionListSection
    let sectionIndicesShown: Bool
    
    var body: some View {
        Section(section.label) {
            ForEach(section.communities) { (community: Community2) in
                SubscriptionListItemView(
                    community: community,
                    section: section,
                    sectionIndicesShown: sectionIndicesShown
                )
            }
        }
    }
}

enum SubscriptionListSort: String, CaseIterable, Codable {
    case alphabetical
    case instance
    
    var label: LocalizedStringResource {
        switch self {
        case .alphabetical: "Name"
        case .instance: "Instance"
        }
    }
    
    var systemImage: String {
        switch self {
        case .alphabetical: "textformat"
        case .instance: "at"
        }
    }
}

struct SubscriptionListSection: Identifiable {
    let label: String
    var icon: Icon?
    let communities: [Community2]
    
    var id: String { label }
}

private extension SubscriptionList {
    func visibleSections(sort: SubscriptionListSort) -> [SubscriptionListSection] {
        var sections: [SubscriptionListSection] = .init()
        if !favorites.isEmpty {
            sections.append(.init(label: String(localized: "Favorites"), icon: .lemmy.favorited, communities: favorites))
        }
        switch sort {
        case .alphabetical:
            for section in alphabeticSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? "#", communities: section.value))
            }
        case .instance:
            for section in instanceSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? String(localized: "Other"), communities: section.value))
            }
        }
        
        return sections
    }
}
