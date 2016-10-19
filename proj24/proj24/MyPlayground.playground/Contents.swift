//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
var int = 0

extension Integer {
    func cubed() -> Self {
        return self * self * self
    }
}

int.cubed()