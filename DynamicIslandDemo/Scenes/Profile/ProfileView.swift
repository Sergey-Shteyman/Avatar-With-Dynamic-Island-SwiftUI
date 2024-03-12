//
//  ProfileView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// TODO: - Попробовать сделать чуть сложнее растягивание авы и по короче анимацию для смещения контента страницы

// TODO: - Перенести проект в приложение

// TODO: - Добавить градиент под заголовки


// MARK: - ProfileView
struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var showFullAvatar: Bool = false
    @State private var isIsland: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .top) {
                if isIsland {
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
                tapArea()
            }
        }
        .toolbar(.hidden)
        .onAppear(perform: {
            self.isIsland = isIslindVisible()
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
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFullAvatar = true
                    }
                }
                if offset >= 10 && showFullAvatar {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFullAvatar = false
                    }
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
            .padding(.top, Const.MainView.imageSize + Const.MainView.imageTopPadding + 25)
            .padding(.horizontal, 16)
        }
        .padding(.top, isIsland ? Const.MainView.imageTopPadding : Const.MainView.imageTopPadding + 2) // чуть чуть пониже если нет челки
        .scrollDismissesKeyboard(.interactively)
    }

    private func headerView() -> some View {
        // Если закрыт включаем формулы, а если открыт то готовые значения
        // Возмонжо ввести еще одну переменную, которая будет срабатывать с анимацией
        VStack(spacing: 2.0) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: showFullAvatar ? 125 + (28 - UIFont.preferredFont(forTextStyle: .title1).pointSize) : 0)
            HStack {
                Text(viewModel.userName)
                    .font(showFullAvatar ? .title3 : .system(size: viewModel.titleFontSize, weight: .medium))
                    .foregroundStyle(showFullAvatar ? .white : colorScheme == .dark ? .white : .black)
                if showFullAvatar {
                    Spacer()
                }
            }
            HStack(spacing: 2.0) {
                Text(viewModel.userPhoneNumber)
                Text(Const.General.bulletPointSymbol)
                Text(viewModel.userNickname)
                if showFullAvatar {
                    Spacer()
                }
            }
            .frame(height: max(showFullAvatar ? 20 : 20 - pow(viewModel.offset.y * 0.05, 2), isIsland ? 4 : 8)) // Сделал экспоненциальный рост с минимальным значением 4 или 8
            .foregroundColor(Color(uiColor: .systemGray))
            .font(.system(size: viewModel.descriptionFontSize, weight: .regular))
            .opacity(viewModel.headerOpacity)
            .padding(.bottom, showFullAvatar ? viewModel.headerPadding + 10.0 - (28 - UIFont.preferredFont(forTextStyle: .title1).pointSize) : viewModel.headerPadding) // 25 если увеличенный и 10 если не увеличенный
            Divider()
                .opacity(!showFullAvatar && viewModel.offset.y > 90 ? 1 : 0)
                .padding(.horizontal, -16)
        }
        .frame(maxWidth: .infinity)
        .background(!showFullAvatar && viewModel.offset.y > 50 ? Color(uiColor: .systemGray6) : .clear)
        .id(Const.MainView.headerViewId)
    }
    
    private func tapArea() -> some View {
        if viewModel.offset.y == 0 {
            return AnyView(
                Rectangle()
                    .ignoresSafeArea()
                    .frame(maxWidth: showFullAvatar ? .infinity : 90)
                    .frame(height: showFullAvatar ? 310 : 90)
                    .foregroundStyle(.red)
                    .opacity(0.01)
                    .padding(.top, showFullAvatar ? 0 : 30)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showFullAvatar.toggle()
                        }
                    }
            )
        }
        return AnyView(EmptyView())
    }

    private func scrollViewCells() -> some View {
        VStack(spacing: 24.0) {
            emptyCells()
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
                    .foregroundStyle(showFullAvatar ? .white : .blue)
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.top, self.isIsland ? Const.MainView.imageTopPadding : Const.MainView.imageTopPadding + 2)
    }
}

// MARK: - PreviewProvider
struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileView(viewModel: .init(user: .mock()))
    }
}
