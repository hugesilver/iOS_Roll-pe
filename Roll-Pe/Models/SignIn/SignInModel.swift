//
//  SignInModel.swift
//  Roll-Pe
//
//  Created by 김태은 on 2/14/25.
//

import Foundation

struct SignInModel: Decodable {
    let status_code: Int
    let message: String
    let code: String
    let link: String?
    let data: SignInDataStructure?
}

struct SignInDataStructure: Decodable {
    let refresh: String
    let access: String
    let user: SignInDataUserStructure?
}

struct SignInDataUserStructure: Decodable {
    let name: String
    let email: String
    let identifyCode: String
    let id: Int
    let provider: String?
}
