-- ==========================================================
-- V16 SIKE — PAINEL DE TESTE ANTI-CHEAT
-- Aimbot + ESP com Team Check
-- ==========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()

-- ===================== ESTADO =====================
local S = {
    Aimbot          = false,
    AimbotFOV       = 250,
    AimbotSmooth    = 1,
    AimbotPart      = "Head",
    MostrarFOV      = false,
    AimbotVisivel   = true,
    AimbotTeamCheck = true,

    ESP             = false,
    ESPBox          = false,
    ESPName         = false,
    ESPHealth       = false,
    ESPLine         = false,
    ESPTeam         = true,
    ESPTeamCheck    = false,
    ESPColor        = Color3.fromRGB(255, 60, 60),

    Speed           = false,
    SpeedVal        = 100,
    SpeedKey        = Enum.KeyCode.F,

    Fly             = false,
    FlySpeed        = 60,
    FlyKey          = Enum.KeyCode.G,

    Noclip          = false,
    NoclipKey       = Enum.KeyCode.H,

    Teleport        = false,
    TeleportKey     = Enum.KeyCode.T,
}

local ESPCache = {}
local conns    = {}
local keybindAtual = nil

-- ===================== UI BASE =====================
local gui = Instance.new("ScreenGui")
gui.Name = "V16SIKE"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local espContainer = Instance.new("Frame")
espContainer.Name = "ESPContainer"
espContainer.Size = UDim2.new(1, 0, 1, 0)
espContainer.BackgroundTransparency = 1
espContainer.BorderSizePixel = 0
espContainer.ZIndex = 1
espContainer.Parent = gui

-- CÍRCULO DE FOV
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.ZIndex = 2
fovCircle.Visible = false
fovCircle.Parent = gui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Thickness = 1.5
fovStroke.Color = Color3.fromRGB(255, 60, 60)
fovStroke.Transparency = 0.2
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ===================== BOTÃO MENU =====================
local menuBtn = Instance.new("TextButton")
menuBtn.Name = "MenuButton"
menuBtn.Size = UDim2.new(0, 90, 0, 40)
menuBtn.Position = UDim2.new(0, 20, 0, 100)
menuBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
menuBtn.Text = "MENU"
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextSize = 15
menuBtn.Active = true
menuBtn.Draggable = true
menuBtn.ZIndex = 20
menuBtn.Parent = gui

Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 8)

local btnStroke = Instance.new("UIStroke", menuBtn)
btnStroke.Color = Color3.fromRGB(255, 80, 80)
btnStroke.Thickness = 2
btnStroke.Transparency = 0.2

-- Painel principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 420)
main.Position = UDim2.new(0.5, -270, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ZIndex = 10
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 40, 40)
stroke.Thickness = 2
stroke.Transparency = 0.3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local glow = Instance.new("UIStroke", main)
glow.Color = Color3.fromRGB(255, 40, 40)
glow.Thickness = 4
glow.Transparency = 0.85
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
header.ZIndex = 11
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "V16 SIKE"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -36, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.ZIndex = 12
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -52)
sidebar.Position = UDim2.new(0, 10, 0, 47)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0, 4)
sideList.SortOrder = Enum.SortOrder.LayoutOrder

local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.PaddingLeft = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)

-- CONTEÚDO
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -52)
content.Position = UDim2.new(0, 150, 0, 47)
content.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
content.BorderSizePixel = 0
content.ZIndex = 11
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

-- ===================== PÁGINAS =====================
local paginas = {}

local function criarPagina(nome)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    frame.ZIndex = 12
    frame.Parent = content

    local l = Instance.new("UIListLayout", frame)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder

    paginas[nome] = frame
    return frame
end

local pagAimbot  = criarPagina("Aimbot")
local pagESP     = criarPagina("ESP")
local pagMove    = criarPagina("Movement")
local pagMisc    = criarPagina("Misc")

-- ===================== SIDEBAR BOTÕES =====================
local abasBotoes = {}
local function criarAba(nome, pagina)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.ZIndex = 12
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    abasBotoes[nome] = btn

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(paginas) do p.Visible = false end
        for _, b in pairs(abasBotoes) do
            b.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
            b.TextColor3 = Color3.fromRGB(220, 220, 230)
        end
        pagina.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

criarAba("🎯 Aimbot",   pagAimbot)
criarAba("👁 ESP",      pagESP)
criarAba("🏃 Movement", pagMove)
criarAba("⚙ Misc",      pagMisc)

