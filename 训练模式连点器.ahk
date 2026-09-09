#Requires AutoHotkey v2.0

MsgBox "本脚本依赖于AutoHotKey v2.0，请确保您已安装该应用程序。请确保您是通过以管理员身份运行ahk脚本而不是该脚本编译出来的exe文件来执行此程序，以防杀毒软件误隔离。`nThis program relies on AutoHotKey v2.0. Please make sure you've installed this application. Please make sure you Run the `"ahk`" script instead of the compiled `"exe`" file As Adminstrator, in case the `"exe`" file would be quarantined by any anti-virus software.`n按下Windows+Z以打开AutoHotKey官网。按下Windows+Shift+Z打开AutoHotKey v2官方文档。`nPress Windows + Z to open AutoHotKey official website. Press Windows + Shift + Z to open AutoHotKey v2 official documentation."

#z::Run("https://www.autohotkey.com") ; Windows+Z本来是调出窗口调节选项的，但其实鼠标悬停在最大化/还原按钮上面就可以调出这个选项（Windows + Z is originally meant to pull out the window adjustment options, but actually one can call it out by simplify moving the mouse cursor to the maximize / restore button）
#+z::Run("https://www.autohotkey.com/docs/v2/") ; Windows+Shift+Z打开AutoHotKey v2官方文档（Windows + Shift + Z to open AutoHotKey v2 official documentation）


; 以管理员身份运行（Run As Administrator）
if (!A_IsAdmin) {
    try {
        Run '*RunAs "' A_ScriptFullPath '"'
        ExitApp
    } catch Error as e {
        MsgBox "脚本尝试以管理员权限重启失败。`n在游戏内可能无法正常工作。"
    }
}

; 初始化全局变量（Initialize the global variable）
maxLoops := 1980 ; 重复次数（Repetition times）
interval := 0 ; 命令执行间隔（Command execution interval）
stopKey := "#s" ; 停止热键（Stop hotkey）
Hotkey(stopKey, StopAction, "On")

MyGui := Gui() ; 初始化图形化界面（Initialize Graphical User Interface）
MyGui.SetFont("s12 bold", "Microsoft YaHei")
MyGui.Title := "训练模式连点器 | Practice AutoClicker"

; 整个界面的左侧是事件部分，右侧是参数部分（In the whole interface, the left part is the event part, and the right part is the parameter part）
; 下面设置左侧的事件部分的控件（In the following, we build the left part - event part）
;; 添加描述（Add descriptions）
MyGui.Add("Text", "w500 Center", "《英雄联盟》训练模式按键辅助工具`nLeague of Legends Practice Tool Key Press Assistant")
MyGui.Add("Text", "w500 Center", "请在训练模式中使用，违者后果自负。`nPlease run this program in Practice Tool.`nViolators shall bear the result by themselves.")

MyGui.Add("Text", "w500 0x10") ; 添加水平分隔线。此处表明整个图形化界面的左侧宽度是500像素（Add horizontal separator. Here it shows the width of the left side is 500 digits）

;; 添加动作按钮（Add action buttons）
ActionButton_incgold := MyGui.Add("Button", "w200 r2 x" MyGui.MarginX + 25 " yp+10 center", "增加金钱`nAdd Gold") ; 确保指定绝对坐标时维持全局偏移（Ensure when specifying the absolute coordinates, maintain the global offset）
ActionButton_inclevel := MyGui.Add("Button", "w200 r2 x+50 yp center", "升级`nLevel Up")
ActionButton_incunit100health := MyGui.Add("Button", "w200 r2 x" MyGui.MarginX + 25 " center", "添加100最大生命值`nAdd 100 Max HP")
ActionButton_decunit100health := MyGui.Add("Button", "w200 r2 x+50 yp center", "移除100最大生命值`nRemove 100 Max HP")
ActionButton_incunit10resistance := MyGui.Add("Button", "w200 r2 x" MyGui.MarginX + 25 " center", "添加10双抗`nAdd 10 Resistances")
ActionButton_decunit10resistance := MyGui.Add("Button", "w200 r2 x+50 yp center", "移除10双抗`nRemove 10 Resistances")

