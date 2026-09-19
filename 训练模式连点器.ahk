#Requires AutoHotkey v2.0

; 以管理员身份运行（Run As Administrator）
if (!A_IsAdmin) {
    try {
        Run '*RunAs "' A_ScriptFullPath '"'
        ExitApp
    } catch Error as e {
        MsgBox "脚本尝试以管理员权限重启失败。`n在游戏内可能无法正常工作。"
    }
}

MsgBox "本脚本依赖于AutoHotKey v2.0，请确保您已安装该应用程序。请确保您是通过以管理员身份运行ahk脚本而不是该脚本编译出来的exe文件来执行此程序，以防杀毒软件误隔离。`nThis program relies on AutoHotKey v2.0. Please make sure you've installed this application. Please make sure you Run the `"ahk`" script instead of the compiled `"exe`" file As Adminstrator, in case the `"exe`" file would be quarantined by any anti-virus software.`n按下Windows+Z以打开AutoHotKey官网。按下Windows+Shift+Z打开AutoHotKey v2官方文档。`nPress Windows + Z to open AutoHotKey official website. Press Windows + Shift + Z to open AutoHotKey v2 official documentation.`n`n警告：更换字体和粗体选项将重置窗口所有状态！在执行此操作前，请注意保存数据。`nWarning: Changing the font size or boldness will reset all status in the window. Before you do this, please remember to save data."

#z::Run("https://www.autohotkey.com") ; Windows+Z本来是调出窗口调节选项的，但其实鼠标悬停在最大化/还原按钮上面就可以调出这个选项（Windows + Z is originally meant to pull out the window adjustment options, but actually one can call it out by simplify moving the mouse cursor to the maximize / restore button）
#+z::Run("https://www.autohotkey.com/docs/v2/") ; Windows+Shift+Z打开AutoHotKey v2官方文档（Windows + Shift + Z to open AutoHotKey v2 official documentation）


; 初始化全局变量（Initialize global variables）
maxLoops := 1980 ; 重复次数（Repetition times）
interval := 0 ; 命令执行间隔（Command execution interval）
stopKey := "#s" ; 停止热键（Stop hotkey）
Hotkey(stopKey, StopAction, "On")
keySeq := [] ; 按键序列。每个元素是一个数组；每个数组的第一个元素是按键代码，第二个元素是按键的字符串表示（Key sequence. Each element is an array; the first element of each array is key code, and the second element is the string representation of the key to press）
IsRunning := false ; 标记是否在执行某个功能（Mark whether a function is being performed）
StopRequested := false ; 标记用户是否请求中止（Mark whether the user has requested to abort）
BasicAttackNeeded_Actions := Map() ; 用于普通攻击型功能的输出提示（Used for output hint of basic attack based cheats）
BasicAttackNeeded_Actions["incunit100health"] := true
BasicAttackNeeded_Actions["decunit100health"] := true
BasicAttackNeeded_Actions["incunit10resistance"] := true
BasicAttackNeeded_Actions["decunit10resistance"] := true
IsBold := true ; 是否使用粗体字（Whether to use bold characters）
ProgressMonitorAlwaysOnTop := false ; 进度小窗口是否置顶（Whether the progress monitor is always on top）

; 准备一些测量函数（Prepare some measure functions）
/**
 * 通过构建临时控件，测量一类控件的高度。<br>Mesure the heigth of a type of controls by creating a temporary control.
 * @param {String} fontOptions 字体选项，包括字号、粗体、斜体等。<br>Font options, including font size, boldness, italicize, etc.
 * @param {String} fontName 字体内置名。<br>Font internal name.
 * @param {Array} ctrlOptions 创建控件时的选项。分别`Gui.Add`方法的三个参数。<br>Options when a control is being created. Act as three parameters of `Gui.Add` method, respectively.
 * - 控件类型。<br>Control type.
 * - 图形化界面参数。<br>GUI parameters.
 * - 文本或其它参数。<br>Text or another parameter.
 * @returns {Integer} 控件高度。<br>Height of the control.
 */
MeasureHeight(fontOptions, fontName, ctrlOptions) {
    tmpGui := Gui()
    tmpGui.SetFont(fontOptions, fontName)
    tmpCtrl := tmpGui.Add(ctrlOptions[1], ctrlOptions[2], ctrlOptions[3])
    tmpCtrl.GetPos(&X, &Y, &W, &H)
    tmpGui.Destroy()
    return H
}
/**
 * 通过构建临时控件，测量一类控件的宽度。<br>Mesure the width of a type of controls by creating a temporary control.
 * @param {String} fontOptions 字体选项，包括字号、粗体、斜体等。<br>Font options, including font size, boldness, italicize, etc.
 * @param {String} fontName 字体内置名。<br>Font internal name.
 * @param {Array} ctrlOptions 创建控件时的选项。分别`Gui.Add`方法的三个参数。<br>Options when a control is being created. Act as three parameters of `Gui.Add` method, respectively.
 * - 控件类型。<br>Control type.
 * - 图形化界面参数。<br>GUI parameters.
 * - 文本或其它参数。<br>Text or another parameter.
 * @returns {Integer} 控件高度。<br>Height of the control.
 */
MeasureWidth(fontOptions, fontName, ctrlOptions) {
    tmpGui := Gui()
    tmpGui.SetFont(fontOptions, fontName)
    tmpCtrl := tmpGui.Add(ctrlOptions[1], ctrlOptions[2], ctrlOptions[3])
    tmpCtrl.GetPos(&X, &Y, &W, &H)
    tmpGui.Destroy()
    return W
}
/**
 * 通过构建临时控件，测量控件的横纵间距。<br>Measure the horizontal and vertical padding between controls by creating a temporary control.
 * @param {String} fontOptions 字体选项，包括字号、粗体、斜体等。<br>Font options, including font size, boldness, italicize, etc.
 * @param {String} fontName 字体内置名。<br>Font internal name.
 */
MeasurePadding(fontOptions, fontName) {
    global PadX, PadY
    tmpGui := Gui()
    tmpGui.SetFont(fontOptions, fontName)
    tmpCtrl := tmpGui.Add("Button", "", "")
    tmpCtrl.GetPos(&PadX, &PadY, &W, &H)
    tmpGui.Destroy()
}
/**
 * 测量各类控件的高度。<br>Measure the height of all kinds of controls.
 * @param {String} fontOptions 字体选项，包括字号、粗体、斜体等。<br>Font options, including font size, boldness, italicize, etc.
 * @param {String} fontName 字体内置名。<br>Font internal name.
 */
