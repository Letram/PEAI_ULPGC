//
//  QueryService.swift
//  Project2
//
//  Created by Alumno on 24/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

protocol QueryService{
    typealias customerQueryResult = ([CustomerModel], String) -> ()
    typealias customerInsertResult = (Int, String) -> ()
    typealias customerUpdateResult = (Bool, String) -> ()
    typealias customerDeleteResult = (Bool, String) -> ()
    typealias jsonDict = [String: Any]
    
    func getAll(completion: @escaping customerQueryResult)
    func insert(params: jsonDict, completion: @escaping customerInsertResult)
    func update(params: jsonDict, completion: @escaping customerUpdateResult)
    func delete(params: jsonDict, completion: @escaping customerDeleteResult)
}