-- ===================== HELPERS UI =====================
local function toggle(pagina, nome, key, callback, padrao)
    if padrao ~= nil then S[key] = padrao end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 32)
    btn.BackgroundColor3 = S[key] and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(38, 38, 52)
    btn.Text = "  " .. nome .. "  [" .. (S[key] and "ON" or "OFF") .. "]"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 13
    btn.Parent = pagina
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  " .. nome .. "  [" .. (S[key] and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = S[key] and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(38, 38, 52)
        if callback then callback(S[key]) end
    end)
    return btn
end

local function slider(pagina, nome, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    frame.ZIndex = 13
    frame.Parent = pagina
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = nome .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(210, 210, 230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    bar.ZIndex = 14
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    fill.ZIndex = 15
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = nome .. ": " .. val
        callback(val)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
end

local function dropdown(pagina, nome, opcoes, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    frame.ZIndex = 13
    frame.Parent = pagina
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = nome
    lbl.TextColor3 = Color3.fromRGB(210, 210, 230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = frame

    local atual = 1
    for i, v in ipairs(opcoes) do if v == default then atual = i end end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Text = opcoes[atual]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.ZIndex = 14
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        atual = atual % #opcoes + 1
        btn.Text = opcoes[atual]
        callback(opcoes[atual])
    end)
end

-- ==========================================================
-- TOGGLE COM KEYBIND
-- ==========================================================
local function toggleComKeybind(pagina, nome, keyAtivo, keyTecla, padrao)
    if padrao ~= nil then S[keyAtivo] = padrao end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 32)
    container.BackgroundTransparency = 1
    container.ZIndex = 13
    container.Parent = pagina

    local submenu = Instance.new("Frame")
    submenu.Size = UDim2.new(0.75, 0, 0, 30)
    submenu.Position = UDim2.new(0.22, 0, 0, 36)
    submenu.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    submenu.BorderSizePixel = 0
    submenu.ZIndex = 13
    submenu.Visible = false
    submenu.Parent = container
    Instance.new("UICorner", submenu).CornerRadius = UDim.new(0, 6)

    local lblKey = Instance.new("TextLabel")
    lblKey.Size = UDim2.new(0.6, 0, 1, 0)
    lblKey.Position = UDim2.new(0, 8, 0, 0)
    lblKey.BackgroundTransparency = 1
    lblKey.Text = "Tecla de atalho:"
    lblKey.TextColor3 = Color3.fromRGB(200, 200, 220)
    lblKey.Font = Enum.Font.Gotham
    lblKey.TextSize = 11
    lblKey.TextXAlignment = Enum.TextXAlignment.Left
    lblKey.ZIndex = 14
    lblKey.Parent = submenu

    local btnKey = Instance.new("TextButton")
    btnKey.Size = UDim2.new(0.36, 0, 0, 22)
    btnKey.Position = UDim2.new(0.6, 0, 0, 4)
    btnKey.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btnKey.Text = S[keyTecla].Name
    btnKey.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnKey.Font = Enum.Font.GothamBold
    btnKey.TextSize = 11
    btnKey.ZIndex = 14
    btnKey.Parent = submenu
    Instance.new("UICorner", btnKey).CornerRadius = UDim.new(0, 4)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = S[keyAtivo] and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(38, 38, 52)
    btn.Text = "  " .. nome .. "  [" .. (S[keyAtivo] and "ON" or "OFF") .. "]"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 14
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local function atualizarTamanho()
        if submenu.Visible then
            container.Size = UDim2.new(1, -8, 0, 32 + 36 + 4)
        else
            container.Size = UDim2.new(1, -8, 0, 32)
        end
    end

    btn.MouseButton1Click:Connect(function()
        S[keyAtivo] = not S[keyAtivo]
        btn.Text = "  " .. nome .. "  [" .. (S[keyAtivo] and "ON" or "OFF") .. "]"
        btn.BackgroundColor3 = S[keyAtivo] and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(38, 38, 52)
        submenu.Visible = S[keyAtivo]
        atualizarTamanho()
    end)

    btnKey.MouseButton1Click:Connect(function()
        btnKey.Text = "..."
        btnKey.BackgroundColor3 = Color3.fromRGB(200, 130, 60)
        keybindAtual = { keyTecla = keyTecla, botao = btnKey, ativo = keyAtivo }
    end)

    submenu.Visible = S[keyAtivo]
    atualizarTamanho()
end

-- ==========================================================
-- CAPTURA DE KEYBIND
-- ==========================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if keybindAtual then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            S[keybindAtual.keyTecla] = input.KeyCode
            keybindAtual.botao.Text = input.KeyCode.Name
            keybindAtual.botao.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            keybindAtual = nil
        end
        return
    end

    if input.KeyCode == S.SpeedKey then
        S.Speed = not S.Speed
    elseif input.KeyCode == S.FlyKey then
        S.Fly = not S.Fly
        if not S.Fly then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v.Name == "__FlyBV" or v.Name == "__FlyBG" then v:Destroy() end
                end
            end
        end
    elseif input.KeyCode == S.NoclipKey then
        S.Noclip = not S.Noclip
    elseif input.KeyCode == S.TeleportKey then
        S.Teleport = not S.Teleport
    elseif input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

-- BOTÃO MENU
menuBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- ==========================================================
-- MOVEMENT
-- ==========================================================
RunService.Heartbeat:Connect(function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = S.Speed and S.SpeedVal or 16
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bv = hrp:FindFirstChild("__FlyBV")
    local bg = hrp:FindFirstChild("__FlyBG")

    if not S.Fly then
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        return
    end

    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "__FlyBV"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        bg = Instance.new("BodyGyro")
        bg.Name = "__FlyBG"
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
    end

    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

    bv.Velocity = move.Magnitude > 0 and move.Unit * S.FlySpeed or Vector3.zero
    bg.CFrame = Camera.CFrame
end)

RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local char = LP.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

Mouse.Button1Down:Connect(function()
    if not S.Teleport then return end
    local hit = Mouse.Hit
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hit then
        hrp.CFrame = hit + Vector3.new(0, 3, 0)
    end
end)

-- ==========================================================
-- AIMBOT
-- ==========================================================
local function estaVisivel(parteAlvo)
    if not parteAlvo then return false end
    local char = LP.Character
    if not char then return false end
    local minhaHead = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not minhaHead then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclusoes = { char }
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(exclusoes, p.Character) end
    end
    params.FilterDescendantsInstances = exclusoes
    params.IgnoreWater = true

    local resultado = Workspace:Raycast(minhaHead.Position, parteAlvo.Position - minhaHead.Position, params)
    return resultado == nil
end

local function mesmoTime(p1, p2)
    if not p1 or not p2 then return false end
    if not p1.Team or not p2.Team then return false end
    return p1.Team == p2.Team
end

local function getClosest()
    local centroX = Camera.ViewportSize.X / 2
    local centroY = Camera.ViewportSize.Y / 2
    local raio = S.AimbotFOV / 2

    local closest, dist = nil, raio
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local part = p.Character:FindFirstChild(S.AimbotPart)
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local podePegar = true

                if S.AimbotTeamCheck and mesmoTime(LP, p) then
                    podePegar = false
                end

                if podePegar and S.AimbotVisivel then
                    podePegar = estaVisivel(part)
                end

                if podePegar then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(centroX, centroY)).Magnitude
                        if d < dist then dist = d; closest = part end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    fovCircle.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
    fovCircle.Size = UDim2.new(0, S.AimbotFOV, 0, S.AimbotFOV)
    fovCircle.Visible = S.MostrarFOV

    if not S.Aimbot then
        if S.MostrarFOV then fovStroke.Color = Color3.fromRGB(255, 60, 60) end
        return
    end

    local alvo = getClosest()

    if S.MostrarFOV then
        if alvo then fovStroke.Color = Color3.fromRGB(60, 255, 100)
        else fovStroke.Color = Color3.fromRGB(255, 60, 60) end
    end

    if alvo and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos = Camera.CFrame.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(pos, alvo.Position), S.AimbotSmooth)
    end
