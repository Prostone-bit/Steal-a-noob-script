local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Platform Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

-- GUI Container
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "TPGui"
gui.ResetOnSpawn = false

-- Beautiful Startup Animation Popup
local startupPopup = Instance.new("Frame", gui)
startupPopup.Size = UDim2.new(0, 0, 0, 0)
startupPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
startupPopup.AnchorPoint = Vector2.new(0.5, 0.5)
startupPopup.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
startupPopup.BorderSizePixel = 0
startupPopup.ZIndex = 1000
Instance.new("UICorner", startupPopup).CornerRadius = UDim.new(0, 20)

-- Gradient background for popup
local gradient = Instance.new("UIGradient", startupPopup)
gradient.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 144, 255)),
  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
}
gradient.Rotation = 45

-- Animated border
local border = Instance.new("Frame", startupPopup)
border.Size = UDim2.new(1, 8, 1, 8)
border.Position = UDim2.new(0.5, 0, 0.5, 0)
border.AnchorPoint = Vector2.new(0.5, 0.5)
border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
border.ZIndex = 999
Instance.new("UICorner", border).CornerRadius = UDim.new(0, 24)

local borderGradient = Instance.new("UIGradient", border)
borderGradient.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 20, 147)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
}

-- Main title
local popupTitle = Instance.new("TextLabel", startupPopup)
popupTitle.Size = UDim2.new(1, 0, 0.4, 0)
popupTitle.Position = UDim2.new(0, 0, 0.1, 0)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "ta mère la pute"
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextSize = 48
popupTitle.TextTransparency = 0
popupTitle.TextStrokeTransparency = 0
popupTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
popupTitle.ZIndex = 1001

-- Subtitle
local popupSubtitle = Instance.new("TextLabel", startupPopup)
popupSubtitle.Size = UDim2.new(1, 0, 0.3, 0)
popupSubtitle.Position = UDim2.new(0, 0, 0.45, 0)
popupSubtitle.BackgroundTransparency = 1
popupSubtitle.Text = "Fuck les noirs et fuck steal a noob"
popupSubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupSubtitle.Font = Enum.Font.Gotham
popupSubtitle.TextSize = 32
popupTitle.TextTransparency = 0
popupSubtitle.TextStrokeTransparency = 0
popupSubtitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
popupSubtitle.ZIndex = 1001

-- Sparkle effects
local function createSparkle(parent, delay)
  local sparkle = Instance.new("Frame", parent)
  sparkle.Size = UDim2.new(0, 8, 0, 8)
  sparkle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  sparkle.BorderSizePixel = 0
  sparkle.Rotation = math.random(0, 360)
  Instance.new("UICorner", sparkle).CornerRadius = UDim.new(1, 0)
  
  -- Random position
  sparkle.Position = UDim2.new(math.random(10, 90)/100, 0, math.random(10, 90)/100, 0)
  
  -- Sparkle animation
  spawn(function()
    wait(delay)
    for i = 1, 3 do
      local sparkleTween = TweenService:Create(
        sparkle,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true),
        {
          Size = UDim2.new(0, 12, 0, 12),
          BackgroundTransparency = 0.7,
          Rotation = sparkle.Rotation + 180
        }
      )
      sparkleTween:Play()
      wait(1)
    end
    sparkle:Destroy()
  end)
end

-- Create multiple sparkles
for i = 1, 15 do
  createSparkle(startupPopup, math.random(0, 2))
end

-- Startup Animation Sequence
spawn(function()
  -- Phase 1: Popup appears with bounce
  local popupAppear = TweenService:Create(
    startupPopup,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 500, 0, 300)}
  )
  
  -- Phase 2: Border rotation
  local borderRotation = TweenService:Create(
    borderGradient,
    TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    {Rotation = 360}
  )
  
  -- Phase 3: Text pulse animation
  local textPulse = TweenService:Create(
    popupTitle,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {TextSize = 52}
  )
  
  local subtitlePulse = TweenService:Create(
    popupSubtitle,
    TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {TextSize = 36}
  )
  
  -- Execute animations
  popupAppear:Play()
  popupAppear.Completed:Connect(function()
    borderRotation:Play()
    textPulse:Play()
    subtitlePulse:Play()
    
    -- Auto-close after 4 seconds with fade out
    wait(4)
    local fadeOut = TweenService:Create(
      startupPopup,
      TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
      {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
      }
    )
    
    local titleFade = TweenService:Create(
      popupTitle,
      TweenInfo.new(1, Enum.EasingStyle.Quad),
      {TextTransparency = 1}
    )
    
    local subtitleFade = TweenService:Create(
      popupSubtitle,
      TweenInfo.new(1, Enum.EasingStyle.Quad),
      {TextTransparency = 1}
    )
    
    fadeOut:Play()
    titleFade:Play()
    subtitleFade:Play()
    
    fadeOut.Completed:Connect(function()
      startupPopup:Destroy()
    end)
  end)
