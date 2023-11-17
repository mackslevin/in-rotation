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
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
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
        "window.casement",
        "window.awning.closed",
        "window.awning",
        "wifi.router",
        "washer",
        "videoprojector",
        "video.doorbell",
        "toilet",
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
        "popcorn",
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
