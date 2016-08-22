# guiloku

## Introduction

This is a very very bad amalgamation of the names 'Guile' and 'Gomoku' but I'm sticking with it.
The idea is to build a gomoku-like game in guile in the process of learning to use guile

### Gomoku

Gomoku is a strategy board game originating from Japan, where it is referred to as _gomokunarabe_.

You can read more on [Wikipedia](https://en.wikipedia.org/wiki/Gomoku)

## Guiloku

Guiloku is an implementation of Gomoku in [Guile](https://www.gnu.org/software/guile/)

## Dependencies

Guiloku depends on:

* [Guile][guile]
* [Sly][sly]

## Installing and Running

1. Install [GNU Guix](https://www.gnu.org/software/guix/) - I recommend the binary installation
2. Clone [Sly][sly] `git clone git://dthompson.us/sly.git`
3. Change directory into sly: `cd /path/to/sly`
4. Build and install [Sly][sly]
	* Set up build environment: `guix environment -l guix.scm`
	* bootstrap build environment and configure: `./bootstrap && ./configure`
	* Build sly: `guix build -f guix.scm`
	* Install sly: `guix install -f guix.scm`
5. Clone guiloku: `git clone git@github.com:fredmanglis/guiloku.git`
6. Change directory into guiloku: `cd /path/to/guiloku/`
7. Run guiloku `guile -s guiloku.scm`

## Screenshots

**Note**: _Annotations in red do not appear in actual screens_

On launch:

![Initial screen on launching guiloku](docs/screenshots/launch_screen.png)

2 moves in:

![Stones for players 1 and 2 shown](docs/screenshots/players_stones.png)

And a win whenever there are 5 consecutive stones:

![Player 2 wins](docs/screenshots/player2_wins.png)

## Direction

The intention is to implement a simple game of Gomoku, for fun and also to learn both [GNU Guile][guile] and [Sly][sly]

It is also meant to teach me how to use the [GNU Guix][guix] package manager

I intend to add/implement some of the following features and fixes:

- [x] Make the game playable manually
- [ ] Figure out the entire flow of signals and how they are updated
- [ ] Fix failure caused by pressing 'n' to start new game
- [ ] Implement automatic game completion when a player gets 5 consecutive stones
- [ ] Implement updates to status messages
- [ ] Add theming (background and go-stones)


[guile]:https://www.gnu.org/software/guile/
[sly]:https://dthompson.us/projects/sly.html