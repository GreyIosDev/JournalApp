//
//  Recording.swift
//  JournalApp
//
//  Created by Grey  on 27.05.2023.
//

import Foundation
struct Recording: Identifiable {
    let id = UUID()
    let date: Date
    let url: URL
}
