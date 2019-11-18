//
//  ContentView.swift
//  BreatheAppCards
//
//  Created by Arlind Aliu on 30.09.19.
//  Copyright © 2019 Arlind Aliu. All rights reserved.
//
import SwiftUI

struct ContentView : View {
    private let exercises = Exercise.allExercises
    
    @State var isDetailsPresented: Bool = false
    @State var isExcerciseCompletedPresented: Bool = false
    @State var excerciseCompleted: Bool = false
    @State var cards = [Card(id: 0), Card(id: 1), Card(id: 2)]
    @State var todaysExercisePercentage = 0.65
    
    let animationDuration = 0.8
    
    
    func backgroundOpacity() -> Double {
        return Double(cards.reduce(0) {$0 + $1.percentPresented})
    }
    
    var body: some View {
        ZStack {
            HomeView(percentage: $todaysExercisePercentage)
            
            ExerciseBackgroundView()
                .opacity(backgroundOpacity())
            
            
            
            //(0..<exercises.count).map {Card(id: $0)}
            
            if !isExcerciseCompletedPresented {
                CardStackView(fullSizeCard: $isDetailsPresented,
                              cards: self.$cards,
                              animationDuration: animationDuration)
                    .onAppear(perform: {
                        for i in (0..<self.cards.count) {
                            self.cards[i].position = .bottomn
                        }
                    })
            }
            

            if isDetailsPresented {
                ExcerciseAnimationView(animationDuration: self.animationDuration*2).onTapGesture {
                    self.isExcerciseCompletedPresented = true
                }
            }
            
            if isExcerciseCompletedPresented {
                ExcerciseCompletedView().onTapGesture {
                    self.isDetailsPresented = false
                    self.isExcerciseCompletedPresented = false
                }
            }
            
        }.background(Color.black).edgesIgnoringSafeArea([.bottom])
    }
    
}

struct DailyGoalView: View {
    var body: some View {
        (Text("10min ").bold() + Text("daily goal"))
            .font(.bodyText)
            .foregroundColor(Color.white)
    }
}


struct ExerciseBackgroundView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea([.top, .bottom])
            VStack {
                
                (Text("Select ")
                    .font(.bodyText).bold() +
                    Text("breathe exercise")
                        .font(.bodyText))
                    .foregroundColor(Color.white)
                    .offset(y: 25)
                Spacer()
            }
        }
    }
}
