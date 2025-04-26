# ACABOT ver.2
**Auto Classification Album Based On TensorFlow/Turi**
  
ACABOT is a mobile application that automatically classifies a user's photo library into predefined categories and organizes them into albums.  
Originally developed using Objective-C and TensorFlow, ACABOT ver.2 reimplements the project with Swift and CoreML for better mobile performance and user experience.

## Features
- Classify unorganized photos into default categories (Human, Animal, Food, Landscape, Concert, etc.)
- Improved speed and performance using CoreML
- Display latest photo as album thumbnail (instead of static cover)
- Allow users to create custom albums (no duplicate album names)
- Allow users to delete custom albums (default categories cannot be deleted)
- Support multi-selection and bulk deletion of photos
- Efficient photo management without increasing device storage usage

## Screenshots 
<div>
<img width="200" src="https://user-images.githubusercontent.com/28393778/50203946-7c842400-03a6-11e9-9c93-ff2c00cd809a.png"></img>
<img width="200" src="https://user-images.githubusercontent.com/28393778/50203967-8a39a980-03a6-11e9-8f7b-bc3e1cb12f7b.jpg"></img>
</div>

## Technologies Used
- Swift
- UIKit
- CoreML

## Project Background
The original ACABOT was built using TensorFlow, but deploying TensorFlow models on iOS led to large app sizes and slower inference speeds.  
To optimize performance for mobile devices, this version converts the machine learning model to CoreML and reimplements the application in Swift, achieving a lighter, faster user experience.

---
> This project demonstrates real-world experience in applying machine learning to mobile applications, optimizing models for mobile environments, and improving user-centered UX design.

