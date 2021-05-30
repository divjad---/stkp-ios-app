//
//  Etapa.swift
//  STKP
//
//  Created by David Trafela on 17/03/2021.
//

import Foundation

struct Etapa: Identifiable, Decodable {
    
    var id: Int?
    
    let name: String
    let href: String
    let desc: String
    let category: String
    
}
