//
//  NavigationPage+View.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

extension NavigationPage {

    @ViewBuilder
    func sheetView(selectedDetent: Binding<PresentationDetent>) -> some View {
        if let presentationDetentConfiguration {
            view()
                .presentationDetents(configuration: presentationDetentConfiguration, selection: selectedDetent)
        } else {
            view()
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    @ViewBuilder func view() -> some View {
        switch self {
        case .subscriptionList:
            SubscriptionListView()
        case let .selectText(string):
            SelectTextView(text: string)
        case let .shareInstancePicker(sharable):
            ShareInstancePickerView(entity: sharable.wrappedValue)
        case let .settings(page):
            page.view()
        case let .logIn(page):
            page.view()
        case let .signUp(instance):
            SignUpView(instance: instance.wrappedValue)
        case .onboarding:
            OnboardingView()
        case let .feeds(listingType):
            FeedsView(listingType: listingType)
        case .savedFeed:
            VisitAgainView(filter: .saved)
        case .upvotedFeed:
            VisitAgainView(filter: .upvoted)
        case .topCommunities:
            TopCommunitiesListView()
        case .topPeople:
            TopPeopleListView()
        case .topInstances:
            TopInstancesListView()
        case let .community(community, visitContext):
            CommunityView(community: community, visitContext: visitContext)
        case .profile:
            ProfileView()
        case .inbox:
            InboxView()
        case .testInbox:
            TestInboxView()
        case .search:
            SearchView()
        case let .externalApiInfo(api: api, actorId: actorId):
            ExternalApiInfoView(api: api, actorId: actorId)
        case let .imageViewer(url):
            ImageViewer(url: url)
        case .quickSwitcher:
            QuickSwitcherView()
        case let .report(target, community):
            ReportEditorView(target: target.wrappedValue, community: community)
        case let .remove(target):
            ContentRemovalEditorView(target: target.wrappedValue)
        case let .purge(target):
            ContentPurgeEditorView(target: target.wrappedValue)
        case let .ban(person, isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: community):
            if let person = person.wrappedValue as? any Person {
                PersonBanEditorView(
                    person: person,
                    community: community?.wrappedValue as? any Community,
                    isBannedFromCommunity: isBannedFromCommunity,
                    shouldBan: shouldBan
                )
            } else {
                Text(verbatim: "Error")
            }
        case let .post(post, scrollTargetedComment, communityContext, _):
            ExpandedPostView(post: post, tracker: nil, scrollTargetedComment: scrollTargetedComment?.wrappedValue)
                .environment(\.communityContext, communityContext?.wrappedValue)
        case let .postStub(post, _):
            PostStubResolutionPage(stub: post.wrappedValue)
        case let .comment(comment, comments: comments, showViewPostButton, exposeRemovedContent):
            CommentPage(
                comment: comment,
                initialComments: comments,
                showViewPostButton: showViewPostButton,
                exposeRemovedContent: exposeRemovedContent
            )
        case let .person(person, visitContext):
            PersonView(person: person, visitContext: visitContext)
        case let .createComment(context, commentTreeTracker):
            if let view = CommentEditorView(context: context, commentTreeTracker: commentTreeTracker) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
        case let .editComment(comment, context: context):
            if let view = CommentEditorView(commentToEdit: comment, context: context) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
        case let .editCommunity(community):
            CommunityDescriptionEditorView(community: community)
        case let .editNote(person):
            NoteEditorView(person: person.wrappedValue)
        case let .createPost(
            community: community,
            title: title,
            content: content,
            type: type,
            nsfw: nsfw,
            feedLoader: feedLoader
        ):
            if let view = PostEditorView(
                community: community,
                title: title,
                content: content,
                type: type,
                nsfw: nsfw,
                feedLoader: feedLoader.wrappedValue
            ) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
        case let .editPost(post):
            PostEditorView(postToEdit: post, community: nil)
        case let .communityPicker(api: api, callback: callback):
            SearchSheetView(api: api) { (community: Community2, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(community, navigation)
                } label: {
                    CommunityListRowBody(community, readout: .subscribers)
                        .tint(.themedPrimary)
                        .padding(.vertical, 6)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                }
            }
        case let .personPicker(api: api, filter: filter, callback: callback):
            SearchSheetView(api: api, filter: filter) { (person: Person2, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(person, navigation)
                } label: {
                    PersonListRowBody(person)
                        .tint(.themedPrimary)
                        .padding(.vertical, 6)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                }
            }
        case let .instancePicker(callback: callback, requiredFeature: requiredFeature):
            SearchSheetView { (instance: InstanceSummary, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(instance, navigation)
                } label: {
                    InstanceListRowBody(instance)
                        .tint(.themedPrimary)
                        .padding(.vertical, 6)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                }
                .disabled(requiredFeature.map { !instance.software.supports($0) } ?? false)
            } header: {
                if requiredFeature != nil, requiredFeature != .signUp {
                    Text("This feature is not available on all instances.")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.themedCaution.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .foregroundStyle(.themedCaution)
                        .padding(.horizontal, Constants.main.standardSpacing)
                        .padding(.bottom, Constants.main.halfSpacing)
                } else if let errorDetails = MlemStats.main.errorDetails {
                    ErrorView(errorDetails)
                        .padding(.top, 40)
                }
            }
        case let .languagePicker(selectedLanguages: selectedLanguages, callback: callback):
            LanguagePickerSheetView(selectedLanguages: selectedLanguages, callback: callback.wrappedValue)
        case let .instance(instance, visitContext):
            InstanceView(instance: instance.wrappedValue, visitContext: visitContext)
        case let .instanceOpinionList(instance: instance, opinionType: opinionType, data: data):
            FediseerOpinionListView(instance: instance.wrappedValue, opinionType: opinionType, fediseerData: data)
        case .fediseerInfo:
            FediseerInfoView()
        case let .instanceUptime(instance, uptimeData):
            InstanceUptimeView(instance: instance.wrappedValue, uptimeData: uptimeData)
        case let .deleteAccount(account):
            DeleteAccountView(account: account)
        case let .bypassImageProxy(callback):
            BypassProxyWarningSheet(callback: callback.wrappedValue)
        case let .confirmUpload(imageData: imageData, fileExtension: fileExtension, imageManager: imageManager, uploadApi: uploadApi):
            UploadConfirmationView(
                imageData: imageData,
                fileExtension: fileExtension,
                imageManager: imageManager,
                uploadApi: uploadApi
            )
        case let .rulesList(model, callback):
            RulesPickerView(model: model.wrappedValue, callback: callback.wrappedValue)
        case .blockList:
            BlockListView()
        case let .advancedSorting(sort):
            AdvancedSortView(selectedSort: sort.wrappedValue)
        case let .votesList(target):
            VotesListView(target: target)
        case let .messageFeed(person, messageContent: messageContent, focusTextField: focusTextField, editing: editing):
            MessageFeedView(
                person: person,
                messageContent: messageContent,
                focusTextField: focusTextField,
                editing: editing?.wrappedValue
            )
        case let .modlog(target, targetPerson, moderatorPerson):
            ModlogView(initialTarget: target, targetPerson: targetPerson, moderatorPerson: moderatorPerson)
        case let .denyApplication(application):
            RegistrationApplicationDenialEditorView(application: application)
        case let .exportPostImage(post):
            ExportablePostEditorView(post: post.wrappedValue)
        case let .exportCommentImage(comment, tracker):
            ExportableCommentEditorView(comment: comment.wrappedValue, commentTreeTracker: tracker)
        case let .actionSheet(sections):
            ActionSheet(sections: sections.wrappedValue)
        }
    }
}
