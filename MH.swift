//
//  MH.swift
//  Diagnostics
//
//  Created by Ирина Хон on 11.01.2022.
//

import Foundation

class MH: NSObject {
    
    @objc dynamic var classes: String
    @objc dynamic var history: String
    @objc dynamic var features: String
    @objc dynamic var value: String
    @objc dynamic var time: String
    
    init(_ classes: String, _ history: String, _ features: String, _ value: String, _ time: String) {
        self.classes = classes
        self.history = history
        self.features = features
        self.value = value
        self.time = time
    }
    
}
