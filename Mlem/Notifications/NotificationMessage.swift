// 
//  NotificationMessage.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//  
//

import Foundation

/// a simple enumeration representing messages we wish to display to the user
enum NotificationMessage: Notifiable {
    case success(String)
    case detailedSuccess(title: String, subtitle: String)
    case failure(String)
    case detailedFailure(title: String, subtitle: String)
}