MeasureAllHeight(fontOptions, fontName) {
    global H_TEXT_1L, H_TEXT_2L, H_TEXT_3L, H_TEXT_15L, H_HSEPARATOR, H_BUTTON_1L, H_BUTTON_2L, H_CHECKBOX_1L, H_EDIT_1L, H_PROGRESS, H_LISTVIEW
    H_TEXT_1L := MeasureHeight(fontOptions, fontName, ["Text", "", ""]) ; 含有一行文本的文本框高度（Height of a text box with 1 line of text）
    H_TEXT_2L := MeasureHeight(fontOptions, fontName, ["Text", "", "`n"]) ; 含有两行文本的文本框高度（Height of a text box with 2 lines of text）
    H_TEXT_3L := MeasureHeight(fontOptions, fontName, ["Text", "", "`n`n"]) ; 含有三行文本的文本框高度（Height of a text box with 3 lines of text）
    H_TEXT_15L := MeasureHeight(fontOptions, fontName, ["Text", "", StrReplace(Format("{1:+014}", 0), "0", "`n")]) ; 含有15行文本的文本框高度（Height of a text box with 15 lines of text）
    H_HSEPARATOR := MeasureHeight(fontOptions, fontName, ["Text", "0x10", ""]) ; 水平分隔符高度（Height of a horizontal separator）
    H_BUTTON_1L := MeasureHeight(fontOptions, fontName, ["Button", "", ""]) ; 含有一行文本的按钮高度（Height of a button with 1 line of text）
    H_BUTTON_2L := MeasureHeight(fontOptions, fontName, ["Button", "", "`n"]) ; 含有两行文本的按钮高度（Height of a button with 2 lines of text）
    H_CHECKBOX_1L := MeasureHeight(fontOptions, fontName, ["Checkbox", "", ""]) ; 含有一行文本的勾选框高度（Height of a checkbox with 1 line of text）
    H_EDIT_1L := MeasureHeight(fontOptions, fontName, ["Edit", "", ""]) ; 可容纳一行文本的编辑框高度（Height of an edit box that can hold 1 line of text）
    H_PROGRESS := MeasureHeight(fontOptions, fontName, ["Progress", "", 0]) ; 进度条的高度（Height of a progress bar）
    H_LISTVIEW := MeasureHeight(fontOptions, fontName, ["ListView", "r26", ["", ""]]) ; 可容纳30条记录的列表的高度（Height of a list that can hold 30 records）
}
/**
 * 测量各类控件的宽度。<br>Measure the width of all kinds of controls.
 * @param {String} fontOptions 字体选项，包括字号、粗体、斜体等。<br>Font options, including font size, boldness, italicize, etc.
 * @param {String} fontName 字体内置名。<br>Font internal name.
 */
MeasureAllWidth(fontOptions, fontName) {
    global W_VSEPARATOR
    W_VSEPARATOR := MeasureWidth(fontOptions, fontName, ["Text", "0x11", ""])
}

; 下面设置图形化界面的缩放相关常量和参数。这部分思路由DeepSeek V4.1 Flash模型提供（Set GUI scale related constants and parameters. This part is provided by DeepSeek V4.1 Flash model）
;; 定义用于布局的逻辑单位（Define logic units used for layout）
BASE_FONT_SIZE := 12 ; 基础字号（Base font size）
FONT_NAME := "Microsoft YaHei" ; 字体（Font）
CURRENT_FONT_SIZE := 12 ; 当前字号（Current font size）
SCALE := CURRENT_FONT_SIZE / BASE_FONT_SIZE ; 缩放比例（Scale ratio）
FONT_OPTIONS := "s12 bold" ; 字体选项（Font options）
;; 获取控件的横纵间距（Get the horizontal and vertical gaps between controls）
MeasurePadding("s12 bold", FONT_NAME)
;; 获取不同控件的逻辑高度（Get the height of different controls）
MeasureAllHeight("s12 bold", FONT_NAME)
;; 获取不同控件的逻辑宽度（Get the width of different controls）
MeasureAllWidth("s12 bold", FONT_NAME)
;; 定义单位函数（Define unit functions）
/**
 * 计算缩放后的像素数。<br>Calculate scaled pixels.
 * @param {Integer} n 默认字号下的像素数。<br>Number of pixels under the default font size.
 * @returns {Float} 缩放后的像素数。<br>Number of pixels after scaling.
 */
