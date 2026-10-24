# LoL-Practice-AutoClicker

[中文用户？点击此处查看中文介绍。](README.zh_CN.md)

----
**THIS PROGRAM IS FREE TO USE! DON'T TRUST ANYBODY THAT ASK YOU TO PAY!**\
**DO NOT USE THIS AUTO-CLICKER DURING MATCHED GAMES (INCLUDING PVP AND PVE)! YOU DO SO AT YOUR OWN RISK OF GETTING BANNED!**

----
This repository stores an auto-clicker **specifically used in <ins>Practice Tool</ins> of League of Legends**, so that users may perform cheat commands frequently.
## GUI introduction
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
## Installation and execution
1. Visit [AutoHotKey official website](https://www.autohotkey.com/).
2. Click "Download".
3. Click "Download v2.0".
4. After the download finishes, open the downloaded file to install AutoHotKey.
    - It's highly recommended that you install it into C: volume.
5. Download the ahk file in this repository or in the release of this repository.
6. Double-click this file to run.
7. If a user account control (UAC) screen pops up, please select "Yes".
## Features
1. Repetitively press a key.
    1. Fixed cheat functions.
        - Functions that have a potential demand of frequent key press are filtered from all cheat functions in Practice Tool and collected into Area L2.
    2. Custom key combinations.
        - This allows users to customize a key combination to press repetitively. A key combination is composed of control keys and **a** single key.
        - When the user changes the default hotkey of those fixed functions, they can input the changed key combination in Area L3 and run it.
    3. Custom key combination sequence.
        - This benefits the test of [Arena GoH Evelynn Easter Egg BUG](https://youtu.be/XOpag8x34Hw).
            - For example, the user may **push** Ctrl + 1 and Ctrl + 3 into the key sequence stack to let the champion alternate between joking and dancing, thus creating a server instant when there might be multiple players changing from not dancing into dancing if possible.
2. (Beta) Keep holding a key.
    1. Hold a single key.
        - For example, the user may specify the single key to hold as "c". Then, click <ins>Hold</ins> button. After that, C key is kept holding in game, so that the advanced stat panel persists.
    2. Hold multiple single keys.
        - For example, the user may **push** c and z into the key sequence stack. Then, click <ins>Hold Sequence</ins> button. After that, C and Z keys are kept holding in game, so that the advanced stat panel and chat history persist.
    - **Warning: When the user presses keys too frequently, they may encounter a case where they can't do anything in League of Legends anymore starting from some time. If you encounter this case, please <ins>press Ctrl, Shift, Alt, space, Y or other keys that you think you've pressed</ins> to manually release them.**
        - This isn't a problem of this program, so there's no fix for now.
3. Adjust parameters.
    - Number of repeats.
    - Time interval between two successive key presses.
    - ~~Abort hotkey.~~
    - The single key to hold.
    - Time interval between two successive detections of whether single keys are held.
    - Single-key hold detection cooldown.
        - It means when the program detects some single keys are released, how much time the program should wait for detection to restart.
## Notes
1. The default font of this program is <ins>12, bold</ins>. Users may adjust the font size and boldness in settings. On the monitor with low resolution and high scale ratio (e.g. 1080P with 125% scale ratio), the GUI might not display completely. In that case, please lower the font size, e.g. from 12 to 10.
2. After "Progress always on top" settings option is unchecked, when the auto-clicker repetitively clicks some key, the progress window no longer pops up in the center of the screen. This is likely to impact switching between windows, so think twice before you uncheck this option.
3. There's no need, nor is it appropriate, for users to compile this script into an executable using Ahk2Exe.
