//
//  GpxViewModel.swift
//  STKP
//
//  Created by David Trafela on 24/02/2021.
//

import Foundation
import Alamofire
import SwiftUI
import ZIPFoundation
import Combine

class GpxViewModel: NSObject, ObservableObject {
    @Published private var loading = true;
    @Published var success = false;
    
    func fetchFiles(){
        loading = true;
        success = false;
        
        let requestUrl = "https://stkp-app-backend.herokuapp.com/get-latest-date"
        AF.request(requestUrl, method: .get).responseDecodable(of: LatestDate.self) { response in
            if let date = response.value?.getDate(){
                let stringDate = response.value!.stringDate()
                
                print(stringDate)
                
                let savedDate = UserDefaults.standard.object(forKey: "latestDate") as? Date
                
                if(savedDate != nil){
                    if(savedDate!.compare(date) == ComparisonResult.orderedAscending){
                        self.downloadFile(stringDate: stringDate)
                    }else{
                        self.loading = false;
                        self.success = true;
                    }
                }else{
                    self.downloadFile(stringDate: stringDate)
                }
                
                UserDefaults.standard.set(date, forKey: "latestDate")
            }else{
                self.loading = false;
                self.success = true;
            }
        }
    }
    
    func downloadFile(stringDate: String){
        let destination = DownloadRequest
            .suggestedDownloadDestination(for: .documentDirectory)
        
        let downloadUrl = "https://stkp-app-backend.herokuapp.com/download"
        AF.download(downloadUrl, to: destination).response { response in
            // Read file from provided URL.
            print("Download: \(response)")
            
            let fileManager = FileManager()
            
            var sourceURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            sourceURL.appendPathComponent("ZIP_" + stringDate + ".zip")
            
            print("Source url: \(sourceURL.absoluteString)")
            
            var destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            destinationURL.appendPathComponent("files")
            
            print("Destination url: \(destinationURL.absoluteString)")
            do {
                if(fileManager.fileExists(atPath: destinationURL.absoluteString)){
                    try fileManager.removeItem(at: destinationURL)
                }
                
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.unzipItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
            }
            
            self.loading = false;
            self.success = true;
        }
    }
    
    func isLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
        if loading {
            return content()
        }
        
        return nil
    }
    
    func isSuccess<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
        if success {
            return content()
        }
        
        return nil
    }
}
