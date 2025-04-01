//
//  String+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-10.
//

import Foundation

public extension String {
    /// Returns true if the given array of strings contains any word which appears as a substring of this string
    func isContainedIn(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
    
    /// Returns true if the given set of strings contains any word which appears as a substring of this string
    func isContainedIn(_ strings: Set<String>) -> Bool {
        strings.contains { contains($0) }
    }
    
    /// Returns true if this string contains:
    /// - Any single word that matches a single word in filteredKeywords
    /// - Any sequence of words that precisely matches a multi-word phrase in filteredKeywords
    func failsKeywordFilter(_ filteredKeywords: Set<String>) -> Bool {
        // parse single keywords from multi-word phrases
        var keywords: Set<String> = .init()
        var phrases: Set<[String]> = .init()
        for keyword in filteredKeywords {
            if keyword.contains(" ") {
                phrases.insert(keyword.split(separator: " ").map { $0.lowercased() })
            } else {
                keywords.insert(keyword)
            }
        }
        
        // split on any non-letter/number characters so "keyword's" is filtered as "keyword" "s"
        let words = split(separator: /[^[:alnum:]]/)
            .map { $0.lowercased() }
        
        var partialMatches: [PartialMatch] = .init()
        for word in words {
            // check single keywords
            if keywords.contains(word) { return true }
            
            // check if any partial matches succeed
            var matchedPhrase: Bool = false
            partialMatches = partialMatches.filter { partial in
                switch partial.matchNextWord(word) {
                case .failed: return false
                case .partial: return true
                case .matched:
                    matchedPhrase = true
                    return true
                }
            }
            if matchedPhrase { return true }
            
            // check if this word starts a new partial match
            for phrase in phrases {
                guard let firstWord = phrase.first else {
                    assertionFailure("Invalid phrase (no first element)")
                    continue
                }
                if word == firstWord {
                    partialMatches.append(.init(phrase: phrase))
                }
            }
        }
        
        return words.contains { filteredKeywords.contains($0) }
    }
}

private enum MatchState {
    case partial, failed, matched
}

private class PartialMatch {
    private let phrase: [String]
    private var index: Int = 1 // starts at 1 because only initialized if first word matches
    
    init(phrase: [String]) {
        assert(phrase.count > 0, "Invalid phrase")
        self.phrase = phrase
    }
    
    func matchNextWord(_ word: String) -> MatchState {
        guard let nextWord = phrase[safeIndex: index] else {
            assertionFailure("No next word!")
            return .failed
        }
        if word == nextWord {
            if index == phrase.count - 1 {
                return .matched
            } else {
                index += 1
                return .partial
            }
        }
        return .failed
    }
}
