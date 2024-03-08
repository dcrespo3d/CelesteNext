# Celeste Classic for ZX Spectrum Next
Celeste Classic for ZX Spectrum Next (2024) is a port of Maddy Thorson and Noel Berry's Celeste Classic for Pico-8 fantasy console, released on 2015. I contacted Noel Berry and he kindly gave me permission for this remake.

This game runs on:
- Spectrum Next
- Windows/Linux/OSX (emulated with CSpect or ZesarUX)

For more info and downloads, see the [game page at itch.io](https://davidprograma.itch.io/celeste).

The game has been developed using:

- [Godot Engine](https://godotengine.org/) __(3.5.1)__ for prototyping.
- [Pico-8](https://www.lexaloffle.com/pico-8.php) fantasy console for analyzing the original game
- The [Z88DK C compiler](https://z88dk.org/site/).
- [Aseprite](https://www.aseprite.org/) for pixel art editing.
- [Arkos Tracker 2](https://www.julien-nevo.com/arkostracker/) for music/chiptunes.
- Custom [Python 3](https://www.python.org/) scripts for levels and art conversion.

## Disclaimer

This source code is provided as a reference to programmers wanting to learn about the ZX Spectrum Next platform, and to programmers interested in adapting Celeste Classic to other platforms with limitations. It may not compile in your machine, it may not fit your needs. It is provided "as-is" and I will not provide help/guidance. You're free to use this code as you want (well, at least while you honor the GPL3 license it is released under), but also, you're on your own.

## Compiling for ZX Spectrum Next

For compiling, you will need the z88dk compiler, I have used version z88dk-win32-20220704, a bit old but it works for me.

### WSL on Windows

First of all, install WSL1 and Ubuntu. WSL2 is sluggish on windows partitions (at least for me). Beware, WSL2 is the default on Windows 11.

Then, follow the steps for Linux / OSX.

### Linux / OSX

Install z88dk, this [Youtube Video by NCOT Technology](https://www.youtube.com/watch?v=R-JD8CQ5zTc) was all I needed.

Put your freshly compiled z88dk in `$HOME/z88dk` and the downloaded CSPect in `$HOME/z88dk/cspect`. You may need to launch CSpect using [mono](https://www.mono-project.com/), see below.

At this point, `make` and `m4` shoud be installed.

Then, just run `make` to compile the project and `make run` to compile and run in the emulator.

Next times you compile, make will do his work and compile only what's changed. But beware: header (.h) dependencies are not present, so if you change a header file, you will need to `make clean` before `make`.

I experienced a strange behaviour: with mono freshly installed, I could run CSpect.exe from command line and it ran seamlessly. But after a reboot, it stopped working and needed to launch it with `mono CSpect.exe`. So I have prepared a script, `CSpect.sh`, if that happens to you. Copy it to `cspect` dir, rename `CSpect.exe` to `CSpect.exe.bin`, and then, rename `CSpect.sh` to `CSpect.exe`.

## Epilog
This game has been programmed in 2 months, adapting original code, which is available from [here](https://www.lexaloffle.com/bbs/?pid=11722).

I made a full gameplay prototype in Godot in 5 days (all gameplay mechanics, but no sound or menus), then I began working on the ZXNext version.

The biggest challenge was to adapt the original floating-point player physics to fixed point (8.8). Also, having a 64kB address space is a bit of a challenge, needing to be careful with page switching.

I transcribed and adapted the original music and sound effects manually, using Arkos Tracker 2. The AY chip is more limited than the Pico-8 tracker, so I had to downgrade some details.

The game is an almost-perfect clone. To run at original Pico-8 speed, the Spectrum Next must be set up to run at 60Hz. Running at 50Hz makes the game slightly lower (and slightly easier). But the game is quite difficult. Before developing (and testing) this version, I needed about 40~45 min to finish it, after all the testing I have become quite proficient and my fastest run is about 4m30s.
