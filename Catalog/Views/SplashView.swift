//
//  SplashView.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-05-27.
//

import SwiftUI

struct SplashView: View {
    @State private var loaded = false
    @State private var opacity = 0.5
    
    var body: some View {
        if loaded {
            HomeView()
        } else {
            ZStack {
                Color(UIColor(.accentColor))
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20.0) {
                    ZStack {
                        Circle()
                            .frame(width: 250)
                            .foregroundColor(Color(.white))
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                    }
                    Text("Catalog")
                        .font(.custom("ToonaPersonalUse-Regular", size: 60))
                        .foregroundColor(Color("PrimaryColor"))
                    
                }
                .padding()
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation {
                        self.loaded = true;
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