U(n) {
    return SCALE * n
}
;; 定义字符串常量池（Define stringtable）
Stringtable := {
    Title: "训练模式连点器 | Practice AutoClicker",
    Left: {
        Declaration: {
            Text1: "《英雄联盟》训练模式按键辅助工具`nLeague of Legends Practice Tool Key Press Assistant",
            Text2: "请在训练模式中使用，违者后果自负。`nPlease run this program in Practice Tool.`nViolators shall bear the result by themselves."
        },
        Button: {
            AddGold: "增加金钱`nAdd Gold",
            LevelUp: "升级`nLevel Up",
            AddHP: "添加100最大生命值`nAdd 100 Max HP",
            DecHP: "移除100最大生命值`nRemove 100 Max HP",
            AddResist: "添加10双抗`nAdd 10 Resistances",
            DecResist: "移除10双抗`nRemove 10 Resistances"
        },
        Custom: {
            Title: "自定义`nCustom",
            Checkbox1: "Ctrl",
            Checkbox2: "Shift",
            Checkbox3: "Alt",
            Prompt: "请输入单键：`nPlease input a single key:",
            RunButton: "执行/Run",
            SequenceLoop: "序列循环`nSequence Loop",
            PushButton: "入栈/Push",
            PopButton: "出栈/Pop",
            ClearButton: "清空/Clear",
            RunSequenceButton: "运行序列`nRun Sequence"
        },
        Status: {
            StopButton: "强制停止`nForce to stop",
            Text: "就绪——等待开始……`nReady - Awaiting to start ...",
            ExitButton: "退出/Quit"
        }
    },
    Middle: {
        Title: "按键序列`nKey Sequence",
        Column1: "行号|Index",
        Column2: "按键|Key"
    },
    Right: {
        Config: {
            Title: "参数设置`nParameter Configuration",
            RepetitionPrompt: "重复次数/Repetition：",
            IntervalPrompt: "间隔/Interval：",
            AbortHotkeyPrompt: "中止热键/Abort Hotkey：",
            UpdateButton: "更新/Update",
            MeleeResetButton: "近战复位`nMelee Reset",
            RangedResetButton: "远程复位`nRanged Reset",
            ResetButton: "复位/Reset",
            ResetAllButton: "复位全部变量`nReset all parameters"
        },
        HelpDoc: "组合键格式（Key combination rule）：`n#`tWindows`n!`tAlt`n^`tCtrl`n+`tShift`n<`t左控制键（Left control）`n>`t右控制键（Right control）`n示例（Examples）：`n#s`tWindows + S`n<^t`tLCtrl + t`n游戏内仅Windows+单键可用。`nOnly Windows plus a single key works in game.`n更多热键字符串请参考AutoHotKey官方文档。`nFor more hotkey strings, please refer to AutoHotKey official documentation.`n#+z: https://www.autohotkey.com/docs/v2/"
    }
}
;; 定义配置层（Define config layer）
Config_default := {
    ; 区域划分（Area division）
    Regions: {
        Left:   {Width: 500, Height: 900},
        Middle: {Width: 300, Height: 900},
        Right:  {Width: 750, Height: 900},
    },
    
    ; 每个区域内的控件规格（Control speculation in each area）
    Left_Controls: {
        ;                    类型           横坐标   纵坐标                                                                                                           宽度                高度                选项                     文本
        ;                    Type           X       Y                                                                                                               Width               Height              Options                 Text
        Title:              ["Text",        0,      PadY,                                                                                                           500,                H_TEXT_2L,          "Center",               Stringtable.Left.Declaration.Text1],
        Declaration:        ["Text",        0,      PadY * 2 + H_TEXT_2L,                                                                                           500,                H_TEXT_3L,          "Center",               Stringtable.Left.Declaration.Text2],
        Separator1:         ["Text",        0,      PadY * 3 + H_TEXT_2L + H_TEXT_3L,                                                                               500,                H_HSEPARATOR,       "0x10",                 ""],
        AddGoldButton:      ["Button",      25,     PadY * 4 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR,                                                                200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.AddGold],
        LevelUpButton:      ["Button",      275,    PadY * 4 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR,                                                                200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.LevelUp],
        AddHPButton:        ["Button",      25,     PadY * 5 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR + H_BUTTON_2L,                                                  200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.AddHP],
        DecHPButton:        ["Button",      275,    PadY * 5 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR + H_BUTTON_2L,                                                  200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.DecHP],
        AddResistButton:    ["Button",      25,     PadY * 6 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR + H_BUTTON_2L * 2,                                              200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.AddResist],
        DecResistButton:    ["Button",      275,    PadY * 6 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR + H_BUTTON_2L * 2,                                              200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Button.DecResist],
        Separator2:         ["Text",        0,      PadY * 7 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR + H_BUTTON_2L * 3,                                              500,                H_HSEPARATOR,       "0x10",                 ""],
        CustomTitle:        ["Text",        0,      PadY * 8 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + 20,                                     100,                H_TEXT_2L,          "Center",               Stringtable.Left.Custom.Title],
        Checkbox1:          ["Checkbox",    100,    PadY * 8 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3,                                          60,                 H_CHECKBOX_1L,      "",                     Stringtable.Left.Custom.Checkbox1],
        Checkbox2:          ["Checkbox",    100,    PadY * 9 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L,                          60,                 H_CHECKBOX_1L,      "",                     Stringtable.Left.Custom.Checkbox2],
        Checkbox3:          ["Checkbox",    100,    PadY * 10 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 2,                     60,                 H_CHECKBOX_1L,      "",                     Stringtable.Left.Custom.Checkbox3],
        CustomPrompt:       ["Text",        170,    PadY * 8 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3,                                          220,                H_TEXT_2L,          "",                     Stringtable.Left.Custom.Prompt],
        SingleKeyEdit:      ["Edit",        170,    PadY * 9 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3,                                      220,                H_EDIT_1L,          "",                     ""],
        SingleKeyRunButton: ["Button",      400,    PadY * 9 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3,                                      100,                H_BUTTON_1L,        "",                     Stringtable.Left.Custom.RunButton],
        SequenceLoopTitle:  ["Text",        0,      PadY * 11 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 3,                     160,                H_TEXT_2L,          "Center",               Stringtable.Left.Custom.SequenceLoop],
        PushButton:         ["Button",      170,    PadY * 11 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 3,                     100,                H_BUTTON_1L,        "Center",               Stringtable.Left.Custom.PushButton],
        PopButton:          ["Button",      280,    PadY * 11 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 3,                     100,                H_BUTTON_1L,        "Center",               Stringtable.Left.Custom.PopButton],
        ClearButton:        ["Button",      390,    PadY * 11 + H_TEXT_2L + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 3,                     100,                H_BUTTON_1L,        "Center",               Stringtable.Left.Custom.ClearButton],
        RunSequenceButton:  ["Button",      150,    PadY * 12 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 3 + H_CHECKBOX_1L * 3,                 200,                H_BUTTON_2L,        "Center",               Stringtable.Left.Custom.RunSequenceButton],
        Separator3:         ["Text",        0,      PadY * 13 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 2 + H_BUTTON_2L * 4 + H_CHECKBOX_1L * 3,                 500,                H_HSEPARATOR,       "0x10",                 ""],
        StopButton:         ["Button",      175,    PadY * 14 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 3 + H_BUTTON_2L * 4 + H_CHECKBOX_1L * 3,                 150,                H_BUTTON_2L,        "Center Disabled",      Stringtable.Left.Status.StopButton],
        StatusText:         ["Text",        0,      PadY * 15 + H_TEXT_2L * 2 + H_TEXT_3L + H_HSEPARATOR * 3 + H_BUTTON_2L * 5 + H_CHECKBOX_1L * 3,                 500,                H_TEXT_2L,          "Center",               Stringtable.Left.Status.Text],
        ProgressBar:        ["Progress",    25,     PadY * 16 + H_TEXT_2L * 3 + H_TEXT_3L + H_HSEPARATOR * 3 + H_BUTTON_2L * 5 + H_CHECKBOX_1L * 3,                 450,                H_PROGRESS,         "Range0-100 -Smooth",   ""],
        ExitButton:         ["Button",      190,    PadY * 17 + H_TEXT_2L * 3 + H_TEXT_3L + H_HSEPARATOR * 3 + H_BUTTON_2L * 5 + H_CHECKBOX_1L * 3 + H_PROGRESS,    120,                H_BUTTON_1L,        "Center",               Stringtable.Left.Status.ExitButton],
    },
    VSeparator1:            ["Text",        0,      PadY,                                                                                                           W_VSEPARATOR,       800,                "0x11",                 ""],
    Middle_Controls: {
        ;        类型           横坐标   纵坐标                   宽度                高度         选项        文本
        ;        Type           X       Y                       Width               Height      Options     Text
        Title:  ["Text",        0,      PadY,                   300,                H_TEXT_2L,  "Center",   Stringtable.Middle.Title],
        List:   ["ListView",    0,      PadY * 2 + H_TEXT_2L,   300,                H_LISTVIEW, "Center",   [Stringtable.Middle.Column1, Stringtable.Middle.Column2]]
    },
    VSeparator2: ["Text",       0,      PadY,                   W_VSEPARATOR,       800,        "0x11",                 ""],
    Right_Controls: {
        ;                                类型           横坐标   纵坐标                                                                               宽度                高度            选项         文本
        ;                                Type           X       Y                                                                                   Width               Height          Options     Text
        Title:                          ["Text",        0,      PadY,                                                                               750,                H_TEXT_2L,      "Center",   Stringtable.Right.Config.Title],
        RepetitionLabel:                ["Text",        0,      PadY * 2 + H_TEXT_2L + 5,                                                           200,                H_TEXT_1L,      "",         Stringtable.Right.Config.RepetitionPrompt],
        RepetitionEdit:                 ["Edit",        200,    PadY * 2 + H_TEXT_2L,                                                               80,                 H_EDIT_1L,      "Number",   maxLoops], ; Number属性限制数字输入（"Number" restricts the input type）
        UpdateRepetitionButton:         ["Button",      290,    PadY * 2 + H_TEXT_2L,                                                               120,                H_BUTTON_1L,    "Center",   Stringtable.Right.Config.UpdateButton],
        RepetitionValue:                ["Text",        420,    PadY * 2 + H_TEXT_2L + 5,                                                           90,                 H_TEXT_1L,      "",         ""],
        MeleeResetRepetitionButton:     ["Button",      510,    PadY * 2 + H_TEXT_2L - 10,                                                          120,                H_BUTTON_2L,    "Center",   Stringtable.Right.Config.MeleeResetButton],
        RangedResetRepetitionButton:    ["Button",      640,    PadY * 2 + H_TEXT_2L - 10,                                                          120,                H_BUTTON_2L,    "Center",   Stringtable.Right.Config.RangedResetButton],
        IntervalLabel:                  ["Text",        0,      PadY * 3 + H_TEXT_2L + H_BUTTON_2L + 5,                                             200,                H_TEXT_1L,      "",         Stringtable.Right.Config.IntervalPrompt],
        IntervalEdit:                   ["Edit",        200,    PadY * 3 + H_TEXT_2L + H_BUTTON_2L,                                                 80,                 H_EDIT_1L,      "Number",   interval],
        UpdateIntervalButton:           ["Button",      290,    PadY * 3 + H_TEXT_2L + H_BUTTON_2L,                                                 120,                H_BUTTON_1L,    "Center",   Stringtable.Right.Config.UpdateButton],
        IntervalValue:                  ["Text",        420,    PadY * 3 + H_TEXT_2L + H_BUTTON_2L + 5,                                             90,                 H_TEXT_1L,      "",         ""],
        ResetIntervalButton:            ["Button",      510,    PadY * 3 + H_TEXT_2L + H_BUTTON_2L,                                                 120,                H_BUTTON_1L,    "Center",   Stringtable.Right.Config.ResetButton],
        AbortHotkeyLabel:               ["Text",        0,      PadY * 4 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L + 5,                               200,                H_TEXT_1L,      "",         Stringtable.Right.Config.AbortHotkeyPrompt],
        AbortHotkeyEdit:                ["Edit",        200,    PadY * 4 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L,                                   80,                 H_EDIT_1L,      "",         stopKey],
        UpdateAbortHotkeyButton:        ["Button",      290,    PadY * 4 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L,                                   120,                H_BUTTON_1L,    "Center",   Stringtable.Right.Config.UpdateButton],
        AbortHotkeyValue:               ["Text",        420,    PadY * 4 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L + 5,                               90,                 H_TEXT_1L,      "",         ""],
        ResetAbortHotkeyButton:         ["Button",      510,    PadY * 4 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L,                                   120,                H_BUTTON_1L,    "Center",   Stringtable.Right.Config.ResetButton],
        ResetAllParameterButton:        ["Button",      285,    PadY * 5 + H_TEXT_2L + H_BUTTON_2L + H_BUTTON_1L * 2,                               180,                H_BUTTON_2L,    "Center",   Stringtable.Right.Config.ResetAllButton],
        Separator:                      ["Text",        0,      PadY * 6 + H_TEXT_2L + H_BUTTON_2L * 2 + H_BUTTON_1L * 2,                           750,                H_HSEPARATOR,   "0x10",     ""],
        AbortHotkeyHelpDoc:             ["Text",        0,      PadY * 7 + H_TEXT_2L + H_BUTTON_2L * 2 + H_BUTTON_1L * 2 + H_HSEPARATOR,            750,                H_TEXT_15L,     "",         Stringtable.Right.HelpDoc],
    }
}
;; 控件添加层（Control addition layer）
/**
 * 添加控件。<br>Add a control.
 * @param {Gui} guiObj 一个图形化用户界面对象。<br>A `Gui` object.
 * @param {Integer} region 区域代号。有以下取值：<br>Region id, which has the following values:
 * - 1: 左侧。<br>Left part.
 * - 2: 左侧和中间的垂直分隔线。<br>The vertical separator between the left and middle parts.
 * - 3: 中间。<br>Middle part.
 * - 4: 中间和右侧的垂直分隔线。<br>The vertical separator between the middle and right parts.
 * - 5: 右侧。<br>Right part.
 * - 6: 右侧以右的部分。如果有任何拓展的话。<br>The right to the right part, if there's any extension.
 * 
 * 其它取值会引发值错误。<br>Other values will trigger a ValueError.
 * @param {array} config 控件配置。由以下部分组成：<br>Control config. Composed of the following parts:
 * - （字符串）控件类型。<br>(String) Control type.
 * - （整数）横坐标。<br>(Integer) Horizontal coordinate.
 * - （整数）纵坐标。<br>(Integer) Vertical coordinate.
 * - （整数）宽度。<br>(Integer) Width.
 * - （整数）高度。<br>(Integer) Height.
 * - （字符串）其它控件选项。<br>(String) Other control options.
 * - （字符串）控件的初始显示文本。<br>(String) The initial display text of the control.
 * @returns {Gui.Control} 控件对象。<br>The control object.
 */
