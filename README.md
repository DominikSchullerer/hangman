# hangman
06.03.2023

Hangman has reached v1.0. In the main menu, you can either start a new game or load the last save.

Possible ToDos:

- Scorekeeping
- Reverse mode
- Tyding up the code
- Tyding up the output
- Help mode

Learned/Trained

- Encapsulation
- Basic file manipulation
- Serialization/Deserialization

The program structure is as usual:
- GM: Directs the program flow
- Board: Defines and displays the gamestate
- Player: Gets the player input
- Rules: Handles the game mechanics

Serialization is used for the save/load mechanism. Since the entire gamestate is defined by the instance variables of a Board object, only serialization of this object is needed.
