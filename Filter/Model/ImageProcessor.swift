//
//  ImageProcessor.swift
//  Filter
//
//  Created by Juan Jesus Cueto Yabar on 19/02/18.
//  Copyright © 2018 Juan Jesus Cueto Yabar. All rights reserved.
//

import Foundation
import UIKit

class ImageProcessor {
    
    var image : RGBAImage
    var avgRed = 0
    var avgGreen = 0
    var avgBlue = 0
    
    init(image: UIImage) {
        self.image = RGBAImage(image: image)!
    }
    
    func setImage(image: UIImage) {
        self.image = RGBAImage(image: image)!
        self.getAverages()
    }
    
    func getAverages() {
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<self.image.height {
            for x in 0..<self.image.width {
                let index = y * image.width + x
                var pixel = self.image.pixels[index]
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let count = self.image.width * image.height
        avgRed = totalRed/count
        avgGreen = totalGreen/count
        avgBlue = totalBlue/count
    }
    
    func addFilter(filter:String) {
    }
    
    func removeColor( pixel: Pixel, option: Int) ->Pixel {
        var pixel = pixel
        switch option {
        case 0:
            pixel.red = 0
        case 1:
            pixel.green = 0
        case 2:
            pixel.blue = 0
        default:
            return pixel
        }
        return pixel
    }
    
    func swapColor( pixel: Pixel, option: Int) -> Pixel {
        var pixel = pixel
        if(option == 0) {
            let temp = pixel.red
            pixel.red = pixel.blue
            pixel.blue = pixel.green
            pixel.green = temp
        } else {
            let temp = pixel.blue
            pixel.blue = pixel.red
            pixel.red = pixel.green
            pixel.green = temp
        }
        return pixel
    }
    
    func brightnessAdjust( pixel: Pixel, percent: Double) ->Pixel{
        //Calculate the percent value
        var pixel = pixel
        let value = percent/2
        
        // Modify the pixel
        let red = round(Double(pixel.red) * value)
        let green = round(Double(pixel.green) * value)
        let blue = round(Double(pixel.blue) * value)
        
        //Applying the new pixels
        pixel.red = UInt8(max(0, min(255, red)))
        pixel.green = UInt8(max(0, min(255, green)))
        pixel.blue = UInt8(max(0, min(255, blue)))
        return pixel
    }
    
    
    func changeContrast( pixel: Pixel, modifier: Int) -> Pixel {
        
        var pixel = pixel
        let redDiff = Int(pixel.red) - avgRed
        let greenDiff = Int(pixel.green) - avgGreen
        let blueDiff = Int(pixel.blue) - avgBlue
        
        //Applying the new values
        pixel.red = UInt8(max(min(255, avgRed + modifier * redDiff), 0))
        pixel.green = UInt8(max(min(255, avgGreen + modifier * greenDiff), 0))
        pixel.blue = UInt8(max(min(255, avgBlue + modifier * blueDiff), 0))
        
        return pixel
    }
    
    
    func warmAdjust( pixel: Pixel, modifier: Int) -> Pixel {
        var pixel = pixel
        let redDiff = Int(pixel.red) - avgRed
        if(redDiff > 0) {
            // Changes the pixel to the the specified modifier
            pixel.red = UInt8(max(0, min(255, avgRed + redDiff * (2*modifier))))
            pixel.blue = UInt8(max(0, min(255, avgBlue + redDiff / (2*modifier))))
        }
        
        return pixel
    }
    
    func processImage(filter: String, modifier value: Double) -> UIImage {
        for y in 0..<self.image.height {
            for x in 0..<self.image.width {
                let index = y * self.image.width + x
                let pixel = self.image.pixels[index]
                switch filter.lowercased() {
                case "remove colors":
                    self.image.pixels[index] = removeColor(pixel: pixel, option: 0)
                case "swap colors":
                    self.image.pixels[index] = swapColor(pixel: pixel, option: 0)
                case "brightness adjust":
                    self.image.pixels[index] = brightnessAdjust(pixel: pixel, percent: value)
                case "change contrast":
                    self.image.pixels[index] = changeContrast(pixel: pixel, modifier: Int(value))
                case "warm adjust":
                    self.image.pixels[index] = warmAdjust(pixel: pixel, modifier: Int(value))
                default:
                    print("The filter", filter.lowercased() , "is not available.")
                }
                
                
            }
        }
        return self.image.toUIImage()!
    }
    
}