MyGui.Add("Text", "w500 x" MyGui.MarginX " y+10 0x10") ; 添加水平分隔线（Add horizontal separator）

;; 添加自定义控制按钮（Add custom control buttons）
MyGui.Add("Text", "w100 r2 x" MyGui.MarginX " y+15 center", "自定义`nCustom")
CheckBox1 := MyGui.Add("Checkbox", "w60 x+0 yp-15", "Ctrl")
CheckBox2 := MyGui.Add("Checkbox", "w60 xp yp+30", "Shift")
CheckBox3 := MyGui.Add("Checkbox", "w60 xp yp+30", "Alt")
MyGui.Add("Text", "w220 r2 x+10 yp-60", "请输入单键：`nPlease input a single key:")
KeyEdit := MyGui.Add("Edit", "w200 xp y+0")
ActionButton_custom := MyGui.Add("Button", "w100 x+10 yp center", "执行/Run")

MyGui.Add("Text", "w500 x" MyGui.MarginX " y+10 0x10") ; 添加水平分隔线（Add horizontal separator）

StopButton := MyGui.Add("Button", "w150 r2 xp+175 yp+10 Disabled", "强制停止`nForce to stop")
StopButton.OnEvent("Click", StopAction)

ActionConfigs := Map() ; 设置用于StartAction的动作配置表（Set up an action config table for StartAction process）
ActionConfigs["incgold"] := Map() ; 每个动作也是一个Map对象，分别包含要按下的控制键、按键、要松开的控制键、按钮对象和描述（Each action is also a Map object, containing the control keys to press, the key, the control keys to release, the button object and the description）
ActionConfigs["incgold"]["ControlKeys"] := ["Shift"] ; 表明要被持续按住的键（Indicates the key to be held down）
ActionConfigs["incgold"]["Key"] := "t"
ActionConfigs["incgold"]["Button"] := ActionButton_incgold
ActionConfigs["incgold"]["Description"] := "增加金钱/Add Gold"
ActionConfigs["inclevel"] := Map()
ActionConfigs["inclevel"]["ControlKeys"] := ["Shift"]
ActionConfigs["inclevel"]["Key"] := "y"
ActionConfigs["inclevel"]["Button"] := ActionButton_inclevel
ActionConfigs["inclevel"]["Description"] := "升级/Level Up"
ActionConfigs["incunit100health"] := Map()
ActionConfigs["incunit100health"]["ControlKeys"] := ["Ctrl", "Shift"]
ActionConfigs["incunit100health"]["Key"] := "t"
ActionConfigs["incunit100health"]["Button"] := ActionButton_incunit100health
ActionConfigs["incunit100health"]["Description"] := "添加100最大生命值/Add 100 Max HP"
ActionConfigs["decunit100health"] := Map()
ActionConfigs["decunit100health"]["ControlKeys"] := ["Ctrl", "Shift"]
ActionConfigs["decunit100health"]["Key"] := "y"
ActionConfigs["decunit100health"]["Button"] := ActionButton_decunit100health
ActionConfigs["decunit100health"]["Description"] := "移除100最大生命值/Remove 100 Max HP"
ActionConfigs["incunit10resistance"] := Map()
ActionConfigs["incunit10resistance"]["ControlKeys"] := ["Ctrl", "Shift"]
ActionConfigs["incunit10resistance"]["Key"] := "g"
ActionConfigs["incunit10resistance"]["Button"] := ActionButton_incunit10resistance
ActionConfigs["incunit10resistance"]["Description"] := "添加10双抗/Add 10 Resistances"
ActionConfigs["decunit10resistance"] := Map()
ActionConfigs["decunit10resistance"]["ControlKeys"] := ["Ctrl", "Shift"]
ActionConfigs["decunit10resistance"]["Key"] := "h"
ActionConfigs["decunit10resistance"]["Button"] := ActionButton_decunit10resistance
ActionConfigs["decunit10resistance"]["Description"] := "移除10双抗/Remove 10 Resistances"
ActionConfigs["custom"] := Map()
ActionConfigs["custom"]["ControlKeys"] := []
ActionConfigs["custom"]["Key"] := ""
ActionConfigs["custom"]["Button"] := ActionButton_custom
ActionConfigs["custom"]["Description"] := "自定义/Custom"

