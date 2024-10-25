//
//  ItemSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct ItemSheetView: View {
    let rate: Rate
    @State var isBuying: Bool = false
    @State var isSelling: Bool = false
    var isPresented: Bool {
        isBuying || isSelling
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: -5) {
                Text("\(rate.code)")
                    .font(.largeTitle).bold()
                Text("\(rate.currency)".capitalized)
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(String(format: "%.2f", rate.mid))
                    .fontWeight(.semibold)
                Text("\(rate.currency.capitalized) • \(rate.code)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(10)
        
        HStack {
            Button {
                isBuying.toggle()
            } label: {
                HStack {
                    Text("Buy")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Color(.white))
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 48)
            }
            .background(Color(.systemGreen))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Button {
                isSelling.toggle()
            } label: {
                HStack {
                    Text("Sell")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Color(.white))
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 48)
            }
            .background(Color(.systemRed))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            //.padding(.top, 24)
        }
        .sheet(isPresented: Binding(
            get: { isPresented },
            set: { newValue in
                if !newValue {
                    isBuying = false
                    isSelling = false
                }
            }
        )) {
            if isBuying {
                VStack {
                    Text("Buy")
                }
                .presentationDetents([.height(200)])
            } else {
                VStack {
                    Text("Sell")
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}

#Preview {
    ItemSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0))
}
