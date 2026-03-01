//
//  SyntheticRealizedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-26.
//

import Observation

@Observable
public class SyntheticRealizedValue<T: MergeableValue>: ValueSynthesizer<T>, RealizedValueProviding {
    public var value: T? { synthesize() }
    public var realizedValue: T { synthesize() }
}
