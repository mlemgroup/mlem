//
//  Generic Merge Sort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation

/**
 Performs merge on two sorted arrays, returning the result.
 
 The arrays must be sorted such that compare(a[0], a[1]) returns true
 
 The result will be sorted using the provided compare such that, if compare(x, y) returns true, x will appear before y in the output.
 */
func merge<T>(arr1: [T], arr2: [T], compare: (T, T) -> Bool) -> [T] {
    assert(arrayIsSorted(arr: arr1, compare: compare), "arr1 is not sorted")
    assert(arrayIsSorted(arr: arr2, compare: compare), "arr2 is not sorted")
    
    var ret: [T] = .init()
    
    var aIdx = 0
    var bIdx = 0
    
    // merge
    while aIdx < arr1.count && bIdx < arr2.count {
        if compare(arr1[aIdx], arr2[bIdx]) {
            ret.append(arr1[aIdx])
            aIdx += 1
        } else {
            ret.append(arr2[bIdx])
            bIdx += 1
        }
    }
    
    // handle remaining values
    while aIdx < arr1.count {
        ret.append(arr1[aIdx])
        aIdx += 1
    }
    while bIdx < arr2.count {
        ret.append(arr2[bIdx])
        bIdx += 1
    }
    
    return ret
}

/**
 Helper function for assert above
 */
func arrayIsSorted<T>(arr: [T], compare: (T, T) -> Bool) -> Bool {
    if arr.count < 2 { return true } // empty or single-item array always sorted
    for idx in 1..<(arr.count) where !compare(arr[idx-1], arr[idx]) {
        return false
    }
    return true
}
