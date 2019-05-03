import Foundation

class StaticCustomerService: StaticQueryServiceInterface{
    
    let defaultSession = URLSession(configuration: .default)
    
    static var dataTask: URLSessionDataTask?
    static var errorMessage = ""
    
    static var customers: [CustomerModel] = []{
        didSet{
            customers = customers.sorted(by: {$0.name < $1.name})
        }
    }
    
    static var insertedId: Int? = nil
    static var updateResultReq: Bool? = false
    static var deleteResultReq: Bool? = false
    
    static func getAll(completion: @escaping queryResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.CUSTOMER_GETALL))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "GET"
        
        // Shared session es para peticiones básicas que no necesitan configuración
        let session = URLSession.shared
        
        // Tarea asíncrona para recuperar el contenido de una url.
        dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
            }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                getAllResponse(self)
                DispatchQueue.main.async {
                    completion(self.customers as [CustomerModel], self.errorMessage)
                }
            }
        })
        // Se lanza la tarea
        dataTask?.resume()
    }
    
    func getAllResponse(_ data: Data?){}
    
    static func insert(params: JsonDict, completion: @escaping insertResult) {
        
    }
    
    func insertResponse(){}
    
    static func update(params: JsonDict, completion: @escaping updateResult) {
        
    }
    
    func updateResponse(){}
    
    static func delete(params: JsonDict, completion: @escaping deleteResult) {
        
    }
    
    func deleteResponse(){}
    
    
}
