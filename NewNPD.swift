import Foundation

class NewNPD: NSObject {
    
    @objc dynamic var classes1: String
    @objc dynamic var features1: String
    @objc dynamic var npd1: String
    @objc dynamic var periods1: String
    @objc dynamic var valuesInPeriod1: String
    @objc dynamic var minTime1: String
    @objc dynamic var maxTime1: String
    
    init(_ classes: String, _ features: String, _ npd: String, _ periods: String, _ valuesInPeriod: String, _ minTime: String, _ maxTime: String) {
        self.classes1 = classes
        self.features1 = features
        self.npd1 = npd
        self.periods1 = periods
        self.valuesInPeriod1 = valuesInPeriod
        self.minTime1 = minTime
        self.maxTime1 = maxTime
    }
    
}
