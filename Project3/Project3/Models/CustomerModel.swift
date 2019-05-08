import Foundation

class CustomerModel: DBModel, Codable {
    var name: String
    var address: String
    var IDCustomer: Int
    
    init(name: String, address: String, uid: Int) {
        self.name = name
        self.address = address
        self.IDCustomer = uid
    }
}
