//
//  Icon+Extension.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 27/01/2025.
//

import Foundation
import SwiftUICore
import UIKit

struct IconModifier: ViewModifier {
    var font: Font = .title
    var shape: AnyShape = AnyShape(Circle())
    var fontColor: Color = .white
    var backgroundColor: UIColor = .systemGray3
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(fontColor)
            .fontWeight(.semibold)
            .frame(width: 40, height: 40)
            .background(Color(backgroundColor))
            .clipShape(shape)
            .padding(2)
    }
}

extension View {
    func iconStyle(font: Font = .title,shape: AnyShape = AnyShape(Circle()),fontColor: Color = .white, backgroundColor: UIColor = .systemGray3) -> some View {
        modifier(IconModifier(font: font, shape: shape, fontColor: fontColor, backgroundColor: backgroundColor))
    }
}
