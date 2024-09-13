//
//  BypassProxyWarningSheet.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-13.
//

import Foundation
import SwiftUI

struct BypassProxyWarningSheet: View {
    @Setting(\.autoBypassImageProxy) var autoBypassImageProxy
    
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let callback: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.main.doubleSpacing) {
            WarningView(
                iconName: Icons.proxy,
                text: "Bypass Image Proxy?",
                inList: false,
                overrideColor: palette.caution
            )
            
            // swiftlint:disable:next line_length
            Text("Some instances proxy images to protect your privacy. In certain cases, this causes image loading to fail. You can bypass the image proxy and load directly, but this will expose your IP address to the image host.")
            
            Button {
                callback()
                dismiss()
            } label: {
                Text("Bypass Image Proxy")
                    .padding(.vertical, Constants.main.halfSpacing)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            VStack(spacing: Constants.main.halfSpacing) {
                Button {
                    autoBypassImageProxy = true
                    callback()
                    dismiss()
                } label: {
                    Text("Auto-Bypass On Failure")
                        .padding(.vertical, Constants.main.halfSpacing)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Text("Mlem will always try to load from the proxy first.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .padding(.vertical, Constants.main.halfSpacing)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Constants.main.doubleSpacing)
    }
}