end)

-- Responsive sizing based on platform
local frameWidth = isMobile and math.min(screenSize.X * 0.85, 320) or 300
local frameHeight = isMobile and math.min(screenSize.Y * 0.6, 300) or 270

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, isMobile and 16 or 12)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, isMobile and 40 or 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Fuck Steal a Noob"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = isMobile and 18 or 20
title.TextScaled = isMobile

-- Distance Slider
local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.new(0.8, 0, 0, 6)
sliderBar.Position = UDim2.new(0.1, 0, 0.18, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

local knob = Instance.new("Frame", sliderBar)
knob.Size = UDim2.new(0, 14, 0, 20)
knob.Position = UDim2.new(0.5, -7, -0.7, 0)
knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local valueLabel = Instance.new("TextLabel", frame)
valueLabel.Size = UDim2.new(1, 0, 0, 30)
valueLabel.Position = UDim2.new(0, 0, 0.28, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.TextColor3 = Color3.new(1, 1, 1)
valueLabel.TextSize = 18
valueLabel.Font = Enum.Font.Gotham
valueLabel.Text = "Distance : 15 m"

-- Buttons
local function createButton(text, yPos, color)
  local btn = Instance.new("TextButton", frame)
  btn.Size = UDim2.new(0.8, 0, 0, isMobile and 45 or 35)
  btn.Position = UDim2.new(0.1, 0, yPos, 0)
  btn.Text = text
  btn.BackgroundColor3 = color
  btn.TextColor3 = Color3.new(1, 1, 1)
  btn.Font = Enum.Font.GothamBold
  btn.TextSize = isMobile and 16 or 20
  btn.TextScaled = isMobile
  Instance.new("UICorner", btn).CornerRadius = UDim.new(0, isMobile and 12 or 8)
  return btn
end

local tpButton = createButton("TP", 0.42, Color3.fromRGB(0, 170, 255))
local espButton = createButton("ESP ON", 0.61, Color3.fromRGB(40, 180, 90))
local speedButton = createButton("Boost Vitesse", 0.78, Color3.fromRGB(255, 160, 0))

-- Popup
local tpPopup = Instance.new("TextLabel", gui)
tpPopup.Size = UDim2.new(1, 0, 1, 0)
tpPopup.Position = UDim2.new(0, 0, 0, 0)
tpPopup.BackgroundColor3 = Color3.new(0, 0, 0)
tpPopup.BackgroundTransparency = 0.4
tpPopup.Text = "Tu te tp fdp"
tpPopup.TextColor3 = Color3.new(1, 1, 1)
tpPopup.TextSize = 40
tpPopup.Font = Enum.Font.GothamBold
tpPopup.Visible = false

-- Toggle Button (improved and responsive)
local toggleSize = isMobile and 70 or 56
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, toggleSize, 0, toggleSize)
toggleButton.Position = UDim2.new(0, isMobile and 15 or 20, 0.5, -toggleSize/2)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Text = "🎮"
toggleButton.TextSize = isMobile and 32 or 28
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.AutoButtonColor = false
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

-- Enhanced shadow effect
local shadow = Instance.new("Frame", toggleButton)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 3, 0.5, 3)
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = -1
Instance.new("UICorner", shadow).CornerRadius = UDim.new(1, 0)

-- Pulse animation for mobile
local pulseAnimation
if isMobile then
  pulseAnimation = TweenService:Create(
    toggleButton,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Size = UDim2.new(0, toggleSize * 1.1, 0, toggleSize * 1.1)}
  )
  pulseAnimation:Play()
end

-- Enhanced hover effects
if not isMobile then
  toggleButton.MouseEnter:Connect(function()
    local hoverTween = TweenService:Create(
      toggleButton,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad),
      {
        BackgroundColor3 = Color3.fromRGB(0, 190, 255),
        Size = UDim2.new(0, toggleSize * 1.15, 0, toggleSize * 1.15)
      }
    )
    hoverTween:Play()
  end)
  
  toggleButton.MouseLeave:Connect(function()
    local leaveTween = TweenService:Create(
      toggleButton,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad),
      {
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        Size = UDim2.new(0, toggleSize, 0, toggleSize)
      }
    )
    leaveTween:Play()
  end)
end

