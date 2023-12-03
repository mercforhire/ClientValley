//
//  Array+Extensions.swift
//  Phoenix
//
//  Created by Adam Borzecki on 6/6/18.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import Foundation

extension Array {
    func contains(index : Int) -> Bool {
        return index >= 0 && index <= count - 1
    }
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var uniqueValues = [Element]()
        forEach {
            if !uniqueValues.contains($0) {
                uniqueValues.append($0)
            }
        }
        return uniqueValues
    }
}
