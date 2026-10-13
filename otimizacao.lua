-- =============================================================================
-- SCRIPT: otm luca (OTIMIZAÇÃO AVANÇADA RESPONSIVA)
-- DESENVOLVIDO COM MÁXIMA PRECISÃO E COMPATIBILIDADE DE TOQUE (DELTA EXECUTOR)
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Limpa execuções anteriores para não bugar a tela
if CoreGui:FindFirstChild("otm_luca_gui") then
    CoreGui["otm_luca_gui"]:Destroy()
end

-- =============================================================================
-- TABELAS DE MEMÓRIA (Guarda as texturas originais do jogo)
-- =============================================================================
local OriginalTextures = {}
local TexturasDesativadas = false
local GraficoMassinhaAtivo = false
local OtimizadorFPSAtivo = false

local function SalvarOriginal(obj)
    if not OriginalTextures[obj] then
        if obj:IsA("Texture") or obj:IsA("Decal") then
            OriginalTextures[obj] = {Texture = obj.Texture}
        elseif obj:IsA("MeshPart") then
            OriginalTextures[obj] = {TextureID = obj.TextureID}
        elseif obj:IsA("SpecialMesh") then
            OriginalTextures[obj] = {TextureId = obj.TextureId}
        elseif obj:IsA("Part") or obj:IsA("SpawnLocation") or obj:IsA("WedgePart") or obj:IsA("CornerWedgePart") then
            OriginalTextures[obj] = {Material = obj.Material}
        end
    end
end

-- Ouvinte para novos mapas/objetos carregados dinamicamente
Workspace.DescendantAdded:Connect(function(descendant)
    if TexturasDesativadas or GraficoMassinhaAtivo then
        task.wait(0.2)
        pcall(function()
            SalvarOriginal(descendant)
            if TexturasDesativadas then
                if descendant:IsA("Texture") or descendant:IsA("Decal") then descendant.Texture = "" end
                if descendant:IsA("MeshPart") then descendant.TextureID = "" end
            elseif GraficoMassinhaAtivo then
                if descendant:IsA("Part") or descendant:IsA("SpawnLocation") then descendant.Material = Enum.Material.SmoothPlastic end
            end
        end)
    end
end)

-- =============================================================================
-- CRIAÇÃO DA INTERFACE (AZUL GRADIENTE COM PRETO)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "otm_luca_gui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Botão Flutuante Circular "UPD"
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "UPDBtn"
FloatingBtn.Parent = ScreenGui
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatingBtn.Text = "UPD"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.TextSize = 18
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true

local UICornerFloat = Instance.new("UICorner")
UICornerFloat.CornerRadius = UDim.new(1, 0) -- Força formato perfeitamente redondo
UICornerFloat.Parent = FloatingBtn

local UIGradientFloat = Instance.new("UIGradient")
UIGradientFloat.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
})
UIGradientFloat.Rotation = 45
UIGradientFloat.Parent = FloatingBtn

-- Painel de Configurações Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 270, 0, 350)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false -- Começa fechado, abre estritamente no clique do UPD
MainFrame.Active = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 14)
UICornerMain.Parent = MainFrame

local UIGradientMain = Instance.new("UIGradient")
UIGradientMain.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 70, 200)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(15, 15, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
})
UIGradientMain.Rotation = 135
UIGradientMain.Parent = MainFrame

-- Título Superior do Painel
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "OTM LUCA - SUPREMO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold

-- Caixa Fixa do Mostrador de FPS
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = MainFrame
FpsLabel.Size = UDim2.new(0.9, 0, 0, 35)
FpsLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
FpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
FpsLabel.BackgroundTransparency = 0.2
FpsLabel.Text = "FPS: Medindo Celular..."
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FpsLabel.TextSize = 14
FpsLabel.Font = Enum.Font.Code

local UICornerFps = Instance.new("UICorner")
UICornerFps.CornerRadius = UDim.new(0, 8)
UICornerFps.Parent = FpsLabel

-- Painel Invisível para Organizar os Botões
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = MainFrame
ButtonContainer.Size = UDim2.new(0.9, 0, 0.65, 0)
ButtonContainer.Position = UDim2.new(0.05, 0, 0.28, 0)
ButtonContainer.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Criador de Botões customizados
local function CriarBotaoOtm(nome, texto, ordem)
    local Btn = Instance.new("TextButton")
    Btn.Name = nome
    Btn.Parent = ButtonContainer
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
    Btn.Text = texto
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.LayoutOrder = ordem
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 110, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.6
    Stroke.Parent = Btn
    
    return Btn
end

local BtnTexturas = CriarBotaoOtm("BtnTexturas", "Desativar Texturas: [OFF]", 1)
local BtnMassinha = CriarBotaoOtm("BtnMassinha", "Gráfico Massinha: [OFF]", 2)
local BtnFPS = CriarBotaoOtm("BtnFPS", "Otimizador de FPS/Rede: [OFF]", 3)

-- =============================================================================
-- LOGIC DO ARRASTAR DA JANELA COMPATÍVEL COM CELULAR (SISTEMA MOBILE-SAFE)
-- =============================================================================
local function ConfigurarArrastar(InstanciaFrame)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        InstanciaFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    InstanciaFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = InstanciaFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- Ativa o movimento arrastável no Botão UPD e na Janela Principal de forma isolada
ConfigurarArrastar(FloatingBtn)
ConfigurarArrastar(MainFrame)

-- =============================================================================
-- CONTROLE DE CLIQUE ATIVAR/DESATIVAR DO BOTÃO UPD (MECANISMO SEGURO)
-- =============================================================================
FloatingBtn.Activated:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- =============================================================================
-- CÁLCULO ESTÁVEL DO FPS
-- =============================================================================
local TimeCounter = 0
local FrameCounts = 0
RunService.RenderStepped:Connect(function(dt)
    FrameCounts = FrameCounts + 1
    TimeCounter = TimeCounter + dt
    if TimeCounter >= 1.0 then
        FpsLabel.Text = "FPS DISPOSITIVO: " .. tostring(FrameCounts) .. " FPS"
        FrameCounts = 0
        TimeCounter = 0
    end
end)

-- =============================================================================
-- SISTEMAS INTERNOS DE PERFORMANCE DO CORE ENGINE
-- =============================================================================

-- 1. SISTEMA DE ALTERNAR TEXTURAS
BtnTexturas.Activated:Connect(function()
    TexturasDesativadas = not TexturasDesativadas
    
    if TexturasDesativadas then
        BtnTexturas.Text = "Desativar Texturas: [ON]"
        BtnTexturas.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                SalvarOriginal(obj)
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Texture = ""
                    
