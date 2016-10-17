//
//  Person.swift
//  proj10
//
//  Created by dh on 10/3/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
