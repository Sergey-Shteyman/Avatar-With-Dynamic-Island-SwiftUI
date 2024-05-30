//
//  ProfileView.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.11.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import SwiftUI

// TODO: - Настроить высоту панели навигации

// TODO: - Сделать адапативную верстку под разные модели айфонов

// TODO: - Сделать так, чтобы имя пользователя не уезжало вниз при перетягивании

// TODO: - Добавить градиент под заголовки

// MARK: - ConstructorProfileView
struct ConstructorProfileView<Content: View>: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init
    
    let content: Content
        
    init(viewModel: ViewModel, @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }
    
    @State private var showFullAvatar: Bool = false
    @State private var isIsland: Bool = false
    
    @State private var showReactionsBG = 0
    
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
                avatarView()
                scrollView(bounds: bounds)
                    .zIndex(showReactionsBG == 1 ? 3 : 0)
                navigationButtons()
                    .zIndex(3)
//                tapArea()
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
        let offsetImage = max(-viewModel.offset.y * 1.19, -Const.MainView.imageSize - 12)
        let negativeOffset = max(-viewModel.offset.y * 0.15, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        return Circle()
            .fill(.black)
            .frame(width: Const.MainView.imageSize, height: Const.MainView.imageSize, alignment: .center)
            .scaleEffect(viewModel.scale)
            .offset(y: viewModel.offset.y < 0 ? negativeOffset : offsetImage)
            .tag(Const.MainView.imageViewId)
    }

    private func avatarView() -> some View {
        let offsetImage = max(-viewModel.offset.y, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        let negativeOffset = max(-viewModel.offset.y * 0.1, -Const.MainView.imageSize + Const.MainView.imageSize.percentage(1))
        return AvatarViewRepresentable(shouldShow: showFullAvatar)
            .frame(height: 100)
            .scaleEffect(viewModel.scale)
            .blur(radius: viewModel.blur)
            .opacity(showFullAvatar ? 1 : viewModel.avatarOpacity)
            .offset(y: viewModel.offset.y < 0 ? negativeOffset : offsetImage)
            .onChange(of: viewModel.offset.y, perform: { offset in
                if offset <= -30 && !showFullAvatar  {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showFullAvatar = true
                    }
                }
                if offset >= 10 && showFullAvatar {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showFullAvatar = false
                    }
                }
            })
    }

    private func scrollView(bounds: GeometryProxy) -> some View {
        OffsetObservingScrollView(offset: $viewModel.offset) {
            LazyVStack(
                alignment: .center,
                pinnedViews: viewModel.isHeaderPinningEnabled ? [.sectionHeaders] : []
            ) {
                Section( header: headerView()) {
                    ForEach(0..<2) { _ in
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.purple.opacity(0.5))
                            .frame(height: 60)
                    }
                    .offset(y : showFullAvatar ? 200 : 0)
                }
            }
            .padding(.top, Const.MainView.imageSize + Const.MainView.imageTopPadding + 30)
            .padding(.horizontal, 16)
        }
        .padding(.top, isIsland ? Const.MainView.imageTopPadding : Const.MainView.imageTopPadding + 2)
        .scrollDismissesKeyboard(.interactively)
        .overlay(alignment: .bottom) {
            emojiMenu()
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 5.0) {
            VStack(spacing: 0) {
                HStack {
                    Text(viewModel.userName)
                        .font(.system(size: 22, weight: .semibold))
                        .scaleEffect(viewModel.textScale)
                        .foregroundStyle(showFullAvatar ? .white : .black)
                    if showFullAvatar {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(!showFullAvatar && viewModel.offset.y > 150 ? Color(uiColor: .systemGray6) : .clear)
                Divider()
                    .padding(.horizontal, -16)
                    .opacity(!showFullAvatar && viewModel.offset.y > 150 ? 1 : 0)
            }
            HStack(spacing: 4.0) {
                Text("\(viewModel.offset.y)")
                Text(Const.General.bulletPointSymbol)
                Text(viewModel.userNickname)
                if showFullAvatar {
                    Spacer()
                }
            }
            .foregroundColor(Color(uiColor: .systemGray))
            .opacity(viewModel.headerOpacity)
        }
        .offset(y : showFullAvatar ? 180 : 0)
        .id(Const.MainView.headerViewId)
    }
    
    private func emojiMenu() -> some View {
        let groupedEmodji = groupAndSortEmodji(emoji: emodji)
        return ZStack(alignment: .bottom) {
            if showReactionsBG == 1 {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.yellow.opacity(0.5))
                    .ignoresSafeArea()
                    .zIndex(2)
                    .onTapGesture {
                        showReactionsBG = 0
                    }
            }
            VStack {
                ScrollView {
                    ScrollViewReader { _ in
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(groupedEmodji, id: \.key) { (key: String, value: [Emoji]) in
                                Text(key)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 15))
                                    .id(key)
                                    .padding(.top, 5)

                                VStack(alignment: .leading, spacing: 0) {
                                    let chunkedValue = value.chunked(into: 6)

                                    ForEach(0..<chunkedValue.count, id: \.self) { idx in
                                        HStack {
                                            ForEach(chunkedValue[idx], id: \.uuid) { sticker in
                                                Image("boxer-64x64-3818895")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: UIScreen.main.bounds.width / 11, height: 60)
                                                    .padding(.horizontal, 3)
                                                    .onTapGesture {
                                                        
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 5)
                .frame(maxWidth: UIScreen.main.bounds.width - 32, maxHeight: showReactionsBG == 1 ? 330 : 0)
                .background(.black)
                .cornerRadius(20)
                .animation(.interpolatingSpring(stiffness: showReactionsBG == 1 ? 300 : 600,
                                                damping: showReactionsBG == 1 ? 21 : 60).delay(0.05), value: showReactionsBG)
                .padding(.top, viewModel.scale < 0.360 ? 50 : showFullAvatar ? 280 : 180)
                Spacer()
            }
            .zIndex(3)
        }
    }
    
    private func tapArea() -> some View {
        if viewModel.offset.y == 0 {
            return AnyView(
                Rectangle()
                    .ignoresSafeArea()
                    .frame(maxWidth: showFullAvatar ? .infinity : 90)
                    .frame(height: showFullAvatar ? 250 : 90)
                    .foregroundStyle(.red)
                    .opacity(0.5)
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

    private func navigationButtons() -> some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                AnyView(Text("Edit"))
                    .foregroundStyle(showFullAvatar ? .white : .blue)
            }
            .disabled(showReactionsBG == 1 ? true : false)
        }
        .padding(.horizontal, 16.0)
        .padding(.top, self.isIsland ? Const.MainView.imageTopPadding : Const.MainView.imageTopPadding + 2)
    }
    
    private func groupAndSortEmodji(emoji: [Emoji]) -> [(key: String, value: [Emoji])] {
        let grouped = Dictionary(grouping: emoji) { $0.name }
        return Array(grouped).sorted(by: { $0.key < $1.key })
    }
}

// MARK: - PreviewProvider
struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        ConstructorProfileView(viewModel: .init(user: .mock())) {
            emptyCells()
        }
    }
}

struct Emoji {
    let uuid = UUID()
    let id: String
    let name: String
    let image: UIImage
}

var emodji: [Emoji] = [
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "Puslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
    Emoji(id: "72", name: "shmuslan", image: UIImage(named: "Puslan")!),
]

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}


import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode =  self.loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