BasicAttackNeeded_Actions := Map() ; 用于普通攻击型功能的输出提示（Used for output hint of basic attack based cheats）
BasicAttackNeeded_Actions["incunit100health"] := true
BasicAttackNeeded_Actions["decunit100health"] := true
BasicAttackNeeded_Actions["incunit10resistance"] := true
BasicAttackNeeded_Actions["decunit10resistance"] := true

;; 状态视觉元素（Status visual elements）
StatusText := MyGui.Add("Text", "w500 r2 x" MyGui.MarginX " Center", "就绪——等待开始……`nReady - Awaiting to start ...") ; 添加状态显示（Add status display）
ProgressBar := MyGui.Add("Progress", "w450 h20 x" MyGui.MarginX + 25 " Range0-100 -Smooth", 0) ; 添加一个隐藏的进度条，用于视觉反馈（Added a hidden progress bar for visual feedback）

MyGui.Add("Button", "w120 h30 x" MyGui.MarginX + 190 " Center", "退出/Quit").OnEvent("Click", (*) => ExitApp()) ; 添加退出按钮（Add exit button）

; 下面设置右侧的参数部分的控件（In the following, we build the right part - parameter part）
MyGui.Add("Text", "h680 x" MyGui.MarginX + 500 " y" MyGui.MarginY + 5 " 0x11") ; 添加垂直分隔线（Add vertical separator）

MyGui.Add("Text", "w600 r2 xp+" MyGui.MarginX " Center y" MyGui.MarginY + 5, "参数设置`nParameter configuration") ; 这里加上MyGui.MarginX是将分隔线视为一个边界，而控件应尽量离边界一些距离。而且这里需要注意一定要设置绝对纵坐标，否则下一个控件会直接从分隔线的底部开始创建（That`MyGui.MarginX` is added is because the separator is considered as a border, and the controls should leave some distance from it. Besides, note here an absolute y must be set, otherwise the next control element will be created from the bottom of the vertical separator）

;; 添加重复次数设置区域（Add repetition area）
MyGui.Add("Text", "w200", "重复次数/Repetition：")
LoopEdit := MyGui.Add("Edit", "w80 Number x+0", maxLoops) ; Number属性限制数字输入（"Number" restricts the input type）
Repeat_UpdateButton := MyGui.Add("Button", "w120 x+10 Center", "更新/Update")
Repeat_UpdateButton.OnEvent("Click", UpdateLoopCount)
RepeatNumber_text := MyGui.Add("Text", "w90 x+10 yp+5", "") ; 微移文本框纵坐标，使得视觉上垂直居中（Shift the text vertical coordinate to make it vertically centered in vision）
UpdateRepetitionText(maxLoops)
Repeat_ResetButton := MyGui.Add("Button", "w120 x+0 yp-5 Center", "复位/Reset")
Repeat_ResetButton.OnEvent("Click", ResetLoopCount)

