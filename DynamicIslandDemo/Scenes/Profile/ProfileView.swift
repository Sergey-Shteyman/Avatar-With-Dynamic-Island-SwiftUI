//
//  ProfileView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// TODO: - Сделать адапатинвое появление офна панели навигации

// TODO: -  Сравнить расположение кнопок и заголовка на других устройствах модели айфона

// TODO: - Сделать анимацию для имени пользователя перезжаение вниз и влево при раскрытой аватарке.

// TODO: - Подогнать заголовок панели навигации с кнопкой на панели на разных устройствах

// TODO: - Сделать так чтобы расскрывалась по тапу

// TODO: - ПОдогнать аватарку и все текста по размеру, чтобы было как в нашей прилке


// MARK: - ProfileView
struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var showFullAvatar: Bool = false
    @State private var isIslandVisible: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .top) {
                if isIslandVisible {
                    if viewModel.isIslandShapeVisible {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                            context.addFilter(.blur(radius: 6))
                            context.drawLayer { ctx in
                                if let island = ctx.resolveSymbol(id: Const.MainView.islandViewId) {
                                    ctx.draw(island, at: CGPoint(x: (size.width / 2),
                                                                 y: viewModel.islandTopPadding + (viewModel.islandSize.height / 2)))
                                }
                                if let image = ctx.resolveSymbol(id: Const.MainView.imageViewId) {
                                    let yImageOffset = (Const.MainView.imageSize / 2) + Const.MainView.imageTopPadding
                                    let yImagePosition = bounds.safeAreaInsets.top + yImageOffset + 22
                                    ctx.draw(image, at: CGPoint(x: size.width / 2, y: yImagePosition))
                                }
                            }
                        } symbols: {
                            islandShapeView()
                            avatarShapeView()
                        }
                        .edgesIgnoringSafeArea(.top)
                    }
                }
                avatarView(offsetY: bounds)
                scrollView()
                navigationButtons()
            }
        }
        .toolbar(.hidden)
        .onAppear(perform: {
            self.isIslandVisible = isIslindVisible()
        })
        .background(Color(uiColor: .systemGray6))
        .onChange(of: scenePhase) { newPhase in
            let isActive = newPhase == .active
            let duration = isActive ? 0.3 : .zero
            withAnimation(Animation.linear(duration: duration).delay(duration)) {
                viewModel.isIslandShapeVisible = isActive
            }
        }
    }
    
    func isIslindVisible() -> Bool {
        let topInset = getSafeArea().top
        if topInset > 47 {
            print("⛳️ Островок найден! \(topInset)")
            return true
        } else {
            print("🍌 Челка! \(topInset)")
            return false
        }
    }
    
    // MARK: - Private Methods

    private func islandShapeView() -> some View {
        Capsule(style: .continuous)
            .frame(width: viewModel.islandSize.width,
                   height: viewModel.islandSize.height,
                   alignment: .center)
            .scaleEffect(viewModel.islandScale)
            .tag(Const.MainView.islandViewId)
    }

    private func avatarShapeView() -> some View {
        let offsetImage = max(-viewModel.offset.y * 1.16, -Const.MainView.imageSize - 12)
        let negativeOffset = max(-viewModel.offset.y * 0.65, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        return Circle()
            .fill(.black)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .scaleEffect(viewModel.scale)
            .offset(y: viewModel.offset.y < 0 ? negativeOffset : offsetImage)
            .tag(Const.MainView.imageViewId)
    }

    private func avatarView(offsetY: GeometryProxy) -> some View {
        let offsetImage = max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        let negativeOffset = max(-viewModel.offset.y * 0.46, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        return AvatarViewRepresentable(offsetY: $showFullAvatar)
            .frame(height: 100)
            .scaleEffect(viewModel.scale)
            .blur(radius: viewModel.blur)
            .opacity(showFullAvatar ? 1 : viewModel.avatarOpacity)
            .offset(y: viewModel.offset.y < 0 ? negativeOffset : offsetImage)
            .onChange(of: viewModel.offset.y, perform: { offset in
                if offset <= -30 && !showFullAvatar  {
                    showFullAvatar = true
                }
                if offset >= 10 && showFullAvatar {
                    showFullAvatar = false
                }
            })
    }

    private func scrollView() -> some View {
        OffsetObservingScrollView(
            offset: $viewModel.offset,
            showsIndicators: $viewModel.showsIndicators,
            isHeaderPagingEnabled: $viewModel.isHeaderPagingEnabled
        ) {
            LazyVStack(
                alignment: .center,
                pinnedViews: viewModel.isHeaderPinningEnabled ? [.sectionHeaders] : []
            ) {
                Section(header: headerView()) {
                    scrollViewCells()
                }
            }
            .padding(.top, Const.MainView.imageSize + Const.MainView.imageTopPadding + 20)
            .padding(.horizontal)
        }
        .padding(.top, 4)
        .scrollDismissesKeyboard(.interactively)
    }

    private func headerView() -> some View {
        // Если закрыт включаем формулы, а если открыт то готовые значения
        // Возмонжо ввести еще одну переменную, которая будет срабатывать с анимацией
        VStack(spacing: 4.0) {
            Text(viewModel.userName)
                .font(.system(size: viewModel.titleFontSize, weight: .medium))
            HStack(spacing: 4.0) {
                Text(viewModel.userPhoneNumber)
                Text(Const.General.bulletPointSymbol)
                Text(viewModel.userNickname)
            }
            .foregroundColor(Color(uiColor: .systemGray))
            .font(.system(size: viewModel.descriptionFontSize, weight: .regular))
            .opacity(viewModel.headerOpacity)
            .padding(.bottom, viewModel.headerPadding)
        }
        .frame(maxWidth: .infinity)
        .id(Const.MainView.headerViewId)
        .onTapGesture {
            dismiss()
        }
    }

    private func scrollViewCells() -> some View {
        VStack(spacing: 24.0) {
//            generalSettingsCells()
//            headerSettingsCells()
            emptyCells()
        }
    }

    private func generalSettingsCells() -> some View {
        VStack(spacing: 24.0) {
            ToggleCellView(parameterName: "Indicators", isToggleOn: $viewModel.showsIndicators)
            ToggleCellView(parameterName: "Zoom Effect", isToggleOn: $viewModel.isZoomEffectEnabled)
        }
    }

    private func headerSettingsCells() -> some View {
        VStack {
            ToggleCellView(parameterName: "Header Paging", isToggleOn: $viewModel.isHeaderPagingEnabled)
            ToggleCellView(parameterName: "Header Pinning", isToggleOn: $viewModel.isHeaderPinningEnabled)
        }
    }

    private func emptyCells() -> some View {
        VStack {
            ForEach(0..<25) { _ in
                ToggleCellView(isToggleOn: .constant(false), showToggle: false)
            }
        }
    }

    private func navigationButtons() -> some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                AnyView(Text("Edit"))
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.top, 4.0)
    }
}

// MARK: - PreviewProvider
struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileView(viewModel: .init(user: .mock()))
    }
}
