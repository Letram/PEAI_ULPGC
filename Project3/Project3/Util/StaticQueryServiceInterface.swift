//
//  StaticQueryServiceInterface.swift
//  Project3
//
//  Created by Alumno on 03/05/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

protocol StaticQueryServiceInterface {
    typealias queryResult = ([DBModel], String) -> ()
    typealias insertResult = ([DBModel], String) -> ()
    typealias updateResult = ([DBModel], String) -> ()
    typealias deleteResult = ([DBModel], String) -> ()
    typealias JsonDict = [String: Any]
    
    static func getAll(completion: @escaping queryResult)
    static func insert(params: JsonDict, completion: @escaping insertResult)
    static func update(params: JsonDict, completion: @escaping updateResult)
    static func delete(params: JsonDict, completion: @escaping deleteResult)
}