;; 添加命令执行间隔设置区域（Add command execution interval area）
MyGui.Add("Text", "w200 x" MyGui.MarginX * 2 + 500 " y+20", "间隔/Interval：") ; 相邻参数行间隔20像素（Neighboring parameter lines are 20 pixels away）
IntervalEdit := MyGui.Add("Edit", "w80 Number x+0", interval)
Interval_UpdateButton := MyGui.Add("Button", "w120 x+10 Center", "更新/Update")
Interval_UpdateButton.OnEvent("Click", UpdateInterval)
Interval_text := MyGui.Add("Text", "w90 x+10 yp+5", "")
UpdateIntervalText(interval)
Interval_ResetButton := MyGui.Add("Button", "w120 x+0 yp-5 Center", "复位/Reset")
Interval_ResetButton.OnEvent("Click", ResetInterval)

;; 添加全局快捷键禁用设置（Add the hotkey to abort key press）
MyGui.Add("Text", "w200 x" MyGui.MarginX * 2 + 500 " y+20", "中止热键/Abort Hotkey：")
StopKeyEdit := MyGui.Add("Edit", "w80 x+0", stopKey)
StopKey_UpdateButton := MyGui.Add("Button", "w120 x+10 Center", "更新/Update")
StopKey_UpdateButton.OnEvent("Click", UpdateStopKey)
StopKey_text := MyGui.Add("Text", "w90 x+10 yp+5", "")
UpdateStopKeyText(stopKey)
StopKey_ResetButton := MyGui.Add("Button", "w120 x+0 yp-5 Center", "复位/Reset")
StopKey_ResetButton.OnEvent("Click", ResetStopKey)

;; 添加全参数复位按钮（Add all parameter reset button）
AllParameter_ResetButton := MyGui.Add("Button", "w180 x" MyGui.MarginX * 2 + 500 + 225 " y+20 Center", "复位全部变量`nReset all parameters")
AllParameter_ResetButton.OnEvent("Click", ResetAllParameters)

;; 添加按键格式说明文本（Add key format instruction text）
MyGui.Add("Text", "w650 x" MyGui.MarginX + 500 + 5 " y+10 0x10") ; 添加水平分隔线（Add horizontal separator）

MyGui.Add("Text", "w600 x" MyGui.MarginX * 2 + 500 " y+0", "组合键格式（Key combination rule）：`n#`tWindows`n!`tAlt`n^`tCtrl`n+`tShift`n<`t左控制键（Left control）`n>`t右控制键（Right control）`n示例（Examples）：`n#s`tWindows + S`n<^t`tLCtrl + t`n游戏内仅Windows+单键可用。`nOnly Windows plus a single key works in game.`n更多热键字符串请参考AutoHotKey官方文档。`nFor more hotkey strings, please refer to AutoHotKey official documentation.`n#+z: https://www.autohotkey.com/docs/v2/")

;; 设置按钮松开鼠标的事件（Set the button on-release event）
ActionButton_incgold.OnEvent("Click", (*) => StartAction("incgold"))
ActionButton_inclevel.OnEvent("Click", (*) => StartAction("inclevel"))
ActionButton_incunit100health.OnEvent("Click", (*) => StartAction("incunit100health"))
ActionButton_decunit100health.OnEvent("Click", (*) => StartAction("decunit100health"))
ActionButton_incunit10resistance.OnEvent("Click", (*) => StartAction("incunit10resistance"))
ActionButton_decunit10resistance.OnEvent("Click", (*) => StartAction("decunit10resistance"))
ActionButton_custom.OnEvent("Click", (*) => StartCustom())

; 设置窗口关闭和Esc键事件（Set windows close event）
MyGui.OnEvent("Close", (*) => ExitApp())  ; 点击右上角×（Click on the "×" button on the top-right corner）
; MyGui.OnEvent("Escape", (*) => ExitApp()) ; 按Esc键关闭程序。暂时禁用（Press "Esc" to close the app. Temporarily disabled）

; 显示界面（Show UI）
MyGui.Show()

; 设置窗口名称精确匹配（Set the window to be matched the exact name）
SetTitleMatchMode(3)

; 控制标志（Control flags）
IsRunning := false
StopRequested := false

