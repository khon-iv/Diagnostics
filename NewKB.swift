import Foundation

class NewKB: NSObject {
    
    @objc dynamic var classes1: String
    @objc dynamic var features1: String
    @objc dynamic var values1: String
    
    init(_ classes: String, _ features: String, _ values: String) {
        self.classes1 = classes
        self.features1 = features
        self.values1 = values
    }
}
