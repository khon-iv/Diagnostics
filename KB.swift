//
//  KB.swift
//  Diagnostics
//
//  Created by Ирина Хон on 11.01.2022.
//

import Foundation

class KB: NSObject {
    
    @objc dynamic var classes: String
    @objc dynamic var features: String
    @objc dynamic var values: String
    @objc dynamic var normalValues: String
    
    init(_ classes: String, _ features: String, _ values: String, _ normalValues: String) {
        self.classes = classes
        self.features = features
        self.values = values
        self.normalValues = normalValues
    }
}
