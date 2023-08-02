# Event 4 Me

English | [简体中文](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/README_ZH.md)

## Project Overview

This project is my undergraduate graduation project, built using the Flutter framework, and based on Google Map, it provides an app for users to provide surrounding events based on user location. The project was completed on April 26, 2023, and I used this App to participate in the graduation exhibition held by the school, and wrote an academic report on this project, which finally achieved good results.
**Warning: Please do not use this project for your personal projects or for commercial use. The ownership of the project belongs to myself and Swansea University, UK.**   

This project also has a matching back-end server, which I also developed using Jetty as the REST API provider. The code for the server can be found here

### Project Rationale
  
When I first arrived in the UK, I often encountered the inexplicable disappearance of buses. Especially in the rainy night in November, the cold wind was blowing, my hair was messy, and my mood was also very upset. Later I learned that the cancellation of the bus was generally due to construction reasons that caused the route to be adjusted, the bus broke down halfway, and other non-human factors. At this time, I was thinking, it would be great if I knew it earlier. Because, I can plan my travel plans in advance. If the bus does not come for a long time, I might choose to take other buses or take a taxi to the destination. There is absolutely no need to waste meaningless time on a bus that will never come. Then, I found the Twitter account of the bus operating company, but they did not mention any issues about temporary changes to the route or bus situation apart from sending some discount information.
  
At this time, I thought, maybe there is such an app that allows users to post some events around them based on their location. For example, a user sees a bus breaking down halfway and then uploads it as an Event to the app. At this time, there might be a user waiting for this bus. If he/she can see this message, he/she might make a more wise decision.
  
If we step back, the app will not be limited to such a small scene, there are many scenarios for this application. For example, personally, when I first came to the UK, my credit card had a problem, which made it impossible to pay online. Unfortunately, almost all online food ordering apps only support online payment, and cannot pay on delivery. Then, due to the UK's epidemic prevention policy at that time, foreigners who first arrived in the UK must be home-quarantined for 14 days before they can go out. I didn't have anything to eat at the time, I felt helpless. I hope someone can help me buy some food, even if I give more tips, I am very willing, but unfortunately there is no such platform. Therefore, this app can also do similar things, such as helping helpless international students who first came to the UK for their first dinner.
  
I always believe that people live in a circle. Whether it is a circle of friends or a comfort zone, it is difficult to integrate into a new circle when we jump out of this circle. For example, if I have friends in the UK, I might seek his help. Another example, if my English was good enough at the time, I might use it to knock on the door of the person in the opposite dormitory and seek help. But, this is not an easy thing. I believe that my app can achieve this function, allowing people who are not in this circle to also have a channel to seek the help of people in the circle. So, I decided to create this app.
  
### Project Introduction
  
When the user opens the App, it will request to get the user's location. After the user allows it, the events around the user will be displayed.  

Each Event will be represented with an icon corresponding to its category. After the user clicks the Event, a secondary menu will pop up, displaying the information of the Event, such as title, start and end time, location, description, etc.  

Use different color text to distinguish whether the Event has expired. When the Event is expired, it will display red. If the Event has not started, it will be yellow. If the Event has started and has not ended, it will be green.  
At the same time, users can like the Event and see the number of likes for the current Event.

On the settings page, there will be an Event List, which will display all the Events published by the user, including all expired and unexpired events. Users can click to edit the Event, all data will be directly inherited from the previous Event and can be modified. At the same time, different colors of time are used to indicate whether the event has expired.
  
## Project Features
  
- Multi-platform: Due to the characteristics of Flutter, this project can be deployed on most terminals. Including Android, Apple, Web applications, Windows
- Interaction with the server background: The server backend uses Jetty as the provider of the REST Web API, and the client will interact with the server using JSON
- Login system: Use Google Firebase's Authentication as the backend verification server, and the server will also check the user's login status
- Location-based services: Based on user location, call Google Map to get user location, and use algorithms in the server to return the Events around the user
- Classification of Events: Use preset 5 categories to divide Events into different types. At the same time, new categories can be added very conveniently
- Multilingual: The App supports multiple languages, and the language file is independent, and a new language can be added very conveniently
- Auto-refresh function: Users can set the Event to auto-refresh
- Add Event: Add Event based on user location, users can customize and edit all information, and can freely choose the location
- Location conversion: Will not display latitude and longitude (numbers), will replace it with readable text, such as 1xx Park Street, Sketty, Uplands, Swansea.
- Event List: Users can find their own published Event list in the settings page. The list will display the title and publishing time of the Event. And it will remind users of the status of the Event through different colors of time, such as not started, started, and ended.
- Edit Event: Users can click on the Event in the list to edit the existing Event. All data of the original Event will be added to the editing page, and users can modify it
  
## Project Challenges
  
- Starting from scratch, beginning with learning Flutter: I have never been exposed to the Flutter framework or the Dart language before. I started learning Dart and Flutter from scratch for this project.
- Independent development: During the development process, I solved all Flutter-related problems on my own. Although my thesis advisor is proficient in Jetty, he does not understand Flutter, so I was completely independent in learning and developing in Flutter.
- Data interaction: The client and the server use JSON-formatted files for data exchange. However, they use different programming languages (Jetty uses Java, and Flutter uses Dart), making it a significant challenge to enable data communication between the server and the client.
- Server: I independently wrote the backend server code and designed the server framework.
- Database: I designed and used a MySQL database, and the database relationships meet 2NF.
- Backend server: The backend server uses Jetty and different URLs to access specific interfaces for data interaction. The interfaces meet the hierarchical relationship, and the server can call data from the database, read it, and package it into the appropriate JSON format to return to the client.
- Double-end login check: The client checks the user's login, and the server also checks the user's login status through the user's token.
- Data storage: MySQL is used on the server side to store user data. The client cannot directly read and call data, ensuring data independence and security.
- Independent language files: All displayed text in the project is replaceable. Different language configuration files are invoked according to different language settings to read the text.
- Version control: After completing a major function, I would commit it. The details of version control can be seen in the commit history of the main branch.
   
## Third-party Libraries Used in the Project
- firebase related firebase_core: ^2.9.0
- Choosing images image_picker: ^0.8.7
- Custom icons material_design_icons_flutter: ^6.0.7096
- Global variables shared_preferences: ^2.0.13
- Photo management photo_manager: ^2.5.2
- Multilingual support easy_localization: ^3.0.0
- Getting user location geolocator: ^9.0.2
- Mobile vibration vibration: ^1.7.5
- Converting latitude and longitude to address geocoding: ^2.1.0
- Used for translation in EventDetail html: ^0.15.0
- Used to handle permission requests permission_handler: ^10.2.0
- Used to send messages and get user deviceToken firebase_messaging: ^14.4.0
- Related to notification display flutter_local_notifications: ^9.9.1
- Generating a variable and continuously monitoring rxdart: ^0.27.7
- Related to map markers clustering google_maps_cluster_manager: ^3.0.0+1
- cupertino_icons: ^1.0.2
- firebase_auth: ^4.1.3
- google_maps_flutter: ^2.0.1
- flutter_easyloading: ^3.0.3
- http: ^0.13.5
  
## Project Demo
  
### Screenshots
  
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%202.png)
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%203.png)
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%206.jpg)
