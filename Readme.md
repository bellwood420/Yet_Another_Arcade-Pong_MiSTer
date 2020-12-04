# Yet Another Arcade Pong for MiSTer

+ FPGA implementation of arcade Atari Pong(1972)
+ Ported to MiSTer from [pong-arcade-fpga](https://github.com/bellwood420/pong-arcade-fpga) 
+ There already exists Arcade Pong in official MiSTer cores, so this is an unofficial yet another version.

## Inputs
+ Keyboard
```
   Coin        : Any of the following keys will work
                 - F1 (Coin + Start 1P) 
                 - F2 (Coin + Start 2P)
                 - 1  (Start 1P)
                 - 2  (Start 2P)
                 - 5  (Coin 1)
                 - 6  (Coin 2)
   1P Up/Down  : W/S
   2P Up/Down  : Up/Down
```
+ Joystick, Paddle are supported

## What's the difference from the official core?
In terms of just playing the game, there is no major difference.

Technically it differs in the following way:
+ The official core implements asynchronous discrete logic circuit as-is on FPGA
+ My core implements it totally synchronously by treating clock signals to registers as datapaths for edge detection, and driving them by another clock.
I found this technique introduced in [this paper](http://www.cs.columbia.edu/~sedwards/papers/edwards2012reconstructing.pdf)

At first, I was trying to implement Pong in the same way as the official core.
But I gave it up since I encounterd intolerable unstability due to asynchronous factor.

## Why duplicate yet another core?
I wanted my fpga work to be enjoyed by more people.

Unfortunately my original work ([pong-arcade-fpga](https://github.com/bellwood420/pong-arcade-fpga)) requires external analog circuit to play.
This means that more knowledge, effort and money are required than playing with MiSTer. 

I thought it was best to port and publish it as a MiSTer core even there already existed an official core.

In addition, I was interested in learning to develop MiSTer core.