local uiVisible = true
toggleButton.MouseButton1Click:Connect(function()
  uiVisible = not uiVisible
  
  -- Smooth fade animation
  local targetTransparency = uiVisible and 0 or 1
  local fadeTween = TweenService:Create(
    frame,
    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
    {BackgroundTransparency = targetTransparency}
  )
  
  -- Update button appearance
  toggleButton.Text = uiVisible and "🎮" or "📱"
  toggleButton.BackgroundColor3 = uiVisible and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 100, 100)
  
  fadeTween:Play()
  if uiVisible then
    frame.Visible = true
    fadeTween.Completed:Connect(function()
      -- Make all children visible with fade
      for _, child in pairs(frame:GetChildren()) do
        if child:IsA("GuiObject") then
          child.Visible = true
        end
      end
    end)
  else
    fadeTween.Completed:Connect(function()
      frame.Visible = false
    end)
  end
end)

-- Draggable Function (mobile + pc, clamped)
local function makeDraggable(frame)
  local dragging = false
  local dragInput, dragStart, startPos

  frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
      -- Don't start dragging if we're interacting with a slider
      local hitObject = input.Hit and input.Hit.Parent
      if hitObject and (hitObject == sliderBar or hitObject == speedSliderBar or hitObject == jumpSliderBar or 
                       hitObject.Parent == sliderBar or hitObject.Parent == speedSliderBar or hitObject.Parent == jumpSliderBar) then
        return
      end
      
      dragging = true
      dragStart = input.Position
      startPos = frame.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)

  UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
      local delta = input.Position - dragStart
      local newPos = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
      local screen = workspace.CurrentCamera.ViewportSize
      newPos = UDim2.new(0,
        math.clamp(newPos.X.Offset, 0, screen.X - frame.AbsoluteSize.X),
        0,
        math.clamp(newPos.Y.Offset, 0, screen.Y - frame.AbsoluteSize.Y)
      )
      frame.Position = newPos
    end
  end)
end

makeDraggable(frame)
makeDraggable(toggleButton)

-- Slider Logic
local currentDistance = 15
local minDist = 0
local maxDist = 30
local isDraggingDistanceSlider = false

local function updateSlider(inputX)
  local relX = math.clamp(inputX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
  local percent = relX / sliderBar.AbsoluteSize.X
  currentDistance = math.floor(minDist + (maxDist - minDist) * percent + 0.5)
  knob.Position = UDim2.new(percent, -7, -0.7, 0)
  valueLabel.Text = "Distance : " .. currentDistance .. " m"
end

sliderBar.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingDistanceSlider = true
    updateSlider(input.Position.X)
    input.UserInputService = nil -- Prevent event propagation
  end
end)

sliderBar.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingDistanceSlider = false
  end
end)

UserInputService.InputChanged:Connect(function(input)
  if isDraggingDistanceSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    updateSlider(input.Position.X)
  end
end)

-- TP Function
local function teleport()
  local char = player.Character or player.CharacterAdded:Wait()
  local root = char:FindFirstChild("HumanoidRootPart")
  local humanoid = char:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid then return end

  tpPopup.Visible = true

  local function safeTweenTo(offset)
    local goal = root.CFrame + offset
    local tween = TweenService:Create(root, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {CFrame = goal})
    tween:Play()
    tween.Completed:Wait()
    return (root.Position - goal.Position).Magnitude < 1
  end

  local dir = root.CFrame.LookVector.Unit
  local success = false

  for i = 1, 5 do
    local down = Vector3.new(0, -10, 0)
    local forward = dir * currentDistance
    local up = Vector3.new(0, 12, 0)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

    if safeTweenTo(down) and safeTweenTo(forward) and safeTweenTo(up) then
      success = true
      break
    end
    task.wait(0.1)
  end

  tpPopup.Visible = false
end

tpButton.MouseButton1Click:Connect(teleport)

-- ESP System Variables
local espTags = {}
local espSettings = {
  enabled = false,
  showPlayers = true,
  showObjects = true,
  showInvisible = true,
  showAll = false,
  viewRadius = 100
}

-- ESP Configuration Interface
local espFrameWidth = isMobile and math.min(screenSize.X * 0.9, 380) or 400
local espFrameHeight = isMobile and math.min(screenSize.Y * 0.85, 500) or 520

local espFrame = Instance.new("Frame", gui)
espFrame.Size = UDim2.new(0, espFrameWidth, 0, espFrameHeight)
espFrame.Position = UDim2.new(0.5, -espFrameWidth/2, 0.5, -espFrameHeight/2)
espFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
espFrame.BorderSizePixel = 0
espFrame.Visible = false
Instance.new("UICorner", espFrame).CornerRadius = UDim.new(0, isMobile and 16 or 12)

-- ESP Frame Gradient
local espGradient = Instance.new("UIGradient", espFrame)
espGradient.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
espGradient.Rotation = 90

-- ESP Frame Title
local espTitle = Instance.new("TextLabel", espFrame)
espTitle.Size = UDim2.new(1, 0, 0, isMobile and 50 or 45)
espTitle.Position = UDim2.new(0, 0, 0, 0)
espTitle.Text = "Esp de salope"
espTitle.BackgroundTransparency = 1
espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = isMobile and 18 or 20
espTitle.TextScaled = isMobile

