//
//  PostEditorTargetView.swift
//  Mlem
//
//  Created by Sjmarf on 14/08/2024.
//

import MlemMiddleware
import SwiftUI

struct PostEditorTargetView: View {
    @Environment(NavigationLayer.self) private var navigation
    
    @Bindable var target: PostEditorTarget
    let isMoreThanOneTarget: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: Constants.main.standardSpacing) {
                if AccountsTracker.main.userAccounts.count > 1 {
                    communityPicker
                        .frame(maxWidth: .infinity, alignment: .leading)
                    accountPicker
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                } else {
                    communityPicker
                }
            }
            if isMoreThanOneTarget {
                switch target.sendState {
                case .unsent:
                    EmptyView()
                case .sent:
                    Image(systemName: Icons.successCircleFill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.themedPositive)
                case .failed:
                    Image(systemName: Icons.errorCircleFill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.themedne)
                }
            }
        }
    }
    
    @ViewBuilder
    var communityPicker: some View {
        Button {
            navigation.openSheet(.communityPicker(
                api: target.account.api,
                callback: { target.community = .init($0) }
            ))
        } label: {
            let singleAccount = AccountsTracker.main.userAccounts.count == 1
            HStack(spacing: 0) {
                if let community = target.community as? any Community {
                    FullyQualifiedLabelView(community, labelStyle: singleAccount ? .medium : .large)
                } else if let community = target.community {
                    FullyQualifiedNameView(name: nil, instance: nil, instanceLocation: .trailing)
                        .task {
                            do {
                                target.community = try await community.upgrade()
                            } catch {
                                handleError(error)
                            }
                        }
                } else {
                    HStack(spacing: 7) {
                        Image(systemName: Icons.communityCircleFill)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(
                                width: singleAccount ? Constants.main.mediumAvatarSize : Constants.main.largeAvatarSize
                            )
                            .symbolRenderingMode(.hierarchical)
                        Text("Choose a community...")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .environment(\._lineHeightMultiple, 0.8)
                            .offset(y: 1)
                    }
                }
                if !singleAccount || isMoreThanOneTarget {
                    Spacer()
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        }
    }
    
    @ViewBuilder
    var accountPicker: some View {
        HStack {
            AccountPickerMenu(account: $target.account) {
                FullyQualifiedLabelView(target.account, labelStyle: .large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
            }
            switch target.resolutionState {
            case .notFound, .error:
                Image(systemName: Icons.warningFill)
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.themedCaution)
                    .fontWeight(.semibold)
            default:
                EmptyView()
            }
        }
    }
    
    @MainActor
    func resolveCommunity() async {
        guard target.community?.api !== target.account.api else { return }
        guard let community = target.community else { return }
        
        target.resolutionState = .resolving
        do {
            let newCommunity: Community2 = try await target.account.api.getCommunity(url: community.allResolvableUrls[0])
            target.community = newCommunity
            target.resolutionState = .success
        } catch ApiClientError.noEntityFound {
            target.resolutionState = .notFound
        } catch {
            target.resolutionState = .error(.init(error: error))
        }
    }
}

@Observable
class PostEditorTarget: Identifiable {
    enum ResolutionState: Equatable {
        case success, notFound, error(ErrorDetails), resolving
    }
    
    enum SendState: Equatable {
        case unsent, sent, failed
    }
    
    var community: (any CommunityStubProviding)?
    var account: UserAccount {
        didSet {
            slurRegex_ = nil
            onAccountChange()
        }
    }

    let id = UUID()
    
    var resolutionState: ResolutionState = .success
    var sendState: SendState = .unsent
    
    var onAccountChange: () -> Void
    
    private var slurRegex_: Regex<AnyRegexOutput>?
    var slurRegex: Regex<AnyRegexOutput>? {
        get async throws {
            if let slurRegex_ { return slurRegex_ }
            slurRegex_ = try await account.api.getMyInstance().slurRegex()
            return slurRegex_
        }
    }
    
    init(
        community: (any CommunityStubProviding)? = nil,
        account: UserAccount,
        onAccountChange: @escaping () -> Void = {}
    ) {
        self.community = community
        self.account = account
        self.slurRegex_ = account.api.myInstance?.slurRegex()
        self.onAccountChange = onAccountChange
    }
    
    /// If this target matches the given feedLoader, prepends the given post
    func prepend(post: Post2, to feedLoader: (any FeedLoading)?) {
        guard let feedLoader else { return }
        
        if let community,
           let communityFeedLoader = feedLoader as? CommunityPostFeedLoader,
           communityFeedLoader.community.actorId == community.actorId_ {
            Task { @MainActor in
                withAnimation {
                    communityFeedLoader.prependItem(post)
                }
            }
            return
        }
        
        if let personContentFeedLoader = feedLoader as? PersonContentFeedLoader,
           personContentFeedLoader.userId == account.id,
           personContentFeedLoader.api == account.api {
            Task { @MainActor in
                withAnimation {
                    personContentFeedLoader.prependItem(.init(wrappedValue: .post(post)))
                }
            }
            return
        }
    }
}