AddCtrl(guiObj, region, config) {
    ControlType := config[1]
    x := config[2]
    y := config[3]
    w := config[4]
    h := config[5]
    extraOption := config[6]
    text := config[7]
    if region == 1
        XOffset := PadX
    else if region == 2
        XOffset := PadX * 2 + Config_default.Regions.Left.Width
    else if region == 3
        XOffset := PadX * 3 + Config_default.Regions.Left.Width
    else if region == 4
        XOffset := PadX * 4 + Config_default.Regions.Left.Width + Config_default.Regions.Middle.Width
    else if region == 5
        XOffset := PadX * 5 + Config_default.Regions.Left.Width + Config_default.Regions.Middle.Width
    else if region == 6
        XOffset := PadX * 6 + Config_default.Regions.Left.Width + Config_default.Regions.Middle.Width + Config_default.Regions.Right.Width
    else
        throw ValueError("Parameter #2 invalid", -1, region)
    Options := "w" U(w) " h" U(h) " x" U(XOffset + x) " y" U(y) " " extraOption
    ctrl := guiObj.Add(ControlType, Options, text)
    return ctrl
}

; 菜单栏的动作（Actions in menu bar）
/**
 * 设置图形化界面的字号。<br>Set the font size of the GUI.
 * 
 * 警告：此操作将重置页面所有状态。<br>Warning: This operation resets all status in the interface.
 * @param {Integer} n 字号。<br>Font size.
 */
SetFontSize(n, *) {
    global CURRENT_FONT_SIZE, FONT_OPTIONS, SCALE
    CURRENT_FONT_SIZE := n
    SCALE := CURRENT_FONT_SIZE / BASE_FONT_SIZE
    FONT_OPTIONS := "s" n (IsBold ? " bold" : "")
    ; 由于生成控件时在控件添加函数内会调用单位函数，因此这里不需要直接在三个测量函数中传入修改后的字体选项，而是使用默认字体选项即可（When controls are generated, `AddCtrl` function calls `U` function, so here the modified `FONT_OPTIONS` don't need to be passed into those three measure functions. Use the default font options instead）
    MeasurePadding("s12 bold", FONT_NAME)
    MeasureAllHeight("s12 bold", FONT_NAME)
    MeasureAllWidth("s12 bold", FONT_NAME)
    RebuildUI() ; 重新构建界面（Rebuild the GUI）
}

/**
 * 切换粗体。<br>Toggle boldness.
 * 
 * 警告：此操作将重置页面所有状态。<br>Warning: This operation resets all status in the interface.
 */
ToggleBold(*) {
    global IsBold
    IsBold := !IsBold
    SetFontSize(CURRENT_FONT_SIZE)
}

/**
 * 切换进度小窗口置顶状态。<br>Toggle the progress monitor window to become always on top or not.
 */
ToggleProgressMonitorAlwaysOnTop(*) {
    global ProgressMonitorAlwaysOnTop
    ProgressMonitorAlwaysOnTop := !ProgressMonitorAlwaysOnTop
    if ProgressMonitorAlwaysOnTop
        SettingsMenu.Check("执行进度置顶 | Progress always on top")
    else
        SettingsMenu.Uncheck("执行进度置顶 | Progress always on top")
}

/**
 * 显示关于对话框。<br>Show about dialog box.
 */
ShowAbout(*) {
    MsgBox("训练模式连点器（Practice Tool Auto Clicker） v2`n作者（Author）：WordlessMeteor`n上次更新时间（Latest update）：2026-09-18", "关于 | About", 0x40)
}

/**
 * 重新构建界面。<br>Re-create the user interface.
 */
RebuildUI() {
    global MyGui
    if IsSet(MyGui) && MyGui.Hwnd
        MyGui.Destroy()
    CreateMainGui()
    MyGui.Show()
}

; 构建图形化界面（Create the Graphical User Interface）
/**
 * 构建主界面。<br>Create the main GUI.
 */