end)

-- ==========================================================
-- ESP
-- ==========================================================
local function corDoTime(player)
    if not S.ESPTeam then return S.ESPColor end
    local team = player.Team
    if team and team.TeamColor then return team.TeamColor.Color end
    return S.ESPColor
end

local function criarObjetos(char)
    if ESPCache[char] then return end
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end
    local cor = corDoTime(player)
    local objetos = { char = char, player = player }

    local bordas = {}
    for i = 1, 4 do
        local b = Instance.new("Frame")
        b.BackgroundColor3 = cor
        b.BorderSizePixel = 0
        b.ZIndex = 2
        b.Visible = false
        b.Parent = espContainer
        bordas[i] = b
    end
    objetos.bordas = bordas

    local nome = Instance.new("TextLabel")
    nome.BackgroundTransparency = 1
    nome.Text = char.Name
    nome.TextColor3 = cor
    nome.TextStrokeTransparency = 0
    nome.Font = Enum.Font.GothamBold
    nome.TextSize = 14
    nome.ZIndex = 3
    nome.Visible = false
    nome.Parent = espContainer
    objetos.nome = nome

    local healthBG = Instance.new("Frame")
    healthBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBG.BorderSizePixel = 0
    healthBG.ZIndex = 2
    healthBG.Visible = false
    healthBG.Parent = espContainer
    Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0, 2)

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(60, 220, 90)
    healthFill.BorderSizePixel = 0
    healthFill.ZIndex = 3
    healthFill.Parent = healthBG
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0, 2)

    objetos.healthBG = healthBG
    objetos.healthFill = healthFill

    local line = Instance.new("Frame")
    line.BackgroundColor3 = cor
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 2
    line.Visible = false
    line.Parent = espContainer
    objetos.line = line

    ESPCache[char] = objetos