-- ESP Close Button
local espCloseButton = Instance.new("TextButton", espFrame)
espCloseButton.Size = UDim2.new(0, isMobile and 40 or 35, 0, isMobile and 40 or 35)
espCloseButton.Position = UDim2.new(1, -(isMobile and 45 or 40), 0, 5)
espCloseButton.Text = "✕"
espCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
espCloseButton.TextColor3 = Color3.new(1, 1, 1)
espCloseButton.Font = Enum.Font.GothamBold
espCloseButton.TextSize = isMobile and 18 or 16
Instance.new("UICorner", espCloseButton).CornerRadius = UDim.new(0, 6)

espCloseButton.MouseButton1Click:Connect(function()
  local closeTween = TweenService:Create(
    espFrame,
    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    {Size = UDim2.new(0, 0, 0, 0)}
  )
  closeTween:Play()
  closeTween.Completed:Connect(function()
    espFrame.Visible = false
    espFrame.Size = UDim2.new(0, espFrameWidth, 0, espFrameHeight)
  end)
end)

-- ESP Options Toggle Buttons
local function createESPToggle(parent, text, yPos, enabled, callback)
  local toggle = Instance.new("TextButton", parent)
  toggle.Size = UDim2.new(0.85, 0, 0, isMobile and 40 or 35)
  toggle.Position = UDim2.new(0.075, 0, 0, yPos)
  toggle.Text = text .. (enabled and ": ON" or ": OFF")
  toggle.BackgroundColor3 = enabled and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(70, 70, 80)
  toggle.TextColor3 = Color3.new(1, 1, 1)
  toggle.Font = Enum.Font.GothamBold
  toggle.TextSize = isMobile and 14 or 16
  Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
  
  toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = text .. (enabled and ": ON" or ": OFF")
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(70, 70, 80)
    callback(enabled)
  end)
  
  return toggle
end

-- ESP Toggle Options
local playersToggle = createESPToggle(espFrame, "👥 Joueurs", 60, espSettings.showPlayers, function(enabled)
  espSettings.showPlayers = enabled
  if espSettings.enabled then updateESP() end
end)

local objectsToggle = createESPToggle(espFrame, "📦 Objets", 110, espSettings.showObjects, function(enabled)
  espSettings.showObjects = enabled
  if espSettings.enabled then updateESP() end
end)

local invisibleToggle = createESPToggle(espFrame, "👻 Objets Invisibles", 160, espSettings.showInvisible, function(enabled)
  espSettings.showInvisible = enabled
  if espSettings.enabled then updateESP() end
end)

local allToggle = createESPToggle(espFrame, "🌐 Tout Afficher", 210, espSettings.showAll, function(enabled)
  espSettings.showAll = enabled
  if espSettings.enabled then updateESP() end
end)

-- Radius Slider
local radiusLabel = Instance.new("TextLabel", espFrame)
radiusLabel.Size = UDim2.new(1, 0, 0, 25)
radiusLabel.Position = UDim2.new(0, 0, 0, 270)
radiusLabel.Text = "🔍 Rayon de Vision"
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextSize = 16

local radiusSliderBar = Instance.new("Frame", espFrame)
radiusSliderBar.Size = UDim2.new(0.8, 0, 0, 6)
radiusSliderBar.Position = UDim2.new(0.1, 0, 0, 305)
radiusSliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", radiusSliderBar).CornerRadius = UDim.new(0, 3)

local radiusKnob = Instance.new("Frame", radiusSliderBar)
radiusKnob.Size = UDim2.new(0, 14, 0, 20)
radiusKnob.Position = UDim2.new(0.5, -7, -0.7, 0)
radiusKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", radiusKnob).CornerRadius = UDim.new(1, 0)

local radiusValueLabel = Instance.new("TextLabel", espFrame)
radiusValueLabel.Size = UDim2.new(1, 0, 0, 25)
radiusValueLabel.Position = UDim2.new(0, 0, 0, 330)
radiusValueLabel.BackgroundTransparency = 1
radiusValueLabel.TextColor3 = Color3.new(1, 1, 1)
radiusValueLabel.TextSize = 14
radiusValueLabel.Font = Enum.Font.Gotham
radiusValueLabel.Text = "Rayon : " .. espSettings.viewRadius .. " studs"

-- Radius Slider Logic
local isDraggingRadiusSlider = false

local function updateRadiusSlider(inputX)
  local relX = math.clamp(inputX - radiusSliderBar.AbsolutePosition.X, 0, radiusSliderBar.AbsoluteSize.X)
  local percent = relX / radiusSliderBar.AbsoluteSize.X
  espSettings.viewRadius = math.floor(50 + (500 - 50) * percent + 0.5)
  radiusKnob.Position = UDim2.new(percent, -7, -0.7, 0)
  radiusValueLabel.Text = "Rayon : " .. espSettings.viewRadius .. " studs"
  if espSettings.enabled then updateESP() end