CreateMainGui() {
    global MyGui, SettingsMenu, ActionConfigs, StopButton, StatusText, ProgressBar, KeyEdit, CheckBox1, CheckBox2, CheckBox3, LoopEdit, RepeatNumber_text, IntervalEdit, Interval_text, StopKeyEdit, StopKey_text, SequenceList
    ; 下面设置图形化界面（Set the graphical user interface）    
    MyGui := Gui() ; 初始化图形化界面（Initialize Graphical User Interface）
    ;; 标题（Title）
    MyGui.SetFont(FONT_OPTIONS, FONT_NAME)
    MyGui.Title := Stringtable.Title
    ;; 菜单栏（Menu bar）
    MyMenu := MenuBar()
    SettingsMenu := Menu()
    FontSizeMenu := Menu()
    Loop 15 {
        FontSizeMenu.Add(A_Index, SetFontSize.Bind(A_Index))
        if A_Index == CURRENT_FONT_SIZE
            FontSizeMenu.Check(A_Index)
    }
    SettingsMenu.Add("字号 | Font size", FontSizeMenu)
    SettingsMenu.Add("加粗 | Bold", ToggleBold)
    if IsBold
        SettingsMenu.Check("加粗 | Bold")
    SettingsMenu.Add("执行进度置顶 | Progress always on top", ToggleProgressMonitorAlwaysOnTop)
    ToggleProgressMonitorAlwaysOnTop()
    MyMenu.Add("设置 | Settings", SettingsMenu)
    MyMenu.Add("关于 | About", ShowAbout)
    MyGui.MenuBar := MyMenu
    ;; 左侧——按键部分（Left part - key press part）
    ;;; 声明（Declaration）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.Title)
    AddCtrl(MyGui, 1, Config_default.Left_Controls.Declaration)
    ;;; 左侧第一分隔线（First separator of the left part）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.Separator1) ; 添加水平分隔线（Add horizontal separator）
    ;;; 动作按钮（Action buttons）
    ActionButton_incgold := AddCtrl(MyGui, 1, Config_default.Left_Controls.AddGoldButton)
    ActionButton_inclevel := AddCtrl(MyGui, 1, Config_default.Left_Controls.LevelUpButton)
    ActionButton_incunit100health := AddCtrl(MyGui, 1, Config_default.Left_Controls.AddHPButton)
    ActionButton_decunit100health := AddCtrl(MyGui, 1, Config_default.Left_Controls.DecHPButton)
    ActionButton_incunit10resistance := AddCtrl(MyGui, 1, Config_default.Left_Controls.AddResistButton)
    ActionButton_decunit10resistance := AddCtrl(MyGui, 1, Config_default.Left_Controls.DecResistButton)
    ;;; 左侧第二分隔线（Second separator of the left part）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.Separator2)
    ;;; 自定义控制按钮（Custom control buttons）
    ;;;; 自定义（Custom）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.CustomTitle)
    CheckBox1 := AddCtrl(MyGui, 1, Config_default.Left_Controls.Checkbox1)
    CheckBox2 := AddCtrl(MyGui, 1, Config_default.Left_Controls.Checkbox2)
    CheckBox3 := AddCtrl(MyGui, 1, Config_default.Left_Controls.Checkbox3)
    AddCtrl(MyGui, 1, Config_default.Left_Controls.CustomPrompt)
    KeyEdit := AddCtrl(MyGui, 1, Config_default.Left_Controls.SingleKeyEdit)
    ActionButton_custom := AddCtrl(MyGui, 1, Config_default.Left_Controls.SingleKeyRunButton)
    ;;;; 序列循环（Sequence loop）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.SequenceLoopTitle)
    PushButton_custom := AddCtrl(MyGui, 1, Config_default.Left_Controls.PushButton)
    PopButton_custom := AddCtrl(MyGui, 1, Config_default.Left_Controls.PopButton)
    ClearButton_custom := AddCtrl(MyGui, 1, Config_default.Left_Controls.ClearButton)
    RunSequenceButton := AddCtrl(MyGui, 1, Config_default.Left_Controls.RunSequenceButton)
    ;;; 左侧第三分隔线（Third separator of the left part）
    AddCtrl(MyGui, 1, Config_default.Left_Controls.Separator3)
    ;;; 状态栏（Status section）
    StopButton := AddCtrl(MyGui, 1, Config_default.Left_Controls.StopButton)
    ;;;; 状态视觉元素（Status visual elements）
    StatusText := AddCtrl(MyGui, 1, Config_default.Left_Controls.StatusText) ; 添加状态显示（Add status display）
    ProgressBar := AddCtrl(MyGui, 1, Config_default.Left_Controls.ProgressBar) ; 添加一个隐藏的进度条，用于视觉反馈（Add a hidden progress bar for visual feedback）
    ;;; 退出按钮（Exit button）
    QuitButton := AddCtrl(MyGui, 1, Config_default.Left_Controls.ExitButton) ; 添加退出按钮（Add exit button）
    ;; 第一垂直分隔线（First vertical separator）
    AddCtrl(MyGui, 2, Config_default.VSeparator1)
    ;; 中间——按键序列（Middle part - key sequence）
    AddCtrl(MyGui, 3, Config_default.Middle_Controls.Title)
    SequenceList := AddCtrl(MyGui, 3, Config_default.Middle_Controls.List)
    ;; 第二垂直分隔线（Second vertical separator）
    AddCtrl(MyGui, 4, Config_default.VSeparator2)
    ;; 右侧——参数配置（Right part - parameter configuration）
    ;;; 标题（Title）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.Title)
    ;;; 重复次数（Repetition）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.RepetitionLabel)
    LoopEdit := AddCtrl(MyGui, 5, Config_default.Right_Controls.RepetitionEdit)
    Repeat_UpdateButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.UpdateRepetitionButton)
    RepeatNumber_text := AddCtrl(MyGui, 5, Config_default.Right_Controls.RepetitionValue)
    MeleeRepeat_ResetButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.MeleeResetRepetitionButton)
    RangedRepeat_ResetButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.RangedResetRepetitionButton)
    ;;; 命令执行间隔（Command execution interval）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.IntervalLabel) ; 相邻参数行间隔20像素（Neighboring parameter lines are 20 pixels away）
    IntervalEdit := AddCtrl(MyGui, 5, Config_default.Right_Controls.IntervalEdit)
    Interval_UpdateButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.UpdateIntervalButton)
    Interval_text := AddCtrl(MyGui, 5, Config_default.Right_Controls.IntervalValue)
    Interval_ResetButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.ResetIntervalButton)
    ;;; 全局快捷键禁用（Hotkey to abort key press）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.AbortHotkeyLabel)
    StopKeyEdit := AddCtrl(MyGui, 5, Config_default.Right_Controls.AbortHotkeyEdit)
    StopKey_UpdateButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.UpdateAbortHotkeyButton)
    StopKey_text := AddCtrl(MyGui, 5, Config_default.Right_Controls.AbortHotkeyValue)
    StopKey_ResetButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.ResetAbortHotkeyButton)
    ;;; 全参数复位按钮（Button to reset all parameters）
    AllParameter_ResetButton := AddCtrl(MyGui, 5, Config_default.Right_Controls.ResetAllParameterButton)
    ;; 右侧第一分隔线（First separator of the left part）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.Separator) ; 添加水平分隔线（Add horizontal separator）
    ;; 按键格式说明文本（Key format instruction text）
    AddCtrl(MyGui, 5, Config_default.Right_Controls.AbortHotkeyHelpDoc)
    
    ; 动作配置（Action config）
    ActionConfigs := Map() ; 设置用于StartAction的动作配置表（Set up an action config table for StartAction process）
    ActionConfigs["incgold"] := Map() ; 每个动作也是一个Map对象，分别包含要按下的控制键、按键、要松开的控制键、按钮对象和描述（Each action is also a Map object, containing the control keys to press, the key, the control keys to release, the button object and the description）
    ActionConfigs["incgold"]["ControlKeys"] := ["Shift"] ; 表明要被持续按住的键（Indicates the key to be held down）
    ActionConfigs["incgold"]["Key"] := "T"
    ActionConfigs["incgold"]["Button"] := ActionButton_incgold
    ActionConfigs["incgold"]["Description"] := "增加金钱/Add Gold"
    ActionConfigs["inclevel"] := Map()
    ActionConfigs["inclevel"]["ControlKeys"] := ["Shift"]
    ActionConfigs["inclevel"]["Key"] := "Y"
    ActionConfigs["inclevel"]["Button"] := ActionButton_inclevel
    ActionConfigs["inclevel"]["Description"] := "升级/Level Up"
    ActionConfigs["incunit100health"] := Map()
    ActionConfigs["incunit100health"]["ControlKeys"] := ["Ctrl", "Shift"]
    ActionConfigs["incunit100health"]["Key"] := "T"
    ActionConfigs["incunit100health"]["Button"] := ActionButton_incunit100health
    ActionConfigs["incunit100health"]["Description"] := "添加100最大生命值/Add 100 Max HP"
    ActionConfigs["decunit100health"] := Map()
    ActionConfigs["decunit100health"]["ControlKeys"] := ["Ctrl", "Shift"]
    ActionConfigs["decunit100health"]["Key"] := "Y"
    ActionConfigs["decunit100health"]["Button"] := ActionButton_decunit100health
    ActionConfigs["decunit100health"]["Description"] := "移除100最大生命值/Remove 100 Max HP"
    ActionConfigs["incunit10resistance"] := Map()
    ActionConfigs["incunit10resistance"]["ControlKeys"] := ["Ctrl", "Shift"]
    ActionConfigs["incunit10resistance"]["Key"] := "G"
    ActionConfigs["incunit10resistance"]["Button"] := ActionButton_incunit10resistance
    ActionConfigs["incunit10resistance"]["Description"] := "添加10双抗/Add 10 Resistances"
    ActionConfigs["decunit10resistance"] := Map()
    ActionConfigs["decunit10resistance"]["ControlKeys"] := ["Ctrl", "Shift"]
    ActionConfigs["decunit10resistance"]["Key"] := "H"
    ActionConfigs["decunit10resistance"]["Button"] := ActionButton_decunit10resistance
    ActionConfigs["decunit10resistance"]["Description"] := "移除10双抗/Remove 10 Resistances"
    ActionConfigs["custom"] := Map()
    ActionConfigs["custom"]["ControlKeys"] := []
    ActionConfigs["custom"]["Key"] := ""
    ActionConfigs["custom"]["Button"] := ActionButton_custom
    ActionConfigs["custom"]["Description"] := "自定义/Custom"
    ActionConfigs["sequence"] := Map()
    ; ActionConfigs["sequence"]["ControlKeys"] := []
    ; ActionConfigs["sequence"]["Key"] := ""
    ActionConfigs["sequence"]["Button"] := RunSequenceButton
    ActionConfigs["sequence"]["Description"] := "序列循环/Sequence Loop"
    
    ; 为按钮绑定事件（Bind events to buttons）
    ;; 动作按钮（Action buttons）
    ActionButton_incgold.OnEvent("Click", (*) => StartAction("incgold"))
    ActionButton_inclevel.OnEvent("Click", (*) => StartAction("inclevel"))
    ActionButton_incunit100health.OnEvent("Click", (*) => StartAction("incunit100health"))
    ActionButton_decunit100health.OnEvent("Click", (*) => StartAction("decunit100health"))
    ActionButton_incunit10resistance.OnEvent("Click", (*) => StartAction("incunit10resistance"))
    ActionButton_decunit10resistance.OnEvent("Click", (*) => StartAction("decunit10resistance"))
    ActionButton_custom.OnEvent("Click", (*) => StartCustom())
    ;; 按键序列操作（Key sequence operations）
    PushButton_custom.OnEvent("Click", PushSequence)
    PopButton_custom.OnEvent("Click", PopSequence)
    ClearButton_custom.OnEvent("Click", ClearSequence)
    RunSequenceButton.OnEvent("Click", (*) => StartAction("sequence"))
    ;; 退出按钮（Exit button）
    StopButton.OnEvent("Click", StopAction)
    QuitButton.OnEvent("Click", (*) => ExitApp())
    ;; 参数设置（Parameter configuration）
    ;;; 重复次数（Repetition）
    Repeat_UpdateButton.OnEvent("Click", UpdateLoopCount)
    MeleeRepeat_ResetButton.OnEvent("Click", (*) => ResetLoopCount(false))
    RangedRepeat_ResetButton.OnEvent("Click", (*) => ResetLoopCount(true))
    ;;; 命令执行间隔（Command execution interval）
    Interval_UpdateButton.OnEvent("Click", UpdateInterval)
    Interval_ResetButton.OnEvent("Click", ResetInterval)
    ;;; 中止热键（Abort hotkey）
    StopKey_UpdateButton.OnEvent("Click", UpdateStopKey)
    StopKey_ResetButton.OnEvent("Click", ResetStopKey)
    ;;; 全部复位（Reset all）
    AllParameter_ResetButton.OnEvent("Click", ResetAllParameters)
    ;; 设置窗口关闭和Esc键事件（Set windows close event）
    MyGui.OnEvent("Close", (*) => ExitApp())  ; 点击右上角×（Click on the "×" button on the top-right corner）
    ; MyGui.OnEvent("Escape", (*) => ExitApp()) ; 按Esc键关闭程序。暂时禁用（Press "Esc" to close the app. Temporarily disabled）
    
    ; 其它准备工作（Other preparations）
    UpdateRepetitionText(maxLoops)
    UpdateIntervalText(interval)
    UpdateStopKeyText(stopKey)
    SetTitleMatchMode(3) ; 设置窗口名称精确匹配（Set the window to be matched the exact name）
}

