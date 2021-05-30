//
//  LatestDate.swift
//  STKP
//
//  Created by David Trafela on 24/02/2021.
//

import Foundation

class LatestDate: NSObject, Decodable{
    private var date: String
    
    func getDate() -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.date(from: self.date)
    }
    
    func stringDate() -> String {
        return date
    }
}
