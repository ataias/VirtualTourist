//: [Previous](@previous)

import Foundation
import Combine

// Let's say I want to create a publisher for each of the sub-elements in a nested structure like below
let data = [[1,2,3], [4,5,6], [7,8,9]]

// How do I do that? I could do flatMap
data.publisher
    .flatMap { $0.publisher }
    .sink { (result) in
        print(result)
    }

//: [Next](@next)
