//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ульта on 06.04.2025.
// import Foundation
import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(5)
        
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(5)
        
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        // Выводим все доступные алёрты для отладки
        for alert in app.alerts.allElementsBoundByIndex {
            print("Alert found: \(alert.label)")
        }
        
        // Пытаемся найти алёрт с текстом "Раунд окончен!"
        let alert = app.alerts["Раунд окончен!"]
        
        // Ждем немного дольше для появления алёрта
        sleep(10)
        
        // Проверяем его существование и нужные свойства
        XCTAssertTrue(alert.exists, "Алерт не найден!")
        XCTAssertTrue(alert.label == "Раунд окончен!", "Неверный текст алёрта!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз", "Неверная надпись на кнопке!")
    }

    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
    
    
    
}
