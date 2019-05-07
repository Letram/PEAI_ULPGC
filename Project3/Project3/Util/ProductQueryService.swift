import Foundation

class ProductQueryService: QueryServiceInterface{
    
    let defaultSession = URLSession(configuration: .default)
    
    var delegate: ProductListViewController? = nil
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    
    var products: [ProductModel] = []{
        didSet{
            products = products.sorted(by: {$0.name < $1.name})
            ProductQueryService.staticProducts = products
        }
    }
    
    static var staticProducts: [ProductModel] = []
    
    var insertedId: Int? = nil
    var updateResultReq: Bool? = false
    var deleteResultReq: Bool? = false
    
    func getAll(completion: @escaping queryResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_GETALL))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "GET"
        
        // Shared session es para peticiones básicas que no necesitan configuración
        let session = URLSession.shared
        
        // Tarea asíncrona para recuperar el contenido de una url.
        dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
            }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self.updateResults(data)
                DispatchQueue.main.async {
                    completion(self.products, self.errorMessage)
                }
            }
        })
        // Se lanza la tarea
        dataTask?.resume()
    }
    
    func updateResults(_ data: Data){
        var response: JsonDict?
        self.products.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "GetAll problem!"
            return
        }
        guard let productArray = response!["data"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        for productObj in productArray {
            if let productAux = productObj as? JsonDict{
                let previewName = productAux["name"] as? String
                let previewDescription = productAux["description"] as? String
                let previewPid = productAux["IDProduct"] as? String
                let previewPrice = productAux["price"] as? String
                self.products.append(ProductModel(name: previewName!, description: previewDescription!, pid: Int(previewPid!)!, price: Float(previewPrice!)!))
            }
            else {
                errorMessage += "Problem parsing customerAux\n"
            }
        }
    }
    
    func insert(params: JsonDict, completion: @escaping insertResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_INSERT))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.insertProductResponse(data)
                    if self.insertedId != -1{
                        let productAux = ProductModel(name: params["name"] as! String, description: params["description"] as! String, pid: self.insertedId!, price: params["price"] as! Float)
                        self.products.append(productAux)
                    }
                    DispatchQueue.main.async {
                        completion(self.products, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func insertProductResponse(_ data: Data){
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            insertedId = -1
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Insert problem!"
            insertedId = -1
            return
        }
        guard let insertedIdFromResponse = response!["data"] as? Int else {
            errorMessage += "Dictionary does not contain results key\n"
            insertedId = -1
            return
        }
        insertedId = insertedIdFromResponse
    }
    
    func update(params: JsonDict, completion: @escaping updateResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_UPDATE))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "PUT"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.updateProductResponse(data)
                    if self.updateResultReq! {
                        let productAux = ProductModel(name: params["name"] as! String, description: params["description"] as! String, pid: params["IDProduct"]! as! Int, price: params["price"] as! Float)
                        self.products[self.products.firstIndex(where: {$0.IDProduct == params["IDProduct"] as! Int})!] = productAux
                    }
                    DispatchQueue.main.async {
                        completion(self.products, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func updateProductResponse(_ data: Data){
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Update problem!"
            return
        }
        guard let updateResponse = response!["data"] as? Bool else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        updateResultReq = updateResponse
    }
    
    func delete(params: JsonDict, completion: @escaping deleteResult) {
        dataTask?.cancel()
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_DELETE))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "DELETE"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.deleteProductResponse(data)
                    if self.deleteResultReq! {
                        self.products = self.products.filter({$0.IDProduct != params["IDProduct"] as! Int})
                    }
                    DispatchQueue.main.async {
                        completion(self.products, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func deleteProductResponse(_ data: Data){
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Delete problem!"
            return
        }
        guard let deleteResponse = response!["data"] as? Bool else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        deleteResultReq = deleteResponse
    }
}
