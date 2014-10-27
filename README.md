## FTStepCounter

_Will only work with M7 and M8 enabled devices_

### About
FTStepCounter facilitates the M7 motion coprocessor available since the iPhone 5s for recording steps. It records steps in real time as well as while the app is not active by acquiring the intermittent steps made – for up to 7 days according to the Apple documentation. In addition to that, the app saves all steps recorded in the user defaults until the count has been reset by user interaction.
As a bonus the app displays the current type of activity on the screen.

### Usage
Make sure your controller which facilitates the step counter complies with the
```
FTStepCountControllerDelegate
``` 
delegate protocol.
It is recommended to use the class as a singleton. After initialization the controller will happily collect all steps and will also look beforehand if there have been any steps made since the last time the app was active.

### Author
Andre Hoffmann
github@effzehn.de

### License
See LICENSE.md
