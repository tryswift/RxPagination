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

    var data: NSData {
        guard let path = NSBundle(forClass: Dummy.self).pathForResource(self.rawValue, ofType: "json") else {
            fatalError("Could not file named \(self.rawValue).json in test bundle.")
        }

        guard let data = NSData(contentsOfFile: path) else {
            fatalError("Could not read data from file at \(path).")
        }

        return data
    }

    private class Dummy {
        
    }
}
