//
//  ContentView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            SearchTracksView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