end

radiusSliderBar.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingRadiusSlider = true
    updateRadiusSlider(input.Position.X)
  end
end)

radiusSliderBar.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingRadiusSlider = false
  end
end)

UserInputService.InputChanged:Connect(function(input)
  if isDraggingRadiusSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    updateRadiusSlider(input.Position.X)
  end
end)

-- Apply ESP Button
local applyESPButton = Instance.new("TextButton", espFrame)
applyESPButton.Size = UDim2.new(0.8, 0, 0, 40)
applyESPButton.Position = UDim2.new(0.1, 0, 0, 370)
applyESPButton.Text = "✅ Activer ESP"
applyESPButton.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
applyESPButton.TextColor3 = Color3.new(1, 1, 1)
applyESPButton.Font = Enum.Font.GothamBold
applyESPButton.TextSize = 18
Instance.new("UICorner", applyESPButton).CornerRadius = UDim.new(0, 8)

-- Stop ESP Button
local stopESPButton = Instance.new("TextButton", espFrame)
stopESPButton.Size = UDim2.new(0.8, 0, 0, 40)
stopESPButton.Position = UDim2.new(0.1, 0, 0, 420)
stopESPButton.Text = "Désactiver ESP"
stopESPButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopESPButton.TextColor3 = Color3.new(1, 1, 1)
stopESPButton.Font = Enum.Font.GothamBold
stopESPButton.TextSize = 18
Instance.new("UICorner", stopESPButton).CornerRadius = UDim.new(0, 8)

-- ESP Functions
local function clearESP()
  for _, tag in pairs(espTags) do
    if tag and tag.Parent then tag:Destroy() end
  end
  espTags = {}
end

local function shouldShowObject(obj)
  local char = player.Character
  if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
  
  local distance = (obj.Position - char.HumanoidRootPart.Position).Magnitude
  if distance > espSettings.viewRadius then return false end
  
  if espSettings.showAll then return true end
  
  -- Check if it's a player
  local isPlayer = false
  local currentObj = obj
  while currentObj.Parent do
    currentObj = currentObj.Parent
    if Players:GetPlayerFromCharacter(currentObj) then
      isPlayer = true
      break
    end
  end
  
  if isPlayer and espSettings.showPlayers then return true end
  if not isPlayer and espSettings.showObjects and obj.Transparency < 1 then return true end
  if not isPlayer and espSettings.showInvisible and obj.Transparency >= 1 then return true end
  
  return false
end

local function getObjectDisplayName(obj)
  -- Get the real Roblox Studio name
  local displayName = obj.Name
  
  -- Check if it's part of a player
  local currentObj = obj
  while currentObj.Parent do
    currentObj = currentObj.Parent
    local playerFromChar = Players:GetPlayerFromCharacter(currentObj)
    if playerFromChar then
      return "👤 " .. playerFromChar.Name .. " (" .. obj.Name .. ")"
    end
  end
  
  -- For regular objects, show full hierarchy path if useful
  local parent = obj.Parent
  if parent and parent ~= workspace and parent.Name ~= "Workspace" then
    displayName = parent.Name .. " → " .. displayName
  end
  
  -- Add material info for parts
  if obj:IsA("BasePart") then
    displayName = displayName .. "\n[" .. obj.Material.Name .. "]"
    
    -- Add transparency info
    if obj.Transparency > 0 then
      displayName = displayName .. " (α:" .. math.floor(obj.Transparency * 100) .. "%)"
    end
    
    -- Add size for large objects
    if obj.Size.Magnitude > 20 then
      local sizeText = string.format("%.1f×%.1f×%.1f", obj.Size.X, obj.Size.Y, obj.Size.Z)
      displayName = displayName .. "\n📏 " .. sizeText
    end
  end
  
  return displayName
end

