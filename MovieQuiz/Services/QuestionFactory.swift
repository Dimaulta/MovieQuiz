//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ульта on 08.03.2025.
//

import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            
            
            
            if CommandLine.arguments.contains("--uitesting") {
                // Мок-изображение для UI-тестов
                imageData = Data(count: index * 1000) // Уникальный размер для каждого вопроса
                
                
                
            } else {
                
                do {
                    imageData = try Data(contentsOf: movie.imageURL)
                } catch {
                    print("Failed to load image")
                    return // В реальном случае прерываем, если изображение не загрузилось
                }
                
                let rating = Float(movie.rating) ?? 0
                
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                
                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
        
    }
} // это убрть есди уберу мок данные