end

local function deletarObjetos(char)
    local obj = ESPCache[char]
    if not obj then return end
    if obj.bordas then
        for _, b in ipairs(obj.bordas) do if b.Parent then b:Destroy() end end
    end
    if obj.nome and obj.nome.Parent then obj.nome:Destroy() end
    if obj.healthBG and obj.healthBG.Parent then obj.healthBG:Destroy() end
    if obj.line and obj.line.Parent then obj.line:Destroy() end
    ESPCache[char] = nil
end

task.spawn(function()
    local vp = Camera.ViewportSize
    while true do
        RunService.RenderStepped:Wait()

        if not S.ESP then
            for _, obj in pairs(ESPCache) do
                for _, b in ipairs(obj.bordas) do b.Visible = false end
                obj.nome.Visible = false
                obj.healthBG.Visible = false
                obj.line.Visible = false
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character.Parent then
                    for char, obj in pairs(ESPCache) do
                        if obj.player == p and char ~= p.Character then
                            deletarObjetos(char)
                        end
                    end
                    criarObjetos(p.Character)
                end
            end

            for char, obj in pairs(ESPCache) do
                if not char.Parent then
                    deletarObjetos(char)
                else
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and head and hum then
                        local p2 = Players:GetPlayerFromCharacter(char) or obj.player
                        local corAtual = corDoTime(p2)
                        local headScreen, headOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        local rootScreen, rootOn = Camera:WorldToViewportPoint(hrp.Position)
                        local feetScreen, feetOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local onScreen = headOn and rootOn and feetOn

                        -- TEAM CHECK NO ESP
                        local ehMesmoTime = false
                        if S.ESPTeamCheck and p2 then
                            if LP.Team and p2.Team and LP.Team == p2.Team then
                                ehMesmoTime = true
                            end
                        end

                        if onScreen and not ehMesmoTime then
                            local altura = math.abs(feetScreen.Y - headScreen.Y)
                            local largura = altura * 0.55
                            local cx = rootScreen.X
                            local cyTop = headScreen.Y
                            local cyBot = feetScreen.Y

                            if S.ESPBox then
                                local esp = 1.5
                                local b = obj.bordas
                                b[1].Size = UDim2.new(0, largura, 0, esp); b[1].Position = UDim2.new(0, cx - largura/2, 0, cyTop)
                                b[2].Size = UDim2.new(0, largura, 0, esp); b[2].Position = UDim2.new(0, cx - largura/2, 0, cyBot)
                                b[3].Size = UDim2.new(0, esp, 0, altura);  b[3].Position = UDim2.new(0, cx - largura/2, 0, cyTop)
                                b[4].Size = UDim2.new(0, esp, 0, altura);  b[4].Position = UDim2.new(0, cx + largura/2, 0, cyTop)
                                for i = 1, 4 do b[i].BackgroundColor3 = corAtual; b[i].Visible = true end
                            else
                                for i = 1, 4 do obj.bordas[i].Visible = false end
                            end

                            if S.ESPName then
                                obj.nome.Position = UDim2.new(0, cx - 100, 0, cyTop - 20)
                                obj.nome.Size = UDim2.new(0, 200, 0, 18)
                                obj.nome.TextColor3 = corAtual
                                obj.nome.Visible = true
                            else obj.nome.Visible = false end

                            if S.ESPHealth then
                                local hp = hum.Health / hum.MaxHealth
                                obj.healthBG.Size = UDim2.new(0, largura, 0, 4)
                                obj.healthBG.Position = UDim2.new(0, cx - largura/2, 0, cyBot + 3)
                                obj.healthBG.Visible = true
                                obj.healthFill.Size = UDim2.new(hp, 0, 1, 0)
                            else obj.healthBG.Visible = false end

                            if S.ESPLine then
                                local origem = Vector2.new(vp.X / 2, vp.Y)
                                local destino = Vector2.new(cx, cyBot)
                                local diff = destino - origem
                                local comprimento = diff.Magnitude
                                local angulo = math.deg(math.atan2(diff.Y, diff.X))
                                obj.line.Size = UDim2.new(0, comprimento, 0, 1.5)
                                obj.line.Position = UDim2.new(0, (origem.X + destino.X) / 2, 0, (origem.Y + destino.Y) / 2)
                                obj.line.Rotation = angulo
                                obj.line.BackgroundColor3 = corAtual
                                obj.line.Visible = true
                            else obj.line.Visible = false end
                        else
                            for i = 1, 4 do obj.bordas[i].Visible = false end
                            obj.nome.Visible = false
                            obj.healthBG.Visible = false
                            obj.line.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================================
-- PÁGINA: AIMBOT
-- ==========================================================
toggle(pagAimbot, "Ativar Aimbot (Botão Direito)", "Aimbot", nil, false)
toggle(pagAimbot, "Mostrar Círculo FOV",           "MostrarFOV", nil, false)
toggle(pagAimbot, "Wall Check (só pega visível)",  "AimbotVisivel", nil, true)
toggle(pagAimbot, "Team Check (só inimigos)",      "AimbotTeamCheck", nil, true)
slider(pagAimbot, "Tamanho FOV", 50, 800, 250, function(v) S.AimbotFOV = v end)
slider(pagAimbot, "Suavidade", 1, 10, 1, function(v) S.AimbotSmooth = 1 / v end)
dropdown(pagAimbot, "Parte do alvo", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v)
    S.AimbotPart = v
end)

