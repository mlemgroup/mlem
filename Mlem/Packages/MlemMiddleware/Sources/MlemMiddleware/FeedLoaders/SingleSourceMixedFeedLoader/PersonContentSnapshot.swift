//
//  PersonContentSnapshot.swift
//  Mlem
//
//  Created by Sjmarf on 2026-08-07.
//

import Foundation

public enum PersonContentSnapshot {
    case post(Post2Snapshot)
    case comment(Comment2Snapshot)
}
