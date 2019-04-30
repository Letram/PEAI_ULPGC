import Foundation

class CustomerModel {
    let name: String
    let address: String
    let IDCustomer: Int
    
    init(name: String, address: String, uid: Int) {
        self.name = name
        self.address = address
        self.IDCustomer = uid
    }
}
