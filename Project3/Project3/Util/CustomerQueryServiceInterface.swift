//
//  QueryService.swift
//  Project2
//
//  Created by Alumno on 24/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

protocol CustomerQueryServiceInterface{
    typealias customerQueryResult = ([CustomerModel], String) -> ()
    typealias customerInsertResult = (Int, String) -> ()
    typealias customerUpdateResult = (Bool, String) -> ()
    typealias customerDeleteResult = (Bool, String) -> ()
    typealias JsonDict = [String: Any]
    
    func getAll(completion: @escaping customerQueryResult)
    func insert(params: JsonDict, completion: @escaping customerInsertResult)
    func update(params: JsonDict, completion: @escaping customerUpdateResult)
    func delete(params: JsonDict, completion: @escaping customerDeleteResult)
}
