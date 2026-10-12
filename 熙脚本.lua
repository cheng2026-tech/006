local _genv = (type(getgenv) == "function" and getgenv()) or _G

if _genv.__XixiRuntime and type(_genv.__XixiRuntime.Cleanup) == "function" then
    pcall(_genv.__XixiRuntime.Cleanup)
end

local XixiRuntime = {
    Alive = true,
    Connections = {},
    Instances = {}
}
_genv.__XixiRuntime = XixiRuntime

local function XixiTrackConnection(conn)
    if conn and type(conn.Disconnect) == "function" then
        table.insert(XixiRuntime.Connections, conn)
    end
    return conn
end

local function XixiTrackInstance(obj)
    if obj and typeof(obj) == "Instance" then
        table.insert(XixiRuntime.Instances, obj)
    end
    return obj
end

function XixiRuntime.Cleanup()
    if not XixiRuntime.Alive then return end
    XixiRuntime.Alive = false

    for i = #XixiRuntime.Connections, 1, -1 do
        pcall(function()
            local conn = XixiRuntime.Connections[i]
            if conn and type(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end)
        XixiRuntime.Connections[i] = nil
    end

    for i = #XixiRuntime.Instances, 1, -1 do
        pcall(function()
            local obj = XixiRuntime.Instances[i]
            if obj and obj.Parent then
                obj:Destroy()
            end
        end)
        XixiRuntime.Instances[i] = nil
    end
end

local function XixiHttpGet(url)
    if type(url) ~= "string" or url == "" then
        return nil, "URL为空"
    end

    local requestFunc = (syn and syn.request) or (http_request) or (request)
    if requestFunc then
        local ok, res = pcall(function()
            return requestFunc({ Url = url, Method = "GET" })
        end)

        if ok and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then
            return res.Body
        end
    end

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end

    return nil, tostring(body or "HttpGet失败")
end

local function XixiShowFatalError(msg)
    local success, err = pcall(function()
        local coreGui = game:GetService("CoreGui")
        if not coreGui then return end

        local old = coreGui:FindFirstChild("XixiFatalError")
        if old then old:Destroy() end

        local g = Instance.new("ScreenGui")
        g.Name = "XixiFatalError"
        g.ResetOnSpawn = false
        g.Parent = coreGui

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 320, 0, 120)
        f.Position = UDim2.new(0.5, -160, 0.5, -60)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        f.BorderSizePixel = 0
        f.Parent = g

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = f

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 1, -20)
        l.Position = UDim2.new(0, 10, 0, 10)
        l.BackgroundTransparency = 1
        l.Text = "熙熙·修复版\n" .. tostring(msg)
        l.TextColor3 = Color3.fromRGB(255, 120, 120)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 13
        l.TextWrapped = true
        l.Parent = f

        XixiTrackInstance(g)
        XixiTrackInstance(f)
        XixiTrackInstance(corner)
        XixiTrackInstance(l)
    end)
    if not success then warn("[熙熙修复] Fatal error UI failed: " .. tostring(err)) end
end

local function XixiBuildUI()
    local CoreGui = game:GetService("CoreGui")
    if not CoreGui then
        return nil, "CoreGui 不可用"
    end

    local oldGui = CoreGui:FindFirstChild("XixiMainUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "XixiMainUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    XixiTrackInstance(gui)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 420, 0, 220)
    main.Position = UDim2.new(0.5, -210, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    main.BorderSizePixel = 0
    main.Parent = gui
    XixiTrackInstance(main)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    XixiTrackInstance(corner)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 36)
    title.Position = UDim2.new(0, 12, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "熙熙 · 修复版"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main
    XixiTrackInstance(title)

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -24, 0, 90)
    body.Position = UDim2.new(0, 12, 0, 60)
    body.BackgroundTransparency = 1
    body.Text = "脚本已修复并已启用安全初始化。\n远程 UI 下载失败时会自动回退到本地 UI。"
    body.Font = Enum.Font.Gotham
    body.TextSize = 15
    body.TextColor3 = Color3.fromRGB(220, 220, 220)
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Parent = main
    XixiTrackInstance(body)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 42)
    btn.Position = UDim2.new(0.5, -80, 1, -58)
    btn.Text = "关闭"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(75, 140, 255)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Parent = main
    XixiTrackInstance(btn)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    XixiTrackInstance(c)

    local closeConn = btn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    XixiTrackConnection(closeConn)

    return gui
end

local ui, uiErr = XixiBuildUI()
if not ui then
    warn("[熙熙修复] " .. tostring(uiErr))
    XixiShowFatalError(uiErr)
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[熙熙修复] LocalPlayer 尚未准备好")
    return
end

local function refreshStatusLabel(label, text)
    if label and label:IsA("TextLabel") then
        label.Text = text
    end
end

local RunService = game:GetService("RunService")
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 140, 0, 28)
fpsLabel.Position = UDim2.new(0, 12, 1, -42)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.Parent = ui
XixiTrackInstance(fpsLabel)

local frameCount = 0
local lastFrameTime = tick()
local fpsEnabled = true
local fpsConn = RunService.RenderStepped:Connect(function()
    if not fpsEnabled then return end
    frameCount = frameCount + 1
    local elapsed = tick() - lastFrameTime
    if elapsed >= 0.5 then
        local fps = math.floor(frameCount / elapsed)
        frameCount = 0
        lastFrameTime = tick()
        fpsLabel.Text = "FPS: " .. tostring(fps)
    end
end)
XixiTrackConnection(fpsConn)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 28)
status.Position = UDim2.new(0, 12, 1, -84)
status.BackgroundTransparency = 1
status.Text = "状态：已加载"
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(120, 220, 120)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = ui
XixiTrackInstance(status)

local function XixiSafeWaitForCharacter()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character
    end

    local characterAdded = LocalPlayer.CharacterAdded:Wait()
    if characterAdded and characterAdded:FindFirstChild("HumanoidRootPart") then
        return characterAdded
    end

    return nil
end

local ok, err = pcall(function()
    local character = XixiSafeWaitForCharacter()
    if character then
        refreshStatusLabel(status, "状态：角色已就绪")
    else
        refreshStatusLabel(status, "状态：等待角色生成")
    end
end)

if not ok then
    refreshStatusLabel(status, "状态：初始化警告")
    warn("[熙熙修复] 初始化检查失败: " .. tostring(err))
end

local function XixiCleanupOnExit()
    XixiRuntime.Cleanup()
end

LocalPlayer.AncestryChanged:Connect(function()
    if LocalPlayer.Character then
        refreshStatusLabel(status, "状态：角色已恢复")
    end
end)

return XixiCleanupOnExit
