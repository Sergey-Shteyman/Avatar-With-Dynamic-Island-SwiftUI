//
//  OffsetObservingScrollView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// MARK: - OffsetObservingScrollView

struct OffsetObservingScrollView<Content: View>: View {

    // MARK: - Internal Properties

    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    var axes: Axis.Set = [.vertical]
    @State var delegate = ScrollDelegate()
    @State var isScrolling = false

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axes) {
                PositionObservingView(
                    coordinateSpace: .named(Const.OffsetObservingScrollView.coordinateSpaceName),
                    position: Binding(
                        get: { offset },
                        set: { newOffset in
                            offset = CGPoint(
                                x: -newOffset.x,
                                y: -newOffset.y
                            )
                        }
                    ),
                    content: content
                )
            }
            .scrollStatus(isScrolling: $isScrolling)
            .coordinateSpace(name: Const.OffsetObservingScrollView.coordinateSpaceName)
            .onChange(
                of: isScrolling,
                perform: { _ in
                    guard offset.y > 0 && offset.y < 165,
                          !isScrolling else { return }
//                    guard  offset.y < Const.OffsetObservingScrollView.openOffsetPosition && offset.y > 0,
//                          !isScrolling else { return }
//                    guard isHeaderPagingEnabled,
//                           offset.y > 0,
//                          !isScrolling else { return }
                    let shouldShowBottom = offset.y > Const.OffsetObservingScrollView.openOffsetPosition / 2
                    let anchor: UnitPoint = shouldShowBottom ? .top : .bottom
                    withAnimation {
                        proxy.scrollTo(Const.MainView.headerViewId, anchor: anchor)
                    }
                }
            )
        }
    }
}

// MARK: - OffsetObservingScrollView_Previews
struct OffsetObservingScrollView_Previews: PreviewProvider {

    static var previews: some View {
        ConstructorProfileView(viewModel: .init(user: .mock())) {
            emptyCells()
        }
    }
}

