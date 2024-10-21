//
//  ContentView.swift
//  Journal app
//
//  Created by Rimas Alshahrani on 18/04/1446 AH.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("book1")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Journali")
                .padding(10)
                .bold()
                .fontWeight(.heavy)
                .font(.system(size: 40)) // Corrected font size modifier
            Text("Your thoughts, Your Story") // Corrected typo
        }
    }
}

#Preview {
    ContentView()
}