function updateESP()
  clearESP()
  
  if not espSettings.enabled then return end
  
  for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") and shouldShowObject(obj) then
      local billboard = Instance.new("BillboardGui")
      billboard.Adornee = obj
      billboard.Size = UDim2.new(0, 250, 0, 80)
      billboard.StudsOffset = Vector3.new(0, obj.Size.Y/2 + 2, 0)
      billboard.AlwaysOnTop = true
      billboard.LightInfluence = 0
      
      -- Background frame
      local bgFrame = Instance.new("Frame", billboard)
      bgFrame.Size = UDim2.new(1, 0, 1, 0)
      bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      bgFrame.BackgroundTransparency = 0.3
      bgFrame.BorderSizePixel = 0
      Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)
      
      local label = Instance.new("TextLabel", bgFrame)
      label.Size = UDim2.new(1, -10, 1, -10)
      label.Position = UDim2.new(0, 5, 0, 5)
      label.BackgroundTransparency = 1
      label.Text = getObjectDisplayName(obj)
      label.TextColor3 = Color3.new(1, 1, 1)
      label.TextStrokeTransparency = 0
      label.TextStrokeColor3 = Color3.new(0, 0, 0)
      label.Font = Enum.Font.GothamBold
      label.TextSize = 10
      label.TextScaled = true
      label.TextWrapped = true
      
      -- Distance indicator
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
        local distance = math.floor((obj.Position - char.HumanoidRootPart.Position).Magnitude)
        label.Text = label.Text .. "\n📍 " .. distance .. " studs"
      end
      
      billboard.Parent = obj
      table.insert(espTags, billboard)
    end
  end
end

-- ESP Button Functions
applyESPButton.MouseButton1Click:Connect(function()
  espSettings.enabled = true
  updateESP()
  espButton.Text = "🔍 ESP ON"
  espButton.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
end)

stopESPButton.MouseButton1Click:Connect(function()
  espSettings.enabled = false
  clearESP()
  espButton.Text = "ESP off"
  espButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

-- Update ESP periodically when enabled
spawn(function()
  while true do
    if espSettings.enabled then
      updateESP()
    end
    wait(2) -- Update every 2 seconds
  end
end)

-- ESP Button now opens interface
espButton.MouseButton1Click:Connect(function()
  espFrame.Visible = true
  espFrame.Size = UDim2.new(0, 0, 0, 0)
  espFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
  
  local openTween = TweenService:Create(
    espFrame,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
      Size = UDim2.new(0, espFrameWidth, 0, espFrameHeight),
      Position = UDim2.new(0.5, -espFrameWidth/2, 0.5, -espFrameHeight/2)
    }
  )
  openTween:Play()
end)

-- Make ESP frame draggable (only on PC)
if not isMobile then
  makeDraggable(espFrame)
end

-- Boost Configuration Interface
local boostFrameWidth = isMobile and math.min(screenSize.X * 0.9, 340) or 350
local boostFrameHeight = isMobile and math.min(screenSize.Y * 0.8, 450) or 400

local boostFrame = Instance.new("Frame", gui)
boostFrame.Size = UDim2.new(0, boostFrameWidth, 0, boostFrameHeight)
boostFrame.Position = UDim2.new(0.5, -boostFrameWidth/2, 0.5, -boostFrameHeight/2)
boostFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
boostFrame.BorderSizePixel = 0
boostFrame.Visible = false
Instance.new("UICorner", boostFrame).CornerRadius = UDim.new(0, isMobile and 16 or 12)

-- Boost Frame Title
local boostTitle = Instance.new("TextLabel", boostFrame)
boostTitle.Size = UDim2.new(1, 0, 0, isMobile and 50 or 40)
boostTitle.Position = UDim2.new(0, 0, 0, 0)
boostTitle.Text = "Boost ton père pd"
boostTitle.BackgroundTransparency = 1
boostTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
boostTitle.Font = Enum.Font.GothamBold
boostTitle.TextSize = isMobile and 20 or 22
boostTitle.TextScaled = isMobile

-- Close Button (improved for mobile)
local closeButtonSize = isMobile and 40 or 30
local closeButton = Instance.new("TextButton", boostFrame)
closeButton.Size = UDim2.new(0, closeButtonSize, 0, closeButtonSize)
closeButton.Position = UDim2.new(1, -closeButtonSize - 5, 0, 5)
closeButton.Text = "✕"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = isMobile and 20 or 16
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, isMobile and 8 or 4)

-- Enhanced close button animation
closeButton.MouseButton1Click:Connect(function()
  local closeTween = TweenService:Create(
    boostFrame,
    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    {Size = UDim2.new(0, 0, 0, 0)}
  )
  closeTween:Play()
  closeTween.Completed:Connect(function()
    boostFrame.Visible = false
    boostFrame.Size = UDim2.new(0, boostFrameWidth, 0, boostFrameHeight)
  end)
end)

-- Speed Slider
local speedLabel = Instance.new("TextLabel", boostFrame)
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 60)
speedLabel.Text = "Vitesse"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16

local speedSliderBar = Instance.new("Frame", boostFrame)
speedSliderBar.Size = UDim2.new(0.8, 0, 0, 6)
speedSliderBar.Position = UDim2.new(0.1, 0, 0, 90)
speedSliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", speedSliderBar).CornerRadius = UDim.new(0, 3)

local speedKnob = Instance.new("Frame", speedSliderBar)
speedKnob.Size = UDim2.new(0, 14, 0, 20)
speedKnob.Position = UDim2.new(0.2, -7, -0.7, 0)
speedKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", speedKnob).CornerRadius = UDim.new(1, 0)

