# BiologyDive

BiologyDive is an application for learning basics of microbiology in interactive and entertaining way.
The goal of the app is to let the user see the structure of the cell in a way that cannot be done in school.
Users can easily zoom in discover what are the cells made of.

![screencast1](https://user-images.githubusercontent.com/16286046/55580231-67938c80-571a-11e9-94c7-329135ee6c42.gif) 
![screencast2](https://user-images.githubusercontent.com/16286046/55580287-8c87ff80-571a-11e9-9da2-c55f88e600b9.gif) 
![screencast3](https://user-images.githubusercontent.com/16286046/55580293-8e51c300-571a-11e9-858b-06b1c89509ed.gif)

## Features
* Zoom in and navigate inside the cell
* Tap on an organella (element inside the cell) to dive deeper
* Tap on bottom sheet to learn more about what you see
* Browse all the elements using the hint cards on the bottom

## Data
### Where is data coming from?
All data is stored in `data.json` file. It contains definition of all the elements as well as their composition.  
Each element has fields like id, name imagePath, description and so on.  

### How are the children composed?
Each element in json file has `children` property. Each child has a reference id to its definition, as well as its relative position inside the parent. The distance from left, top and the size of the child are being used by `Positioned` inside a `Stack` to compose the elements how nature designed them :) 

### Accuracy of data
The structure of the cells is determined by me on the basis of multiple google results. I don't guarantee they are 100% accurate, I can only say I did my best. :)

The descriptions are based on references displayed in the provided links. Mostly coming from Wikipedia.

## Images
All the cell images were created by me using Flare. You can check them out in [here](https://www.2dimensions.com/a/marcinus/files/recent/all).

## Boring code FAQ
### Why there are so many offset and zoom variables?
To have the the zoom and transition work. Whenever user starts the zoom or transition, we need to remember the offset and zoom values when he started, this way we can reference to them durgin the gesture even after we updated the position or zoom.

### What's nextId for?
Even though Flare is awesome and lightweight, it does take time to render a new image. After zooming has done, if we just replaced the image, there would be an empty frame where no image is drawn (caused by the time we need to draw a new image).  
`NextId` is used to draw a placeholder image before the animation ends and remove it after the new image is drawn. This way user cannot see there was a change.

### Why hintsController has initialScrollOffset?
There is possibility that all hint cards (at the bottom) visible at start match perfectly the screen width. User may not figure out that they are scrollable. By giving a slight offset at start we are ensuring that the view will be slightly moved which can indicate the user that it is scrollable.

### Why the cells in the small cards don't have any children but only border and fill?
Animated Flare animations can be expensive. I have removed the content of small cells to lower the risk of frozen frames.
