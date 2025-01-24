//
//  Constants.swift
//  TPG
//
//  Created by Shane on 5/21/24.
//

import Foundation

typealias GameCode = String
typealias PlayerId = String
typealias AnswerText = String

struct Constants {
    
    static let numberOfQuestionsPerGame = 8
    static let questionTimerSeconds = 30
    
    static let questions = [
        "Create an NFL team name",
        "I never understood why _____.",
        "How come every time I _____, I _____.",
        "_____ drives me crazy.",
        "If I had one billion dollars, I would _____ ",
        "Netflix should have a show about _____",
        "This just in, a massive _____ has been spotted",
        "I keep having a dream about _____",
        "I am terrified of _____, but _____ doesn't scare me at all",
        "Remember when _____ was cool",
        "Coming to a theater near you, _____ the movie",
        "If you _____ you'll end up _____",
        "What is Santa Clauses other seasonal occupation?",
        "Disney presents, _____ on ice!",
        "Doorbell rings, there’s a package… what’s in the box?",
        "We present Apple’s new product i_____ .",
        "My favorite late night snack is _____. ",
        "🍻 Cheers too _____!",
        "I have no self-control when it comes to _____.",
        "Lord of the _____ .",
        "What does Obama do before bed?",
        "A midget, a priest, and a professor are in a bar… What happens next?",
        "_____  reminds me of my ex.",
        "Nobody likes a _____ .",
        "_____ a day keeps the doctor away.",
        "What would a goldfish say if it could talk?",
        "_____ is made out of _____ .",
        "If I were president, I would _____.",
        "If you could have one super power, what would it be?",
        "Congratulations, you’ve just won a new _____.",
        "You’re probably an idiot if you _____ .",
        "What did Abe Lincoln do in his spare time?",
        "Worst comes to worse we’ll just have to  _____.",
        "For lent I gave up _____.",
        "The newest product on the Infomercial Channel, _____!",
        "THIS JUST IN: Scientist finds a cure for Cancer, the only side effect is _____.",
        "Nothing disgust me more than _____.",
        "In today’s society there are some people that _____.",
        "Two thumbs up for _____.",
        "I’m so hungry I could eat a _____.",
        "I’m so hungry I could eat a _____.",
        "On the 7th day, God did not rest, but actually _____.",
        "Surprisingly, _____ turns me on.?",
        "_____, like a FUCKING BOSS!",
        "_____, the story of my life.",
        "_____ is my favorite thing ever!",
        "Guns don’t kill people, _____ kill(s) people.",
        "All I want for Christmas is _____.",
        "Ever since I was kid I dreamed of _____.",
        "If I could _____, it would be a miracle.",
        "I love to _____ at parties.",
        "If you could listen to any song right now, what would it be?",
        "Some people call me _____. Other people call me _____.",
        "I love the smell of _____ in the morning.",
        "When people make I contact with me, I like to _____ to freak them out.",
        "First thought that comes into your mind. Go!",
        "Nothings more embarrassing than _____.",
        "_____! Fun for the whole family.",
        "_____ puts me right to sleep.",
        "Only you can prevent _____.",
        "_____, the silent killer.",
        "I was recently arrested for _____.",
        "The first thing I do when I get out of bed in the morning is _____.",
        "When in doubt, _____ it out.",
        "Who is the greatest human to ever live?",
        "It’s a bird! It’s a plane! No, it’s _____!",
        "After a long day, nothing is better than _____.",
        "What the hell is a _____, and how do you use it?",
        "The secret to happiness is  _____.",
        "You can never stare directly at _____, for fear you’ll lose _____.",
        "Better late than _____.",
        "_____  is invite only. ",
        "While walking today, I saw _____.",
        "The main purpose for a computer is _____.",
        "If I could clone myself I would _____.",
        "I prefer _____ to humans!",
        "I've always wanted to punch _____ in the face.",
        "The last thing I want to do before I die is _____.",
        "I like to _____ when I’m stuck in traffic.",
        "I’m writing a book about _____.",
        "What is Batman’s guilty pleasure?",
        "If a caveman could send you a text, what would it say?",
        "What is the grossest way to describe the smell of a room?",
        "If you could be anywhere in the world right now, where would it be?",
        "What’s the most ridiculous fact you know?",
        "What’s the best type of cheese?",
        "I really hate when _____.",
        "Sometimes I like to eat _____.",
        "I always enjoy _____, usually right after _____.",
        "What is the most satisfying sound you can think of?",
        "In one sentence, how would you sum up the internet?"
    ]

    
    static let answerSubstitutionKey = "_____"
    
    struct Notifications {
        static let gameDidUpdate = NSNotification.Name("GameDidUpdate")
    }
    
    struct FirestoreKeys {
        static let gamesCollection = "Games"
        static let questionsCollection = "Questions"
        
        static let playersSubCollection = "players"
        static let questionsSubCollection = "questions"
        static let answersSubCollection = "answers"
    }
   
    struct Padding {
        struct Vertical {
            static var textFieldSpacing = 30.0
            static var bottomSpacing = 30.0
        }
    }
    
    struct Heights {
        static var textField: CGFloat = 65.0
        static var button: CGFloat = 75.0
    }
    
    struct WidthMultipliers {
        static let textField: CGFloat = 0.75
        static let button: CGFloat = 0.55
        static let iconImageView: CGFloat = 0.1
    }
    
    struct Text {
        static let answerContainerText = "Say Something"
    }
}