; 按钮点击事件——开始执行（Click event - Start action）
StartAction(actionId, *) {
    global IsRunning, StopRequested

    config := ActionConfigs[actionId]
    controlKeys := config["ControlKeys"]
    keyToSend := config["Key"]
    startBtn := config["Button"]
    actionDesc := config["Description"]
    
    keyToHold := ""
    keyToRelease := ""
    for key in controlKeys {
        keyToHold := keyToHold "{" key " Down}"
        keyToRelease := keyToRelease "{" key " Up}"
    }

    ; 控制标志（Control flags）
    startBtn.Enabled := false   ; 禁用开始按钮（Disable the start button）
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
        result := MsgBox("请确保您目前正在对一个单位执行普通攻击指令。如果需要反复执行一段操作，建议您先将手动反复点击【提供状态效果至自身】，将自己置为【致盲】状态。`nPlease make sure you perform basic attack commands toward a unit. If you need to repeat a command, it's highly suggested that you put yourself as `"Blinded`" by clicking [Grant Self Status Effect] for multiple times by hand.`n点按确认后，程序将自动激活英雄联盟游戏窗口，并执行之后的指令。`nAfter you click the `"Confirm`" button, the program will automatically activate the League of Legends window and execute the commands hereafter.", "确认/Confirm", 0x41) ; 0x41 = OK/Cancel
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

    ; 执行完成（Execution finished）
    ProgressMonitorGui.Destroy()
    IsRunning := false

    ; MyGui.Show()          ; 确保窗口没有被最小化（Make sure the window isn't minimized）
    ; MyGui.Restore()       ; 如果窗口被最小化，则还原它（If the window has been minimized, restore it）
    ; WinActivate(MyGui.Hwnd) ; 将窗口激活到前台（Activate this window to make it front）
    
    if (loopCount = maxLoops && !StopRequested && ControlKeyReleased) {
        StatusText.Text := Format("完成！执行次数：{1:d}。`nFinished! Number of times: {1:d}.", loopCount)
        SoundPlay("*64") ; 播放系统提示音
    }
    
    ; 重置按钮状态（Reset button status）
    startBtn.Enabled := true
    StopButton.Enabled := false
    ProgressBar.Value := 0

    return 0
}

StartCustom(*) {
    global CheckBox1, CheckBox2, CheckBox3, KeyEdit

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
StopAction(*) {
    global IsRunning, StopRequested
    if IsRunning {
        StopRequested := true
        StatusText.Text := "已发送停止运行的请求。`nSent the stop request."
    }
}

; 更新循环次数的函数（Update the loop count）
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

UpdateRepetitionText(maxLoops) {
    RepeatNumber_text.Text := Format("{1:d}次", maxLoops)
}

ResetLoopCount(*) {
    global maxLoops
    maxLoops := 1980
    UpdateRepetitionText(maxLoops)
    StatusText.Text := "重复次数已复位。`nThe number of repetitions has been reset."
}

; 更新命令执行间隔的函数（Update the command execution interval）
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

UpdateIntervalText(interval) {
    Interval_text.Text := Format("{1:d} ms", interval)
}

ResetInterval(*) {
    global interval
    interval := 0
    UpdateIntervalText(interval)
    StatusText.Text := "命令执行间隔已复位。`nCommand execution interval has been reset."
}

; 更新中止热键的函数（Update the stop hotkey）
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

UpdateStopKeyText(stopKey) {
    StopKey_text.Value := stopKey
}

ResetStopKey(*) {
    global stopKey
    stopKey := "#s"
    UpdateStopKeyText(stopKey)
    Hotkey(stopKey, StopAction, "On")
    StatusText.Text := "中止热键已复位。`nThe stop hotkey has been reset."
}

; 重置所有参数（Reset all parameters）
ResetAllParameters(*) {
    ResetLoopCount()
    ResetInterval()
    ResetStopKey()
    StatusText.Text := "所有变量已复位。`nAll parameters have been reset."
}