CreateMainGui()

; 显示界面（Show UI）
MyGui.Show()

; 按钮点击事件——开始执行（Click event - Start action）
/**
 * 执行一个动作。<br>Perform an action.
 * @param {String} actionId 动作代号。有以下取值：<br>Action id, which has the following values:
 * - incgold: 增加金钱。<br>Add gold.
 * - inclevel: 升级。<br>Level up.
 * - incunit100health: 添加100最大生命值。<br>Add 100 max HP.
 * - decunit100health: 移除100最大生命值。<br>Remove 100 max HP.
 * - incunit10resistance: 添加10双抗。<br>Add 10 resistances.
 * - decunit10resistance: 移除10双抗。<br>Remove 10 resistances.
 * - custom: 自定义单键。<br>Custom single key.
 * - sequence: 按键序列。<br>Key sequence.
 */
StartAction(actionId, *) {
    global IsRunning, StopRequested
    config := ActionConfigs[actionId]
    
    ; 控制标志（Control flags）
    startBtn := config["Button"]
    startBtn.Enabled := false       ; 禁用开始按钮（Disable the start button）
    StopButton.Enabled := true      ; 启用停止按钮（Enable stop button）
    StopRequested := false          ; 标记用户是否发送了停止的请求。按下停止按钮时，该变量置为真（Marks whether the user has send the stop request. By clicking the stop button, this variable is set as true）
    
    ; 检查游戏窗口（Check window）
    if !WinExist("League of Legends (TM) Client") {
        MsgBox("未找到英雄联盟游戏进程。请确保您已启动一场对局。`nLeague of Legends.exe not found. Please make sure you've started a game.", "错误/Error", 0x10)
        startBtn.Enabled := true
        StopButton.Enabled := false
        StatusText.Text := "错误：未找到游戏窗口。`nError: Game window not found."
        return 1
    }
    
    ; 显示确认提示（Display confirm hint）
    if BasicAttackNeeded_Actions.Has(actionId)
        result := MsgBox("请确保您目前正在对一个单位执行普通攻击指令。如果需要反复执行一段操作，建议您先将手动反复点击【提供状态效果至自身】，将自己置为【致盲】状态。`nPlease make sure you perform basic attack commands toward a unit. If you need to repeat a command, it's highly suggested that you put yourself as `"Blinded`" by clicking [Grant Self Status Effect] for multiple times by hand.`n点按确认后，程序将自动激活英雄联盟游戏窗口，并执行之后的指令。`nAfter you click the `"Confirm`" button, the program will automatically activate the League of Legends window and execute the commands hereafter.", "确认/Confirm", 0x41) ; 0x41选项会使得文本的左侧会带有一个感叹号（0x41 option causes an exclamation mark to appear to the left of the text）
    else
        result := MsgBox("点按确认后，程序将自动激活英雄联盟游戏窗口，并执行之后的指令。`nAfter you click the `"Confirm`" button, the program will automatically activate the League of Legends window and execute the commands hereafter.", "确认/Confirm", 0x41)
    
    if (result = "Cancel") {
        startBtn.Enabled := true
        StopButton.Enabled := false
        StatusText.Text := "已取消。`nCancelled."
        return 0
    }
    
    ; 创建监视对话框（Create a monitor dialog box）
    ProgressMonitorGui := Gui("+AlwaysOnTop +ToolWindow +Border", "执行中…… | Running ...")
    ProgressMonitorGui.SetFont("s10", "Microsoft YaHei")
    ProgressText := ProgressMonitorGui.Add("Text", "w350 Center", "正在初始化……`nInitializing ...") ; 添加进度文本（Add progress text）
    MonitorProgressBar := ProgressMonitorGui.Add("Progress", "w350 h20 Range0-100 -Smooth", 0) ; 添加进度条（Add progress bar）
    MonitorStopButton := ProgressMonitorGui.Add("Button", "w80 h30 xp+135 y+10 Default", "中止/Abort") ; 3. 添加一个“强制中止”按钮（Add an "Abort" button）
    MonitorStopButton.OnEvent("Click", StopAction)
    ProgressMonitorGui.Show("NoActivate") ; 显示这个监视窗口的同时避免抢走焦点（While this window is displayed, don't focus on it）
    
    ; 设置循环计数器（Define loop counter）
    loopCount := 0
    
    ; 开始执行（Start to execute）
    IsRunning := true
    StatusText.Text := Format("执行中…… | Running ...`n{1:d}/{2:d}", loopCount, maxLoops)
    ProgressBar.Value := 0
    
    ; 激活游戏窗口（Activate the window）
    try {
        WinActivate("League of Legends (TM) Client")
        Sleep(500) ; 等待窗口激活
    } catch Error as e {
        StatusText.Text := "错误：无法激活游戏窗口。`nError: Failed to activate the game window."
        startBtn.Enabled := true
        StopButton.Enabled := false
        IsRunning := false
        return 2
    }
    
    ; 模拟按键（Simulate key press）
    if actionId == "sequence" {
        Loop maxLoops {
            ; 检查停止请求（Check stop request）
            if StopRequested {
                StatusText.Text := Format("已停止！执行次数：{1:d}。`nStopped! Number of times: {1:d}.", loopCount)
                break
            }
            
            ; 检查游戏窗口是否仍然存在（Check if the game window still exists）
            if !WinExist("League of Legends (TM) Client") {
                StatusText.Text := "错误：游戏窗口已关闭。`nError: The game window has been closed."
                break
            }
            
            ; 发送按键（Send key press）
            back := false
            for index, array in keySeq {
                keyToSend := array[1]
                try {
                    Send(keyToSend) ; 核心（Core）
                } catch Error as e {
                    StatusText.Text := "错误：发送按键失败。`nError: Failed to send keys."
                    back := true
                    break
                }
                Sleep(interval)
            }
            if back
                break
            
            ; 更新计数和界面（Update counter and UI status text）
            loopCount := A_Index
            ProgressBar.Value := loopCount / maxLoops * 100
            StatusText.Text := Format("执行中…… | Running ...`n{1:d}/{2:d}", loopCount, maxLoops)
            MonitorProgressBar.Value := loopCount / maxLoops * 100 ; 这部分是监视对话框的内容（This part is for monitor dialog box）
            ProgressText.Text := Format("执行中…… | Running ...`n{1:d}/{2:d}", loopCount, maxLoops)
            
            ; 短暂延迟，确保游戏能处理按键（Short lag to ensure the game handle frequent key press request）
            Sleep(interval)
        }
    }
    else {
        ; 准备按键（Prepare keys to press）
        controlKeys := config["ControlKeys"]
        keyToHold := ""
        keyToRelease := ""
        for key in controlKeys {
            keyToHold := keyToHold "{" key " Down}"
            keyToRelease := "{" key " Up}" keyToRelease
        }
        
        ; 按下控制键（Press control keys）
        try {
            Send(keyToHold)
        } catch Error as e {
            StatusText.Text := "错误：按下控制键失败。`nError: Failed to press control keys."
            startBtn.Enabled := true
            StopButton.Enabled := false
            IsRunning := false
            return 3
        }
        
        ; 按下单键（Press the single key）
        keyToSend := "{" config["Key"] "}"
        Loop maxLoops {
            ; 检查停止请求（Check stop request）
            if StopRequested {
                StatusText.Text := Format("已停止！执行次数：{1:d}。`nStopped! Number of times: {1:d}.", loopCount)
                break
            }
            
            ; 检查游戏窗口是否仍然存在（Check if the game window still exists）
            if !WinExist("League of Legends (TM) Client") {
                StatusText.Text := "错误：游戏窗口已关闭。`nError: The game window has been closed."
                break
            }
            
            ; 检查控制按键是否仍然被按下（Check if the control keys are still being held down）
            for key in controlKeys {
                if !GetKeyState(key, "P") {
                    try {
                        Send("{" key " Down}") ; 重新按下因未知原因被松开的按键（Re-press the key that has been released for unknown reason）
                    } catch Error as e {
                        StatusText.Text := "错误：发送按键失败。`nError: Failed to send keys."
                        return 3
                    }
                }
            }
            
            ; 发送按键（Send key press）
            try {
                Send(keyToSend) ; 核心（Core）
            } catch Error as e {
                StatusText.Text := "错误：发送按键失败。`nError: Failed to send keys."
                break
            }
            
            ; 更新计数和界面（Update counter and UI status text）
            loopCount := A_Index
            ProgressBar.Value := loopCount / maxLoops * 100
            StatusText.Text := Format("执行中…… | Running ...`n{1:d}/{2:d}", loopCount, maxLoops)
            MonitorProgressBar.Value := loopCount / maxLoops * 100 ; 这部分是监视对话框的内容（This part is for monitor dialog box）
            ProgressText.Text := Format("执行中…… | Running ...`n{1:d}/{2:d}", loopCount, maxLoops)
            
            ; 短暂延迟，确保游戏能处理按键（Short lag to ensure the game handle frequent key press request）
            Sleep(interval)
        }
        
        ; 松开控制键（Release control keys）
        ControlKeyReleased := false
        try {
            Send(keyToRelease)
            ControlKeyReleased := true
        } catch Error as e {
            StatusText.Text := "警告：松开控制键失败。`nWarning: Failed to release control keys."
        }
    }
    
    ; 执行完成（Execution finished）
    ProgressMonitorGui.Destroy()
    IsRunning := false
    
    ; MyGui.Show()          ; 确保窗口没有被最小化（Make sure the window isn't minimized）
    ; MyGui.Restore()       ; 如果窗口被最小化，则还原它（If the window has been minimized, restore it）
    ; WinActivate(MyGui.Hwnd) ; 将窗口激活到前台（Activate this window to make it front）
    
    if (loopCount = maxLoops && !StopRequested && (actionId == "sequence" || ControlKeyReleased)) {
        StatusText.Text := Format("完成！执行次数：{1:d}。`nFinished! Number of times: {1:d}.", loopCount)
        SoundPlay("*64") ; 播放系统提示音
    }
    
    ; 重置按钮状态（Reset button status）
    startBtn.Enabled := true
    StopButton.Enabled := false
    ProgressBar.Value := 0
    
    return 0
}

/**
 * 循环按下一个自定义单键。<br>Press a custom single key in a loop.
 */
StartCustom(*) {
    ; 首先检查单键输入是否合法（First check whether the single key input is valid）
    inputKey := KeyEdit.Value
    if (StrLen(inputKey) = 0) {
        StatusText.Text := "请输入一个有效的单键。`nPlease input a valid single key."
        return 1
    }
    else If (not GetKeyVK(inputKey)) {
        StatusText.Text := "无效单键。`nInvalid single key."
        return 1
    }
    
    ; 设置控制键（Set control keys）
    controlKeys := []
    if CheckBox1.Value
        controlKeys.Push("Ctrl")
    if CheckBox2.Value
        controlKeys.Push("Shift")
    if CheckBox3.Value
        controlKeys.Push("Alt")
    
    ActionConfigs["custom"]["ControlKeys"] := controlKeys
    ActionConfigs["custom"]["Key"] := KeyEdit.Value
    
    StartAction("custom")
}

; 停止按钮事件（Stop button-triggered event）
/**
 * 停止当前循环。<br>Cancel the current loop.
 */
StopAction(*) {
    global IsRunning, StopRequested
    if IsRunning {
        StopRequested := true
        StatusText.Text := "已发送停止运行的请求。`nSent the stop request."
    }
}

; 更新循环次数的函数（Update the loop count）
/**
 * 读取重复次数编辑框并更新重复次数。<br>Read repetition edit box and update repetition.
 */
UpdateLoopCount(*) {
    global maxLoops
    inputValue := LoopEdit.Value
    
    ; 验证：确保输入是正整数（Ensure the input is a positive integer）
    if Integer(inputValue) > 0 {
        maxLoops := Integer(inputValue)
        StatusText.Text := Format("重复次数已更新。`nThe number of repetitions has been updated.", inputValue)
        UpdateRepetitionText(maxLoops)
    }
    else 
        StatusText.Text := "重复次数必须大于0。`nThe number of repetitions must be greater than 0."
}

/**
 * 更新重复次数的显示。<br>Update the display of repetition.
 * @param {Integer} maxLoops 要显示的重复次数。<br>The repetition to display.
 */
UpdateRepetitionText(maxLoops) {
    RepeatNumber_text.Text := Format("{1:d}次", maxLoops)
}

/**
 * 重置重复次数。<br>Reset repetition.
 * @param {Integer} ranged 是否应用远程数值。<br>Whether to apply the ranged value.
 */
ResetLoopCount(ranged) {
    global maxLoops
    if ranged
        maxLoops := 1980
    else
        maxLoops := 1523
    UpdateRepetitionText(maxLoops)
    StatusText.Text := "重复次数已复位。`nThe number of repetitions has been reset."
}

; 更新命令执行间隔的函数（Update the command execution interval）
/**
 * 读取命令执行间隔编辑框并更新命令执行间隔。<br>Read the command execution interval edit box and update command execution interval.
 */
UpdateInterval(*) {
    global interval
    inputValue := IntervalEdit.Value
    
    if Integer(inputValue) >= 0 {
        interval := Integer(inputValue)
        StatusText.Text := Format("命令执行间隔已更新。`nCommand execution interval has been updated.", inputValue)
        UpdateIntervalText(interval)
    }
    else 
        StatusText.Text := "命令执行间隔必须大于等于0。`nCommand execution interval must be greater than 0."
}

/**
 * 更新命令执行间隔的显示。<br>Update the display of command execution interval.
 * @param {Integer} interval 要显示的命令执行间隔。单位为毫秒。<br>The command execution interval to display, in milliseconds.
 */
UpdateIntervalText(interval) {
    Interval_text.Text := Format("{1:d} ms", interval)
}

/**
 * 重置命令执行间隔。<br>Reset the command execution interval.
 */
ResetInterval(*) {
    global interval
    interval := 0
    UpdateIntervalText(interval)
    StatusText.Text := "命令执行间隔已复位。`nCommand execution interval has been reset."
}

; 更新中止热键的函数（Update the stop hotkey）
/**
 * 检查一个热键字符串的语法合法性。<br>Check the grammatical validity of a hotkey string.
 * @param {String} keyStr 热键字符串。<br>Hotkey string.
 * @returns {Integer} 热键字符串是否合法。<br>Whether the key string is legal.
 */
VerifyKeyValidity(keyStr) {
    if keyStr = ""
        return false
    else {
        try {
            Hotkey(keyStr, (*) => {}, "On") ; 尝试注册热键以验证其有效性（Try to register the hotkey to verify its validity）
            Hotkey(keyStr, "Off") ; 注销热键（Unregister the hotkey）
            return true
        }
        catch {
            return false
        }
    }
}

/**
 * 读取中止热键编辑框并更新中止热键。<br>Read the abort hotkey edit box and update the stop key.
 */
UpdateStopKey(*) {
    global stopKey
    inputValue := StopKeyEdit.Value
    
    if (StrLen(inputValue) = 0) {
        StatusText.Text := "请输入一个中止热键。`nPlease input a stop hotkey."
    }
    else if VerifyKeyValidity(inputValue) {
        stopKey := inputValue
        UpdateStopKeyText(stopKey)
        Hotkey(stopKey, StopAction, "On")
        StatusText.Text := "中止热键已更新。`nThe stop hotkey has been updated."
    }
    else 
        StatusText.Text := "无效的中止热键。`nInvalid stop hotkey."
}

/**
 * 更新中止热键的显示。<br>Update the display of abort hotkey.
 * @param stopKey 
 */
UpdateStopKeyText(stopKey) {
    StopKey_text.Value := stopKey
}

/**
 * 重置中止热键。<br>Reset the abort hotkey.
 */
ResetStopKey(*) {
    global stopKey
    stopKey := "#s"
    UpdateStopKeyText(stopKey)
    Hotkey(stopKey, StopAction, "On")
    StatusText.Text := "中止热键已复位。`nThe stop hotkey has been reset."
}

; 重置所有参数（Reset all parameters）
/**
 * 重置所有参数。<br>Reset all parameters.
 * 
 * 对于重复次数，重置为远程默认数值。<br>As for repetition, it's reset as the default ranged value.
 */
ResetAllParameters(*) {
    ResetLoopCount(true)
    ResetInterval()
    ResetStopKey()
    StatusText.Text := "所有变量已复位。`nAll parameters have been reset."
}

; 按键序列操作（Key sequence operations）
/**
 * 读取自定义部分的按键组合并压入按键序列栈。<br>Read the key combination in custom part and push it into the key sequence stack.
 */
PushSequence(*) {
    ; 校验单键（Verify the single key）
    inputKey := KeyEdit.Value
    if (StrLen(inputKey) = 0) {
        StatusText.Text := "请输入一个有效的单键。`nPlease input a valid single key."
        return 1
    }
    else If (not GetKeyVK(inputKey)) {
        StatusText.Text := "无效单键。`nInvalid single key."
        return 1
    }
    ; 构建按键代码和按键字符串（Construct key code and key string）
    seqCode := "{" inputKey "}"
    seqStr := inputKey
    if CheckBox2.Value {
        seqCode := "{Shift Down}" seqCode "{Shift Up}"
        seqStr := "Shift+" seqStr
    }
    if CheckBox3.Value {
        seqCode := "{Alt Down}" seqCode "{Alt Up}"
        seqStr := "Alt+" seqStr
    }
    if CheckBox1.Value {
        seqCode := "{Ctrl Down}" seqCode "{Ctrl Up}"
        seqStr := "Ctrl+" seqStr
    }
    if (keySeq.Length == 0 or seqCode != keySeq[-1][1]) { ; 相同的按键不允许相邻排列（Repeated key combinations aren't allowed to be placed next to each other）
        ; 修改数据结构（Edit data structure）
        keySeq.Push([seqCode, seqStr])
        ; 展示结果（Display the result）
        SequenceList.Add("", keySeq.Length, seqStr)
    }
}

/**
 * 从按键序列栈中清除最近压入的一个按键组合。<br>Clear the recently pushed key combination from the key sequence stack.
 */
PopSequence(*) {
    if keySeq.Length > 0 {
        SequenceList.Delete(keySeq.Length)
        keySeq.Pop()
    }
}

/**
 * 清除按键序列栈中的所有按键组合。<br>Clear all key combinations in the key sequence stack.
 */
ClearSequence(*) {
    keySeq.Length := 0
    SequenceList.Delete()
}