local speedValueLabel = Instance.new("TextLabel", boostFrame)
speedValueLabel.Size = UDim2.new(1, 0, 0, 25)
speedValueLabel.Position = UDim2.new(0, 0, 0, 115)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.TextColor3 = Color3.new(1, 1, 1)
speedValueLabel.TextSize = 14
speedValueLabel.Font = Enum.Font.Gotham
speedValueLabel.Text = "Vitesse : 50"

-- Jump Slider
local jumpLabel = Instance.new("TextLabel", boostFrame)
jumpLabel.Size = UDim2.new(1, 0, 0, 25)
jumpLabel.Position = UDim2.new(0, 0, 0, 150)
jumpLabel.Text = "Hauteur de saut"
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 16

local jumpSliderBar = Instance.new("Frame", boostFrame)
jumpSliderBar.Size = UDim2.new(0.8, 0, 0, 6)
jumpSliderBar.Position = UDim2.new(0.1, 0, 0, 180)
jumpSliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", jumpSliderBar).CornerRadius = UDim.new(0, 3)

local jumpKnob = Instance.new("Frame", jumpSliderBar)
jumpKnob.Size = UDim2.new(0, 14, 0, 20)
jumpKnob.Position = UDim2.new(0.0, -7, -0.7, 0)
jumpKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", jumpKnob).CornerRadius = UDim.new(1, 0)

local jumpValueLabel = Instance.new("TextLabel", boostFrame)
jumpValueLabel.Size = UDim2.new(1, 0, 0, 25)
jumpValueLabel.Position = UDim2.new(0, 0, 0, 205)
jumpValueLabel.BackgroundTransparency = 1
jumpValueLabel.TextColor3 = Color3.new(1, 1, 1)
jumpValueLabel.TextSize = 14
jumpValueLabel.Font = Enum.Font.Gotham
jumpValueLabel.Text = "Hauteur : 50"

-- Infinite Jump Toggle
local infiniteJumpToggle = Instance.new("TextButton", boostFrame)
infiniteJumpToggle.Size = UDim2.new(0.8, 0, 0, 35)
infiniteJumpToggle.Position = UDim2.new(0.1, 0, 0, 240)
infiniteJumpToggle.Text = "Saut Infini: OFF"
infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
infiniteJumpToggle.TextColor3 = Color3.new(1, 1, 1)
infiniteJumpToggle.Font = Enum.Font.GothamBold
infiniteJumpToggle.TextSize = 16
Instance.new("UICorner", infiniteJumpToggle).CornerRadius = UDim.new(0, 8)

-- Apply Boost Button
local applyBoostButton = Instance.new("TextButton", boostFrame)
applyBoostButton.Size = UDim2.new(0.8, 0, 0, 40)
applyBoostButton.Position = UDim2.new(0.1, 0, 0, 290)
applyBoostButton.Text = "Activer Boost"
applyBoostButton.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
applyBoostButton.TextColor3 = Color3.new(1, 1, 1)
applyBoostButton.Font = Enum.Font.GothamBold
applyBoostButton.TextSize = 18
Instance.new("UICorner", applyBoostButton).CornerRadius = UDim.new(0, 8)

-- Stop Boost Button
local stopBoostButton = Instance.new("TextButton", boostFrame)
stopBoostButton.Size = UDim2.new(0.8, 0, 0, 40)
stopBoostButton.Position = UDim2.new(0.1, 0, 0, 340)
stopBoostButton.Text = "Désactiver Boost"
stopBoostButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBoostButton.TextColor3 = Color3.new(1, 1, 1)
stopBoostButton.Font = Enum.Font.GothamBold
stopBoostButton.TextSize = 18
Instance.new("UICorner", stopBoostButton).CornerRadius = UDim.new(0, 8)

-- Boost Variables
local currentSpeed = 50
local currentJumpPower = 50
local infiniteJumpEnabled = false
local boostActive = false
local originalSpeed = 16
local originalJumpPower = 50
local infiniteJumpConnection = nil

-- Speed Slider Logic
local isDraggingSpeedSlider = false

local function updateSpeedSlider(inputX)
  local relX = math.clamp(inputX - speedSliderBar.AbsolutePosition.X, 0, speedSliderBar.AbsoluteSize.X)
  local percent = relX / speedSliderBar.AbsoluteSize.X
  currentSpeed = math.floor(16 + (200 - 16) * percent + 0.5)
  speedKnob.Position = UDim2.new(percent, -7, -0.7, 0)
  speedValueLabel.Text = "Vitesse : " .. currentSpeed
end

speedSliderBar.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingSpeedSlider = true
    updateSpeedSlider(input.Position.X)
    input.UserInputService = nil -- Prevent event propagation
  end
