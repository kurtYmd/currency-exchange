//
//  ListItemView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct ListItemView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("USD")
                    .font(.title2)
                    .bold()
                Text("us dollar".capitalized)
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
            }
            Spacer()
            VStack {
                Text(String(format: "%.4f", "4.1") + "zł")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    ListItemView()
}
