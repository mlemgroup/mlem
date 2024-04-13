//
//  InboxRegistrationApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Dependencies
import Foundation
import SwiftUI

struct InboxRegistrationApplicationView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var application: RegistrationApplicationModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxRegistrationApplicationBodyView(
                application: application,
                menuFunctions: application.genMenuFunctions(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
            )
            
            if !application.read {
                interactions
            }
        }
        .background(Color.systemBackground)
        .contextMenu {
            ForEach(application.genMenuFunctions(modToolTracker: modToolTracker, unreadTracker: unreadTracker)) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        }
    }
    
    var interactions: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            Button {
                modToolTracker.denyApplication(application)
            } label: {
                Image(systemName: Icons.deny)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppConstants.standardSpacing)
            }
            .background(Color.secondarySystemBackground)
            .foregroundStyle(.red)
            .clipShape(Capsule())
            
            Button {
                Task {
                    await application.approve(unreadTracker: unreadTracker)
                }
            } label: {
                Image(systemName: Icons.approve)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppConstants.standardSpacing)
            }
            .background(Color.secondarySystemBackground)
            .foregroundStyle(.blue)
            .clipShape(Capsule())
        }
        .padding(.horizontal, AppConstants.standardSpacing)
        .padding(.bottom, AppConstants.standardSpacing)
    }
}
