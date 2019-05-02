import Foundation

class ProductModel: DBModel {
    let name: String
    let description: String
    let price: Float
    let IDProduct: Int
    
    init(name: String, description: String, pid: Int, price: Float) {
        self.name = name
        self.description = description
        self.IDProduct = pid
        self.price = price
    }
}
