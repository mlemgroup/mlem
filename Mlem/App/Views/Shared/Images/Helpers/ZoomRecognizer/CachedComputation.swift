//
//  CachedComputation.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

class CachedComputation<Input: Equatable, Output> {
    private var lastInput: Input?
    private var lastOutput: Output?
    private var computation: (Input) -> Output
    
    init(computation: @escaping (Input) -> Output) {
        self.computation = computation
    }
    
    func compute(_ input: Input) -> Output {
        if let lastInput, let lastOutput, input == lastInput {
            return lastOutput
        }
        lastInput = input
        let output = computation(input)
        lastOutput = output
        return output
    }
}
