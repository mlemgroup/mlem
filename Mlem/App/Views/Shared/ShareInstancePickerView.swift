//
//  ShareInstancePickerView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-09.
//

import MlemMiddleware
import SwiftUI

struct ShareInstancePickerView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    let entity: any Sharable
    
    @State private var sheetContentHeight: CGFloat = SheetHeightKey.defaultValue
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Share using...")
                    .fontWeight(.bold)
                    .foregroundStyle(.themedSecondary)
                    .padding(.leading, 8)
                Spacer()
                CloseButtonView()
            }
            VStack(spacing: 0) {
                instanceTargetRow(entity.api.host, label: "My Instance", url: entity.url())
                Divider()
                instanceTargetRow(entity.actorId.host, label: "Original Instance", url: entity.actorId.url)
            }
            .frame(maxWidth: .infinity)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
            chooseButtonView
        }
        .padding(16)
        .presentationBackground(.themedGroupedBackground)
        .overlay {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SheetHeightKey.self,
                    value: proxy.size.height
                )
            }
        }
        .onPreferenceChange(SheetHeightKey.self) { sheetContentHeight = $0 }
        .presentationDetents([.height(sheetContentHeight)])
    }
    
    @ViewBuilder
    func instanceTargetRow(_ host: String, label: LocalizedStringResource, url: URL) -> some View {
        Button {
            navigation.dismissSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                NavigationModel.main.shareInfo = .init(url: url, actions: entity.shareSheetActions())
            }
        } label: {
            HStack(spacing: 16) {
                CircleCroppedImageView(url: faviconUrl(for: url), frame: 42, fallback: .instance)
                VStack(alignment: .leading, spacing: 5) {
                    Text(host)
                        .foregroundStyle(.themedPrimary)
                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.themedSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    func faviconUrl(for instanceUrl: URL) -> URL? {
        guard let host = instanceUrl.host() else { return nil }
        let summary = MlemStats.main.instances?.first(where: { $0.host == host })
        return summary?.avatar?.withIconSize(128)
    }
    
    @ViewBuilder
    var chooseButtonView: some View {
        Button {
            let model = navigation.model
            navigation.dismissSheet()
            guard let model else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                model.openSheet(.instancePicker(callback: { instance in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        Task {
                            await resolveEntity(url: instance.instanceStub.actorId.url, model: model)
                        }
                    }
                }))
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: Icons.search)
                    .frame(width: 42)
                Text("Choose Another Instance...")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
        }
    }
    
    func resolveEntity(url: URL, model: NavigationModel) async {
        let toastId = ToastModel.main.add(.loading("Resolving..."), location: .bottom)
        do {
            let client = ApiClient.getApiClient(url: url, username: nil)
            let resolvedEntity = try await client.resolve(url: entity.actorId.url)
            NavigationModel.main.shareInfo = .init(
                url: resolvedEntity.url(),
                actions: entity.shareSheetActions()
            )
            ToastModel.main.removeToast(id: toastId)
        } catch {
            ToastModel.main.removeToast(id: toastId)
            handleError(error)
        }
    }
}

struct SheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 500
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment) {
        ScrollView {
            VStack(spacing: Constants.main.standardSpacing) {
                LargePostView(post: Post2.mock(.realistic(.yorkshireDales)))
                LargePostView(post: Post2.mock(.realistic(.meguroRiver)))
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
        .background(.themedGroupedBackground)
        .sheet(isPresented: .constant(true)) {
            ShareInstancePickerView(entity: Community2.mock(.realistic(.pics)))
        }
    }
#endif