end)

speedSliderBar.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingSpeedSlider = false
  end
end)

UserInputService.InputChanged:Connect(function(input)
  if isDraggingSpeedSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    updateSpeedSlider(input.Position.X)
  end
end)

-- Jump Slider Logic
local isDraggingJumpSlider = false

local function updateJumpSlider(inputX)
  local relX = math.clamp(inputX - jumpSliderBar.AbsolutePosition.X, 0, jumpSliderBar.AbsoluteSize.X)
  local percent = relX / jumpSliderBar.AbsoluteSize.X
  currentJumpPower = math.floor(50 + (200 - 50) * percent + 0.5)
  jumpKnob.Position = UDim2.new(percent, -7, -0.7, 0)
  jumpValueLabel.Text = "Hauteur : " .. currentJumpPower
end

jumpSliderBar.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingJumpSlider = true
    updateJumpSlider(input.Position.X)
    input.UserInputService = nil -- Prevent event propagation
  end
end)

jumpSliderBar.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
    isDraggingJumpSlider = false
  end
end)

UserInputService.InputChanged:Connect(function(input)
  if isDraggingJumpSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
    updateJumpSlider(input.Position.X)
  end
end)

-- Infinite Jump Toggle
infiniteJumpToggle.MouseButton1Click:Connect(function()
  infiniteJumpEnabled = not infiniteJumpEnabled
  infiniteJumpToggle.Text = infiniteJumpEnabled and " Saut Infini: ON" or " Saut Infini: OFF"
  infiniteJumpToggle.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(200, 50, 50)
end)

-- Apply Boost Function
local function applyBoost()
  local char = player.Character or player.CharacterAdded:Wait()
  local humanoid = char:FindFirstChildOfClass("Humanoid")
  if not humanoid then return end

  -- Store original values
  if not boostActive then
    originalSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
  end

  -- Apply boost
  humanoid.WalkSpeed = currentSpeed
  humanoid.JumpPower = currentJumpPower
  boostActive = true

  -- Infinite Jump
  if infiniteJumpEnabled and not infiniteJumpConnection then
    infiniteJumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
      if gameProcessed then return end
      
      -- Handle both keyboard space and mobile jump
      local shouldJump = false
      if input.KeyCode == Enum.KeyCode.Space then
        shouldJump = true
      elseif input.UserInputType == Enum.UserInputType.Touch then
        -- For mobile, detect tap in jump area (optional - you can remove this if too sensitive)
        shouldJump = true
      end
      
      if shouldJump then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if humanoidRootPart and humanoid then
          -- Use BodyVelocity for better jump control
          local bodyVelocity = Instance.new("BodyVelocity")
          bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
          bodyVelocity.Velocity = Vector3.new(0, currentJumpPower * 1.2, 0) -- Slightly higher for infinite jump
          bodyVelocity.Parent = humanoidRootPart
          
          -- Clean up after short time
          game:GetService("Debris"):AddItem(bodyVelocity, 0.3)
          
          -- Alternative method using Humanoid state
          humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
      end
    end)
  elseif not infiniteJumpEnabled and infiniteJumpConnection then
    infiniteJumpConnection:Disconnect()
    infiniteJumpConnection = nil
  end
end

-- Stop Boost Function
local function stopBoost()
  local char = player.Character or player.CharacterAdded:Wait()
  local humanoid = char:FindFirstChildOfClass("Humanoid")
  if humanoid then
    humanoid.WalkSpeed = originalSpeed
    humanoid.JumpPower = originalJumpPower
  end
  
  -- Properly clean up infinite jump
  if infiniteJumpConnection then
    infiniteJumpConnection:Disconnect()
    infiniteJumpConnection = nil
  end
  
  -- Reset infinite jump toggle
  infiniteJumpEnabled = false
  infiniteJumpToggle.Text = "🚀 Saut Infini: OFF"
  infiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
  
  boostActive = false
end

-- Button Connections
applyBoostButton.MouseButton1Click:Connect(applyBoost)
stopBoostButton.MouseButton1Click:Connect(stopBoost)

-- Make boost frame draggable (only on PC)
if not isMobile then
  makeDraggable(boostFrame)
end

-- Speed Boost Button (now opens config with animation)
speedButton.MouseButton1Click:Connect(function()
  boostFrame.Visible = true
  boostFrame.Size = UDim2.new(0, 0, 0, 0)
  boostFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
  
  local openTween = TweenService:Create(
    boostFrame,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
      Size = UDim2.new(0, boostFrameWidth, 0, boostFrameHeight),
      Position = UDim2.new(0.5, -boostFrameWidth/2, 0.5, -boostFrameHeight/2)
    }
  )
  openTween:Play()
end)

-- Init slider
task.wait(1)
updateSlider(sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * 0.5)
