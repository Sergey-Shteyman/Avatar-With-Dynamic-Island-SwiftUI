//
//  User.swift
//  DynamicIslandDemo
//
//  Created by Konstantin Stolyarenko on 09.07.2023.
//  Copyright © 2023 SKS. All rights reserved.
//

import Foundation

// MARK: - User

struct User {
    let name: String
    let avatarImageName: String
    let phoneNumber: String
    let nickname: String
}

// MARK: - User Mock Extension

extension User {

    static func mock(
        name: String = "PuslAnus",
        avatarImageName: String = "Puslan",
        phoneNumber: String = "+99999999",
        nickname: String = "@Puslanus"
    ) -> Self {
        .init(
            name: name,
            avatarImageName: avatarImageName,
            phoneNumber: phoneNumber,
            nickname: nickname
        )
    }
}
