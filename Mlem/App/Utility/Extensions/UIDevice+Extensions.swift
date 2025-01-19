//
//  UIDevice+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var frameType: DeviceFrameType {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            let nameSimulator = simulatorModelIdentifier
            return .init(deviceName: nameSimulator)
        }
        
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let name = String(
            bytes: Data(
                bytes: &sysinfo.machine,
                count: Int(_SYS_NAMELEN)
            ),
            encoding: .ascii
        )!.trimmingCharacters(in: .controlCharacters)
        return .init(deviceName: name)
    }
}

enum DeviceFrameType {
    case noNotch, wideNotch, thinNotch, dynamicIsland
    
    init(deviceName: String) {
        // The number in the device name is 1 higher than the commerical number.
        switch deviceName {
        case _ where deviceName.starts(with: /iPhone[1-9][6-9]/): // iPhone 15 and above
            self = .dynamicIsland
        case _ where deviceName.starts(with: "iPhone15"): // iPhone 14
            if deviceName == "iPhone15,2" || deviceName == "iPhone15,3" {
                self = .dynamicIsland
            } else {
                self = .thinNotch
            }
        case _ where deviceName.starts(with: "iPhone14"): // iPhone 13
            self = .thinNotch
        case _ where deviceName.starts(with: /iPhone1[1-3]/): // iPhone X - 12
            self = .wideNotch
        default:
            self = .noNotch
        }
    }
}
