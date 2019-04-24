//
//  CustomerQueryService.swift
//  Project2
//
//  Created by Alumno on 24/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class CustomerQueryService : QueryService{
    typealias JsonDict = [String: Any]
    
    typealias customerQueryResult = ([CustomerModel], String) -> ()
    typealias customerInsertResult = (Int, String) -> ()
    typealias customerUpdateResult = (Bool, String) -> ()
    typealias customerDeleteResult = (Bool, String) -> ()
    
    let defaultSession = URLSession(configuration: .default)
    
    var delegate: CustomerListViewController? = nil
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var customers: [CustomerModel] = []
    
    func getAll(completion: @escaping customerQueryResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: WebData.CUSTOMER_GETALL, relativeTo: WebData.SERVER_URL)!)
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
                    completion(self.customers, self.errorMessage)
                }
            }
        })
        // Se lanza la tarea
        dataTask?.resume()
    }
    
    func updateResults(_ data: Data){
        var response: JsonDict?
        customers.removeAll()
        
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
        guard let customerArray = response!["data"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        for customerObj in customerArray {
            if let customerAux = customerObj as? JsonDict,
                let previewName = customerAux["name"] as? String,
                let previewAddress = customerAux["address"] as? String,
                let previewUid = customerAux["IDCustomer"] as? Int
            {
                customers.append(CustomerModel(name: previewName, address: previewAddress, uid: previewUid))
            } else {
                errorMessage += "Problem parsing customerAux\n"
            }
        }
    }
    
    func insert(params: JsonDict, completion: @escaping customerInsertResult) {
        
    }
    
    func update(params: JsonDict, completion: @escaping customerUpdateResult) {
        
    }
    
    func delete(params: JsonDict, completion: @escaping customerDeleteResult) {
        
    }
    
    
}
