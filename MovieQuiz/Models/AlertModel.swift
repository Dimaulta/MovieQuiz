//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ульта on 13.03.2025.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
