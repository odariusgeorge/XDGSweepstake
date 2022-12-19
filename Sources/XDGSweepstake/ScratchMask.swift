//
//  ScratchMask.swift
//  
//
//  Created by Oanea, George on 19.12.2022.
//

import SwiftUI

struct ScratchMask: Shape {

    // MARK: - Properties

    let points: [CGPoint]

    let startingPoint: CGPoint

    // MARK: - Public

    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: startingPoint)
            path.addLines(points)
        }
    }
}
