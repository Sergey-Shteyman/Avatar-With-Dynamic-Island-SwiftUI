//
//  initial.swift
//  DynamicIslandDemo
//
//  Created by Сергей Штейман on 11.03.2024.
//

import SwiftUI


// MARK: - InitialView
struct InitialView: View {
    
    var body: some View {
        NavigationView(content: {
            ScrollView {
                VStack {
                    NavigationLink {
                        ProfileView(viewModel: .init())
                    } label: {
                        Text("Profile")
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Sex")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                    }, label: {
                        Text("Button")
                    })
                }
            })
            .toolbar(.visible, for: .navigationBar)
        })
    }
    
}