-- ==========================================================
-- PÁGINA: ESP
-- ==========================================================
toggle(pagESP, "Ativar ESP (Master)",       "ESP",          nil, false)
toggle(pagESP, "Mostrar Box",               "ESPBox",       nil, false)
toggle(pagESP, "Mostrar Nome",              "ESPName",      nil, false)
toggle(pagESP, "Mostrar Vida",              "ESPHealth",    nil, false)
toggle(pagESP, "Mostrar Line",              "ESPLine",      nil, false)
toggle(pagESP, "Cor do Time",               "ESPTeam",      nil, true)
toggle(pagESP, "Team Check (só inimigos)",  "ESPTeamCheck", nil, false)

-- ==========================================================
-- PÁGINA: MOVEMENT
-- ==========================================================
toggleComKeybind(pagMove, "Speed Hack",  "Speed",    "SpeedKey",    false)
slider(pagMove, "Speed Valor", 16, 500, 100, function(v) S.SpeedVal = v end)

toggleComKeybind(pagMove, "Fly",         "Fly",      "FlyKey",      false)
slider(pagMove, "Fly Velocidade", 20, 300, 60, function(v) S.FlySpeed = v end)

toggleComKeybind(pagMove, "Noclip",      "Noclip",   "NoclipKey",   false)

toggleComKeybind(pagMove, "Teleport com Mouse", "Teleport", "TeleportKey", false)

-- ==========================================================
-- PÁGINA: MISC
-- ==========================================================
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -8, 0, 200)
info.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
info.Text = "V16 SIKE\n\nAimbot = botão DIREITO do mouse\nTeam Check (Aimbot): só trava em inimigos\nTeam Check (ESP): só mostra inimigos\nWall Check: só trava quem tá visível\nKeybind: clique na tecla e aperte nova\n\nInsert = mostra/esconde painel"
info.TextColor3 = Color3.fromRGB(255, 120, 120)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.TextWrapped = true
info.ZIndex = 13
info.Parent = pagMisc
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 6)

-- ==========================================================
-- ABRIR PÁGINA PADRÃO
-- ==========================================================
pagAimbot.Visible = true
abasBotoes["🎯 Aimbot"].BackgroundColor3 = Color3.fromRGB(140, 60, 60)
abasBotoes["🎯 Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

print("[V16 SIKE] Carregado! Team Check no ESP adicionado.")
