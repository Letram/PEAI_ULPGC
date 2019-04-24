import Foundation

class CustomerModel {
    let name: String
    let address: String
    let uid: Int
    
    init(name: String, address: String, uid: Int) {
        self.name = name
        self.address = address
        self.uid = uid
    }
}
