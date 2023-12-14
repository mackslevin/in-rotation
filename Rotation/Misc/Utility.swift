//
//  Utility.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//


import SwiftUI

struct Utility {
    
    
    static let exampleEntity = MusicEntity(title: "Cool Title", artistName: "Great Artist", numberOfTracks: 15, songTitles: [], type: .album)
    static let exampleTag = Tag(title: "Cool Tag", symbolName: "photo.fill", musicEntities: []) 
    
    @MainActor
    static func dismissKeyboard() {
        #if !ACTIONEXTENSION
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
        #endif
    }
    
    static func formattedTimeInterval(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))

        let formattedString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return formattedString
    }
    
    static func wasOverAnHourAgo(date: Date) -> Bool {
        let secondsInAnHour: TimeInterval = 3599
        return abs(date.timeIntervalSinceNow) > secondsInAnHour
    }
    
    static func stringForType(_ type: EntityType) -> String {
        if type == .song {
            return "Song"
        } else if type == .album {
            return "Album"
        }
        
        return ""
    }
    
    static func defaultCorderRadius(small: Bool) -> CGFloat {
        if small { return 4 }
        return 10
    }
    
    static func prettyDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    static func customBackground(withColorScheme colorScheme: ColorScheme) -> some View {
        let bg = Rectangle().ignoresSafeArea().foregroundStyle(colorScheme == .dark ? Color.clear : Color.orange)
            .opacity(0.07)
        return bg
    }
    
    static var sfSymbols: [String] = [
        "tag.fill",
        "headphones",
        "music.note",
        "music.note.list",
        "music.quarternote.3",
        "music.mic",
        "hifispeaker.fill",
        "hifispeaker.2.fill",
        "speaker.fill",
        "speaker.zzz.fill",
        "speaker.wave.3.fill",
        "dial.low.fill",
        "dial.medium.fill",
        "dial.high.fill",
        "metronome.fill",
        "amplifier",
        "pianokeys.inverse",
        "tuningfork",
        "guitars.fill",
        "radio.fill",
        "horn.fill",
        "music.note.house.fill",
        "person.fill",
        "person.2.fill",
        "person.wave.2.fill",
        "person.2.wave.2.fill",
        "person.3.sequence.fill",
        "person.and.background.dotted",
        "figure.and.child.holdinghands",
        "figure.2.and.child.holdinghands",
        "figure.walk",
        "figure.wave",
        "figure.fall",
        "figure.run",
        "figure.roll.runningpace",
        "figure.cooldown",
        "figure.core.training",
        "figure.dance",
        "figure.mind.and.body",
        "brain.fill",
        "hand.thumbsup.fill",
        "hand.thumbsdown.fill",
        "hands.clap.fill",
        "alarm.fill",
        "gamecontroller.fill",
        "paintpalette.fill",
        "cup.and.saucer.fill",
        "mug.fill",
        "wineglass.fill",
        "birthday.cake.fill",
        "cube.fill",
        "clock.fill",
        "sunglasses.fill",
        "comb.fill",
        "film",
        "movieclapper.fill",
        "ticket.fill",
        "tree.fill",
        "gift.fill",
        "crown.fill",
        "teddybear.fill",
        "shoe.fill",
        "binoculars.fill",
        "stroller.fill",
        "key.fill",
        "lock.fill",
        "lock.open.fill",
        "house.lodge.fill",
        "tent.fill",
        "laser.burst",
        "fireworks",
        "balloon.fill",
        "party.popper.fill",
        "puzzlepiece.fill",
        "theatermask.and.paintbrush.fill",
        "theatermasks.fill",
        "scroll.fill",
        "paintbrush.pointed.fill",
        "paintbrush.fill",
        "dice.fill",
        "wand.and.stars",
        "basket.fill",
        "cart.fill",
        "bag.fill",
        "handbag.fill",
        "briefcase.fill",
        "scissors",
        "bell.fill",
        "flag.fill",
        "flag.2.crossed.fill",
        "umbrella.fill",
        "medal.fill",
        "trophy.fill",
        "hammer.fill",
        "dumbbell.fill",
        "soccerball.inverse",
        "baseball.fill",
        "basketball.fill",
        "football.fill",
        "tennis.racket",
        "cricket.ball.fill",
        "volleyball.fill",
        "skateboard.fill",
        "surfboard.fill",
        "gym.bag.fill",
        "oar.2.crossed",
        "studentdesk",
        "paperclip",
        "newspaper.fill",
        "magazine.fill",
        "clipboard.fill",
        "doc.fill",
        "archivebox.fill",
        "folder.fill",
        "paperplane.fill",
        "tray.and.arrow.up.fill",
        "tray.and.arrow.down.fill",
        "books.vertical.fill",
        "book.fill",
        "book.closed.fill",
        "bookmark.fill",
        "backpack.fill",
        "window.casement",
        "window.awning.closed",
        "window.awning",
        "wifi.router",
        "washer",
        "videoprojector",
        "video.doorbell",
        "toilet.fill",
        "table.furniture",
        "stairs",
        "stove",
        "spigot",
        "sofa",
        "sink",
        "shower",
        "roman.shade.closed",
        "refrigerator",
        "poweroutlet.type.a",
        "poweroutlet.type.b",
        "popcorn.fill",
        "pipe.and.drop",
        "pedestrian.gate.closed",
        "pedestrian.gate.open",
        "oven",
        "microwave",
        "lightswitch.off.square",
        "lightbulb",
        "light.recessed.3",
        "light.recessed",
        "light.cylindrical.ceiling",
        "lamp.table",
        "lamp.floor",
        "lamp.desk",
        "lamp.ceiling",
        "humidifier",
        "house",
        "hifireceiver",
        "frying.pan",
        "fireplace",
        "figure.walk.arrival",
        "fan.desk",
        "fan.and.light.ceiling",
        "dryer",
        "door.sliding.left.hand.closed",
        "door.left.hand.closed",
        "door.garage.closed",
        "door.french.open",
        "dishwasher",
        "curtains.closed",
        "cooktop",
        "chandelier",
        "chair.lounge",
        "chair",
        "cabinet",
        "blinds.vertical.closed",
        "bed.double",
        "bathtub",
        "pin",
        "airplane",
        "airplane.arrival",
        "airplane.circle",
        "airplane.circle.fill",
        "airplane.departure",
        "bicycle",
        "bicycle.circle",
        "bicycle.circle.fill",
        "bolt.car",
        "bolt.car.circle",
        "bolt.car.circle.fill",
        "bolt.car.fill",
        "box.truck",
        "box.truck.badge.clock",
        "box.truck.badge.clock.fill",
        "box.truck.fill",
        "bus",
        "bus.doubledecker",
        "bus.doubledecker.fill",
        "bus.fill",
        "cablecar",
        "cablecar.fill"
    ]
}
