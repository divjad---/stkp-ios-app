//
//  EtapaView.swift
//  STKP
//
//  Created by David Trafela on 17/03/2021.
//

import SwiftUI
import SafariServices

struct EtapaView: View {
    @State var showSafari = false
    
    var etapa: Etapa
    
    var etapaName: String
    
    @ObservedObject var locationViewModel = LocationViewModel()
    
    init(etapa: Etapa) {
        self.etapa = etapa
        
        var name = self.etapa.name.prefix(2)
        let num = Int(name)!
        name = "Etapa_" + String(describing: num)
        
        self.etapaName = String(name)
        
        locationViewModel.loadSpecificEtapa(etapa: self.etapaName)
    }
    
    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                Text(etapa.name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(etapa.category)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text(etapa.desc)
            }
            .padding()
            
            Button(action: {
                self.showSafari = true
                
                print(etapa.href)
            }) {
                Text("Obišči spletno stran etape")
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .fullScreenCover(isPresented: $showSafari) {
                SafariView(url: URL(string: etapa.href)!)
            }
            
            Spacer()
            
            MapView(locationViewModel)
        }.navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            Button(action: {
                shareGpxFiles()
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    
    func shareGpxFiles(){
        let fileManager = FileManager.default
        
        var documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documents.appendPathComponent("files")
        
        let etFile = documents.appendingPathComponent(self.etapaName)
        
        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()
        
        // Add the path of the file to the Array
        filesToShare.append(etFile)
        
        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

struct EtapaView_Previews: PreviewProvider {
    static var previews: some View {
        EtapaView(etapa: LocationViewModel().etape[0])
    }
}

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
}

#if DEBUG
struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url: URL(string: "https://david.y4ng.fr")!)
    }
}
#endif
