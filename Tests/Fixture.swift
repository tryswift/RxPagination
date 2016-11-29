//
//  Fixture.swift
//  Pagination
//
//  Created by Yosuke Ishikawa on 5/6/16.
//  Copyright © 2016 Yosuke Ishikawa. All rights reserved.
//

import Foundation

enum Fixture: String {
    case SearchRepositories

    var data: Data {
        guard let path = Bundle(for: Dummy.self).path(forResource: self.rawValue, ofType: "json") else {
            fatalError("Could not file named \(self.rawValue).json in test bundle.")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Could not read data from file at \(path).")
        }

        return data
    }

    private class Dummy {
        
    }
}
