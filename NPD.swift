//
//  NPD.swift
//  Diagnostics
//
//  Created by Ирина Хон on 11.01.2022.
//

import Foundation

class NPD: NSObject {
    
    @objc dynamic var classes: String
    @objc dynamic var features: String
    @objc dynamic var npd: String
    @objc dynamic var periods: String
    @objc dynamic var valuesInPeriod: String
    @objc dynamic var minTime: String
    @objc dynamic var maxTime: String
    
    init(_ classes: String, _ features: String, _ npd: String, _ periods: String, _ valuesInPeriod: String, _ minTime: String, _ maxTime: String) {
        self.classes = classes
        self.features = features
        self.npd = npd
        self.periods = periods
        self.valuesInPeriod = valuesInPeriod
        self.minTime = minTime
        self.maxTime = maxTime
    }
    
}
