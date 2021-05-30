//
//  ContentView.swift
//  STKP
//
//  Created by David Trafela on 10/02/2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @ObservedObject var gpxViewModel = GpxViewModel()
    @ObservedObject var locationViewModel = LocationViewModel()

    init() {
        //gpxViewModel.fetchFilesFuture().assign(to: \.finishedDownloading, on: self.locationViewModel)
        
        gpxViewModel.fetchFiles()
    }
    
    var body: some View {
        ZStack{
            gpxViewModel.isLoading(){
                Text("Loading...")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.red)
                    .background(Color.clear)
                    .zIndex(10)
            }?.onDisappear(perform: {
                print("Load")
                self.locationViewModel.load()
            })
            
            TabView{
                MapView(locationViewModel)
                    .ignoresSafeArea()
                    .tabItem {
                        Label("Zemljevid", systemImage: "map")
                    }
                NavigationView {
                    List(locationViewModel.etape) { etapa in
                        NavigationLink(destination: EtapaView(etapa: etapa)) {
                            VStack(alignment: .leading) {
                                Text(etapa.name).font(.headline)
                                Text(etapa.category).font(.subheadline)
                            }
                        }
                    }
                    .navigationTitle("Etape")
                }
                .tabItem {
                    Label("Etape", systemImage: "list.bullet")
                }
                NavigationView {
                    List(locationViewModel.kontrolneTocke) { tocka in
                        VStack(alignment: .leading) {
                            Text(tocka.naziv).font(.headline)
                            Text(tocka.zig).font(.subheadline)
                        }
                    }
                    .navigationTitle("Kontrolne točke")
                }
                .tabItem {
                    Label("Kontrolne točke", systemImage: "list.bullet")
                }
            }.zIndex(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
