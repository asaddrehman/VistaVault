//
//  SearchBar.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 06/11/1446 AH.
//
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search", text: $searchText)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(.secondary)
                            .opacity(searchText.isEmpty ? 0 : 1)
                            .onTapGesture {
                                searchText = ""
                            },
                        alignment: .trailing
                    )
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            if isFocused {
                Button("Cancel (إلغاء)") {
                    isFocused = false
                    searchText = ""
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: isFocused)
    }
}
