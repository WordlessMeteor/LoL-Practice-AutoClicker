This repository stores an auto-clicker **specifically used in <ins>Practice Tool</ins> of League of Legends**, so that users may perform cheat commands frequently.
# DECLARATION
> **THIS PROGRAM IS FREE TO USE! DON'T TRUST ANYBODY THAT ASK YOU TO PAY!**\
> **DO NOT USE THIS AUTO-CLICKER DURING MATCHED GAMES (INCLUDING PVP AND PVE)! YOU DO SO AT YOUR OWN RISK OF GETTING BANNED!**
# GUI introduction
- Menu bar
- L: Left part
    - L1: Title and Declaration
    - L2: Fixed functions
    - L3: Custom functions and Sequence loop
    - L4: Progress
- M: Middle part
    - M1: Key sequence stack
- R: Right part
    - R1: Parameter configuration
    - R2: Abort hotkey documentation
# Installation and execution
1. Visit [AutoHotKey official website](https://www.autohotkey.com/).
2. Click "Download".
3. Click "Download v2.0".
4. After the download finishes, open the downloaded file to install AutoHotKey.
    - It's highly recommended that you install it into C: volume.
5. Download the ahk file in this repository or in the release of this repository.
6. Double-click this file to run.
7. If a user account control (UAC) screen pops up, please select "Yes".
# Features
This program supports repetitively pressing the following three kinds of keys:
1. Fixed cheat functions.
    - Functions that have a potential demand of frequent key press are filtered from all cheat functions in Practice Tool and collected into Area L2.
2. Custom key combinations.
    - This allows users to customize a key combination to press repetitively. A key combination is composed of control keys and **a** single key.
    - When the user changes the default hotkey of those fixed functions, they can input the changed key combination in Area L3 and run it.
3. Custom key combination sequence.
    - This benefits the test of [Arena GoH Evelynn Easter Egg BUG](https://youtu.be/1oOkwDWpl7Y).
        - For example, the user may **push** Ctrl + 1 and Ctrl + 3 into the key sequence stack repetitively to let the champion alternate between joking and dancing, thus creating a server instant when there might be multiple players changing from not dancing into dancing if possible.
# Notes
1. The default font of this program is <ins>12, bold</ins>. Users may adjust the font size and boldness in settings. On the monitor with low resolution and high scale ratio (e.g. 1080P with 125% scale ratio), the GUI might not display completely. In that case, please lower the font size, e.g. from 12 to 10.
2. After "Progress always on top" settings option is unchecked, when the auto-clicker repetitively clicks some key, the progress window no longer pops up in the center of the screen. This is likely to impact switching between windows, so think twice before you uncheck this option.
3. There's no need, nor is it appropriate, for users to compile this script into an executable using Ahk2Exe.
