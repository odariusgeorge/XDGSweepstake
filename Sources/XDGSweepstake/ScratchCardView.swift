//
//  ScratchCardView.swift
//  
//
//  Created by Oanea, George on 19.12.2022.
//

import SwiftUI

public struct ScratchCardView<Content: View, OverlayView: View>: View {

    // MARK: - Properties

    @Binding var onFinish: Bool

    @GestureState var gestureLocation: CGPoint = .zero

    @State var startingPoint: CGPoint = .zero

    @State var points: [CGPoint] = []

    let size: CGSize

    let content: Content

    let overlayView: OverlayView

    let cursorSize: CGFloat

    // MARK: - Init

    public init(
        cursorSize: CGFloat,
        size: CGSize,
        onFinish: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder overlayView: @escaping () -> OverlayView
    ) {
        self.cursorSize = cursorSize
        self._onFinish = onFinish
        self.size = size
        self.content = content()
        self.overlayView = overlayView()
    }

    public var body: some View {
        ZStack {
            overlayView.opacity(onFinish ? 0 : 1)

            content
                .mask(
                    ZStack {
                        if !onFinish {
                            ScratchMask(points: points, startingPoint: startingPoint)
                                .stroke(style: StrokeStyle(lineWidth: cursorSize, lineCap: .round, lineJoin: .round))
                        } else {
                            Rectangle()
                        }
                    }
                )
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .updating(
                            $gestureLocation,
                            body: { value, out, _ in
                                out = value.location
                                DispatchQueue.main.async {
                                    if startingPoint == .zero {
                                        startingPoint = value.location
                                    }
                                    points.append(value.location)
                                }
                            }
                        )
                        .onEnded(
                            { value in
                                withAnimation {
                                    if shouldUnveilContent() {
                                        onFinish = true
                                    } else {
                                        withAnimation(.easeIn) {
                                            points.removeAll()
                                        }
                                    }
                                }
                            }
                        )
                )
        }
        .frame(width: size.width, height: size.height)
        .cornerRadius(20)
        .onChange(
            of: onFinish,
            perform: { value in
                if !onFinish && !points.isEmpty {
                    withAnimation(.easeOut) {
                        points.removeAll()
                        startingPoint = .zero
                    }
                }
            }
        )
    }
}

// MARK: - Private

private extension ScratchCardView {

    func maskSize() -> CGSize {
        Path { path in path.addLines(points) }.boundingRect.size
    }

    func getArea(size: CGSize) -> CGFloat {
        size.height * size.width
    }

    func shouldUnveilContent() -> Bool {
        getArea(size: maskSize()) >= (getArea(size: size) / 2)
    }
}
