//
//  KontrolnaTocka.swift
//  STKP
//
//  Created by David Trafela on 17/03/2021.
//

import Foundation

struct KontrolnaTocka: Identifiable, Decodable {

    let zapSt: String
    let naziv: String
    let naslov: String
    let zig: String
    
    var id: Int {
        Int(zapSt) ?? 0
    }
}
