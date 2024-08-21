//
//  PostComposerTargetView.swift
//  Mlem
//
//  Created by Sjmarf on 14/08/2024.
//

import MlemMiddleware
import SwiftUI

struct PostEditorTargetView: View {
    @Environment(NavigationLayer.self) private var navigation
    @Environment(Palette.self) private var palette
    
    @Bindable var target: PostEditorTarget
    
    var body: some View {
        Grid(
            alignment: .center,
            horizontalSpacing: 8,
            verticalSpacing: 8
        ) {
            GridRow {
                Image(systemName: Icons.communityFill)
                    .foregroundStyle(palette.secondary)
                    .fontWeight(.semibold)
                communityPicker
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if AccountsTracker.main.userAccounts.count > 1 {
                GridRow {
                    Image(systemName: Icons.personFill)
                        .foregroundStyle(palette.secondary)
                        .fontWeight(.semibold)
                    accountPicker
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .task(id: target.account, resolveCommunity)
                }
            }
        }
        .font(.footnote)
        .padding(.leading, 15)
    }
    
    @ViewBuilder
    var communityPicker: some View {
        Button {
            navigation.openSheet(.communityPicker(
                api: target.account.api,
                callback: { target.community = .init($0) }
            ))
        } label: {
            if let community = target.community as? any Community {
                FullyQualifiedLabelView(
                    entity: community,
                    labelStyle: .small
                )
                .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                .background(palette.secondaryBackground, in: .capsule)
            } else if let community = target.community {
                FullyQualifiedNameView(name: community.name, instance: community.host, instanceLocation: .trailing)
                    .task {
                        do {
                            target.community = try await community.upgrade()
                        } catch {
                            handleError(error)
                        }
                    }
            } else {
                Text("Choose a community...")
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .background(palette.secondaryBackground, in: .capsule)
            }
        }
    }
    
    @ViewBuilder
    var accountPicker: some View {
        HStack {
            AccountPickerMenu(account: $target.account) {
                FullyQualifiedLabelView(
                    entity: target.account,
                    labelStyle: .small
                )
                .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 8))
                .background(palette.secondaryBackground, in: .capsule)
            }
            switch target.resolutionState {
            case .notFound, .error:
                Image(systemName: Icons.warningFill)
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(palette.caution)
                    .fontWeight(.semibold)
            default:
                EmptyView()
            }
        }
    }
    
    @Sendable
    @MainActor
    func resolveCommunity() async {
        guard target.community?.api !== target.account.api else { return }
        guard let community = target.community else { return }
        
        target.resolutionState = .resolving
        do {
            let newCommunity: Community2 = try await target.account.api.getCommunity(actorId: community.actorId)
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
    
    var community: (any CommunityStubProviding)?
    var account: UserAccount
    let id = UUID()
    
    var resolutionState: ResolutionState = .success
    
    init(community: (any CommunityStubProviding)? = nil, account: UserAccount) {
        self.community = community
        self.account = account
    }
}
