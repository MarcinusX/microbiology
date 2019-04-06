# BiologyDive

BiologyDive is an application for learning basics of microbiology in interactive and entertaining way.
The goal of the app is to let the user see the structure of the cell in a way that cannot be done in school.
Users can easily zoom in to discover what are the cells made of.

![screen_cast_1](https://user-images.githubusercontent.com/16286046/55671845-a8afac00-5894-11e9-813c-1de2489e30db.gif) 
![screen_cast_2](https://user-images.githubusercontent.com/16286046/55671846-ab120600-5894-11e9-8e48-401917ff6c4d.gif) 
![screen_cast_3](https://user-images.githubusercontent.com/16286046/55671847-ad746000-5894-11e9-9832-8ff913f9238c.gif) 

## Features
* Zoom in and navigate inside the cell
* Tap on an organella (element inside the cell) to dive deeper
* Tap on bottom sheet to learn more about what you see
* Browse all the elements using the hint cards at the bottom

## Data
### Where is data coming from?
All data is stored in `data.json` file. It contains definitions of all the elements as well as their composition.  
Each element has fields like id, name imagePath, description and so on.  

### How are the children composed?
Each element in json file has `children` property. Each child has a reference id to its definition, as well as its relative position inside the parent. The distance from left, top and the size of the child are being used by `Positioned` inside a `Stack` to compose the elements how nature designed them :) 

### Accuracy of data
The structure of the cells is determined by me on the basis of multiple google results. I don't guarantee they are 100% accurate, I can only say I did my best. :)

The descriptions are based on references displayed in the provided links. Mostly coming from Wikipedia.

## Images
All the cell images were created by me using Flare. You can check them out in [here](https://www.2dimensions.com/a/marcinus/files/recent/all).

## Boring code FAQ
### Why are there so many offset and zoom variables?
To have the zoom and transition work. Whenever user starts the zoom or transition, we need to remember the offset and zoom values when he started. This way we can continue to update the view when the zoom and the translation change by referencing to the starting point.

### What's nextId for?
Even though Flare is awesome and lightweight, it does take time to render a new image. After zooming is done, if we just replaced the image, there would be an empty frame where no image is drawn (caused by the time we need to draw a new image).  
`NextId` is used to draw a placeholder image before the animation ends and remove it after the new image is drawn. This way user cannot see there was a change.

### Why hintsController has initialScrollOffset?
There is possibility that all hint cards (at the bottom) visible at start match perfectly the screen width. User may not figure out that they are scrollable. By giving a slight offset at start we are ensuring that the view will be slightly moved which can indicate the user that it is scrollable.

### Why the cells in the small cards don't have any children but only border and fill?
Flare animations can be expensive. I have removed the content of small cells to lower the risk of frozen frames.
