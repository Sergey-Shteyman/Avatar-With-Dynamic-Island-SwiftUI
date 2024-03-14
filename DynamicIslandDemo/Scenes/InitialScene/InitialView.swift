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
                        ProfileView(viewModel: .init()) {
                            emptyCells()
                        }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
        })
    }
    
}

func scrollViewCells() -> some View {
    VStack(spacing: 24.0) {
        emptyCells()
    }
}

func emptyCells() -> some View {
    VStack {
        ForEach(0..<25) { _ in
            ToggleCellView(isToggleOn: .constant(false), showToggle: false)
        }
    }
}
