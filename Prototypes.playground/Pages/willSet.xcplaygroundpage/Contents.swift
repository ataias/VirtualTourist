import UIKit

class WillSetTest {
    var array: [Int] = [] {
        willSet(newArray) {
            print("About to set array to \(newArray)")
        }
    }
}

let x = WillSetTest()
for i in 1...8 {
    x.array.append(8)
}
