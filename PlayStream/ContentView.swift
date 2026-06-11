//
//  ContentView.swift
//  PlayStream
//
//  Created by Abdu on 11/06/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = DriveAuthService.shared
    
    var body: some View {
        if authService.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
            
            Text("Bibliothèque")
                .tabItem {
                    Image(systemName: "heart")
                    Text("Bibliothèque")
                }
            
            Text("Rechercher")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Rechercher")
                }
            
            Text("Paramètres")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Paramètres")
                }
        }
        .accentColor(Color.theme.primary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.theme.darkSurface)
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct LoginView: View {
    @StateObject private var authService = DriveAuthService.shared
    
    var body: some View {
        ZStack {
            Color.theme.darkBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Text("PlayStream")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primary)
                
                Text("Vos films Google Drive avec une interface magnifique.")
                    .font(.headline)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    authService.signIn()
                }) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                        Text("Se connecter avec Google")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.primary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
