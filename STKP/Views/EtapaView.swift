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
            }) {
                Text("Obišči spletno stran etape")
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .fullScreenCover(isPresented: $showSafari) {
                SafariView(url: URL(string: etapa.href)!)
            }
            
            Spacer()
        }.navigationBarTitle(Text(""), displayMode: .inline)
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
