

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables de téléportation
local currentDistance = 15

-- Variables de boost
local walkSpeedBoost = 16
local jumpPowerBoost = 50
local isSpeedEnabled = false
local isJumpEnabled = false
local isNoClipEnabled = false
local noClipConnection = nil
local isInvisible = false
local originalTransparencies = {}

-- Variables de fly
local flySpeed = 50
local isFlying = false
local bodyVelocity = nil
local bodyAngularVelocity = nil
local flyConnection = nil

-- Variables de troll
local isSpinAttackEnabled = false
local spinConnection = nil
local spinSpeed = 628318
local isTpToPlayersEnabled = false
local tpToPlayersConnection = nil

-- Nouvelles variables de troll
local isSlowSpinEnabled = false
local slowSpinConnection = nil
local slowSpinSpeed = 157 -- 25 tours par seconde (25 * 2π)
local isScreenShakeEnabled = false
local screenShakeConnection = nil
local isJumpSpamEnabled = false
local jumpSpamConnection = nil
local isChatSpamEnabled = false
local chatSpamConnection = nil
local isLagBombEnabled = false
local lagBombConnection = nil
local isCameraFlipEnabled = false
local cameraFlipConnection = nil



-- Variables d'anti-fall
local isAntiFallEnabled = false
local antiFallConnection = nil

-- Variables d'anti-void
local isAntiVoidEnabled = false
local antiVoidConnection = nil
local voidThreshold = -500 -- Seuil Y en dessous duquel c'est considéré comme le vide

-- Variables ESP
local isEspEnabled = false
local isTracersEnabled = false
local isNametagsEnabled = false
local isDistanceEnabled = false
local isHighlightEnabled = false
local espConnections = {}
local espObjects = {}
local tracerDistance = 1000
local espColor = Color3.fromRGB(255, 0, 0)

-- Variables de sauvegarde de positions
local savedPositions = {}
local currentSavedPositionName = ""

-- Variables de configuration
local configData = {
  autoRestoreSettings = false,
  savedSettings = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 50,
    spinSpeed = 628318,
    isSpeedEnabled = false,
    isJumpEnabled = false,
    isNoClipEnabled = false,
    isInvisible = false,
    isFlying = false,
    isSpinAttackEnabled = false,
    isTpToPlayersEnabled = false,
    isAntiFallEnabled = false,
    isFpsBoostEnabled = false
  }
}

-- Variables pour le boost FPS
local isFpsBoostEnabled = false
local originalSettings = {}





-- Fonction pour sauvegarder une position
local function saveCurrentPosition(name)
  pcall(function()
    if not name or name == "" then 
      print("Nom de position invalide!")
      return false 
    end

    local char = player.Character
    if not char then 
      print("Personnage non trouvé!")
      return false 
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then 
      print("HumanoidRootPart non trouvé!")
      return false 
    end

    savedPositions[name] = {
      position = root.Position,
      cframe = root.CFrame
    }

    print("Position sauvegardée: " .. name .. " à " .. tostring(root.Position))
    return true
  end)
  return false
end

-- Fonction pour se téléporter à une position sauvegardée
local function teleportToSavedPosition(name)
  local success = false
  pcall(function()
    if not name or name == "" then 
      print("Nom de position invalide!")
      return 
    end

    if not savedPositions[name] then 
      print("Position '" .. name .. "' non trouvée!")
      return 
    end

    local char = player.Character
    if not char then 
      print("Personnage non trouvé!")
      return 
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then 
      print("HumanoidRootPart non trouvé!")
      return 
    end

    local savedPos = savedPositions[name]
    if not savedPos or not savedPos.cframe then
      print("Données de position corrompues!")
      return
    end

    -- Créer l'effet de flou
    local screenGui, blurEffect
    pcall(function()
      screenGui, blurEffect = createBlurEffect()
    end)

    -- Téléportation directe plus fiable
    root.CFrame = savedPos.cframe
    print("Téléporté à: " .. tostring(savedPos.position))

    -- Supprimer l'effet de flou après un délai
    task.spawn(function()
      task.wait(0.5)
      pcall(function()
        removeBlurEffect(screenGui, blurEffect)
      end)
    end)

    success = true
  end)
  return success
end

-- Fonction pour sauvegarder la configuration
local function saveConfiguration()
  configData.savedSettings = {
    walkSpeed = walkSpeedBoost,
    jumpPower = jumpPowerBoost,
    flySpeed = flySpeed,
    spinSpeed = spinSpeed,
    isSpeedEnabled = isSpeedEnabled,
    isJumpEnabled = isJumpEnabled,
    isNoClipEnabled = isNoClipEnabled,
    isInvisible = isInvisible,
    isFlying = isFlying,
    isSpinAttackEnabled = isSpinAttackEnabled,
    isTpToPlayersEnabled = isTpToPlayersEnabled,
    isAntiFallEnabled = isAntiFallEnabled,
    isFpsBoostEnabled = isFpsBoostEnabled
  }
end

-- Fonction pour activer/désactiver le boost FPS
local function toggleFpsBoost()
  local lighting = game:GetService("Lighting")
  local workspace = game:GetService("Workspace")

  if isFpsBoostEnabled then
    -- Sauvegarder les paramètres originaux
    originalSettings.Brightness = lighting.Brightness
    originalSettings.GlobalShadows = lighting.GlobalShadows
    originalSettings.FogEnd = lighting.FogEnd
    originalSettings.FogStart = lighting.FogStart

    -- Appliquer les optimisations FPS
    lighting.Brightness = 2
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.FogStart = 0

    -- Optimiser le workspace (suppression des propriétés obsolètes)
    pcall(function()
      workspace.StreamingEnabled = true
    end)

    -- Réduire la qualité graphique
    pcall(function()
      for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
          obj.Enabled = false
        end
      end
    end)

    -- Optimiser les parties avec protection d'erreur
    pcall(function()
      for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
          obj.Material = Enum.Material.Plastic
          obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
          obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
          obj.Enabled = false
        end
      end
    end)

    print("Boost FPS activé - Qualité graphique réduite pour de meilleures performances!")
  else
    -- Restaurer les paramètres originaux
    if originalSettings.Brightness then
      lighting.Brightness = originalSettings.Brightness
      lighting.GlobalShadows = originalSettings.GlobalShadows
      lighting.FogEnd = originalSettings.FogEnd
      lighting.FogStart = originalSettings.FogStart
    end

    -- Réactiver les effets avec protection d'erreur
    pcall(function()
      for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
          obj.Enabled = true
        end
      end
    end)

    -- Restaurer les propriétés des objets avec protection d'erreur
    pcall(function()
      for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
          obj.Transparency = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
          obj.Enabled = true
        end
      end
    end)

    print("Boost FPS désactivé - Qualité graphique restaurée!")
  end
end

-- Fonction pour restaurer la configuration
local function restoreConfiguration()
  if not configData.autoRestoreSettings then return end

  local settings = configData.savedSettings

  -- Restaurer les valeurs des sliders
  walkSpeedBoost = settings.walkSpeed
  jumpPowerBoost = settings.jumpPower
  flySpeed = settings.flySpeed
  spinSpeed = settings.spinSpeed



  -- Attendre que l'interface soit créée
  task.wait(1)

  -- Restaurer les états des toggles
  if settings.isSpeedEnabled then
    isSpeedEnabled = true
    toggleSpeed()
  end
  if settings.isJumpEnabled then
    isJumpEnabled = true
    toggleJump()
  end
  if settings.isNoClipEnabled then
    isNoClipEnabled = true
    toggleNoClip()
  end
  if settings.isInvisible then
    isInvisible = true
    toggleInvisibility()
  end
  if settings.isAntiFallEnabled then
    isAntiFallEnabled = true
    toggleAntiFall()
  end
  if settings.isFpsBoostEnabled then
    isFpsBoostEnabled = true
    toggleFpsBoost()
  end
end

-- Fonction pour créer l'effet de flou
local function createBlurEffect()
  local playerGui = player:WaitForChild("PlayerGui")

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = "BlurEffect"
  screenGui.Parent = playerGui

  local blurFrame = Instance.new("Frame")
  blurFrame.Size = UDim2.new(1, 0, 1, 0)
  blurFrame.Position = UDim2.new(0, 0, 0, 0)
  blurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
  blurFrame.BackgroundTransparency = 0.3
  blurFrame.Parent = screenGui

  local blurEffect = Instance.new("BlurEffect")
  blurEffect.Size = 24
  blurEffect.Parent = game.Lighting

  return screenGui, blurEffect
end

-- Fonction pour supprimer l'effet de flou
local function removeBlurEffect(screenGui, blurEffect)
  if screenGui then
    screenGui:Destroy()
  end
  if blurEffect then
    blurEffect:Destroy()
  end
end

-- TP Function avec effet de flou
local function teleport()
  -- Vérifications de sécurité
  if not player or not player.Parent then 
    print("Joueur non valide")
    return 
  end

  local char = player.Character
  if not char then 
    print("Personnage non trouvé")
    return 
  end

  local root = char:FindFirstChild("HumanoidRootPart")
  local humanoid = char:FindFirstChildOfClass("Humanoid")

  if not root then 
    print("HumanoidRootPart non trouvé")
    return 
  end

  if not humanoid then 
    print("Humanoid non trouvé")
    return 
  end

  -- Créer l'effet de flou avec vérification
  local screenGui, blurEffect
  pcall(function()
    screenGui, blurEffect = createBlurEffect()
  end)

  local function safeTweenTo(offset)
    -- Vérifier que root existe toujours
    if not root or not root.Parent then return false end

    local goal = root.CFrame + offset
    local success = false

    pcall(function()
      local tween = TweenService:Create(root, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {CFrame = goal})
      tween:Play()
      tween.Completed:Wait()

      -- Vérifier si la téléportation a réussi
      if root and root.Parent then
        success = (root.Position - goal.Position).Magnitude < 5
      end
    end)

    return success
  end

  -- Vérifier que root existe toujours avant d'obtenir la direction
  if not root or not root.Parent then return end
  local dir = root.CFrame.LookVector.Unit
  local teleportSuccess = false

  for i = 1, 3 do -- Réduire les tentatives à 3
    if not root or not root.Parent or not humanoid or not humanoid.Parent then 
      break 
    end

    local down = Vector3.new(0, -8, 0)  -- Réduire la distance vers le bas
    local forward = dir * math.min(currentDistance, 50) -- Limiter la distance
    local up = Vector3.new(0, 10, 0)   -- Réduire la hauteur

    -- Changer l'état avec vérification
    pcall(function()
      if humanoid and humanoid.Parent then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
      end
    end)

    if safeTweenTo(down) and safeTweenTo(forward) and safeTweenTo(up) then
      teleportSuccess = true
      break
    end
    task.wait(0.15)
  end

  -- Supprimer l'effet de flou avec vérification
  task.wait(0.2)
  pcall(function()
    removeBlurEffect(screenGui, blurEffect)
  end)

  if teleportSuccess then
    print("Téléportation réussie!")
  else
    print("Téléportation échouée - réessayez")
  end
end

-- Fonction pour activer/désactiver la vitesse
local function toggleSpeed()
  local char = player.Character
  if char then
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
      if isSpeedEnabled then
        humanoid.WalkSpeed = walkSpeedBoost
      else
        humanoid.WalkSpeed = 16
      end
    end
  end
end

-- Fonction pour activer/désactiver le saut
local function toggleJump()
  local char = player.Character
  if char then
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
      if isJumpEnabled then
        humanoid.JumpPower = jumpPowerBoost
      else
        humanoid.JumpPower = 50
      end
    end
  end
end

-- Fonction pour activer/désactiver le NoClip amélioré
local function toggleNoClip()
  local char = player.Character
  if not char then return end

  if isNoClipEnabled then
    -- Activer NoClip amélioré avec toutes les parties
    noClipConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar then
        -- Désactiver les collisions pour toutes les parties du personnage
        for _, part in pairs(currentChar:GetDescendants()) do
          if part:IsA("BasePart") then
            part.CanCollide = false
          end
        end

        -- Gérer spécialement l'Humanoid pour éviter les problèmes de mouvement
        local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
          -- Empêcher l'Humanoid de changer d'état à cause des collisions
          if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
          end
        end
      end
    end)
    print("NoClip activé - Toutes les collisions désactivées!")
  else
    -- Désactiver NoClip
    if noClipConnection then
      noClipConnection:Disconnect()
      noClipConnection = nil
    end

    -- Restaurer les collisions normales
    local char = player.Character
    if char then
      for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
          -- Restaurer les collisions selon le type de partie
          if part.Name == "HumanoidRootPart" then
            part.CanCollide = false -- HumanoidRootPart reste sans collision
          else
            part.CanCollide = true -- Autres parties retrouvent leurs collisions
          end
        end
      end
    end
    print("NoClip désactivé - Collisions restaurées!")
  end
end

-- Fonction pour activer/désactiver l'invisibilité
local function toggleInvisibility()
  local char = player.Character
  if not char then return end

  if isInvisible then
    -- Activer l'invisibilité
    for _, part in pairs(char:GetChildren()) do
      if part:IsA("BasePart") then
        originalTransparencies[part] = part.Transparency
        part.Transparency = 1
      elseif part:IsA("Accessory") then
        local handle = part:FindFirstChild("Handle")
        if handle then
          originalTransparencies[handle] = handle.Transparency
          handle.Transparency = 1
        end
      end
    end

    -- Rendre la tête invisible aussi
    local head = char:FindFirstChild("Head")
    if head then
      for _, child in pairs(head:GetChildren()) do
        if child:IsA("Decal") then
          originalTransparencies[child] = child.Transparency
          child.Transparency = 1
        end
      end
    end
  else
    -- Désactiver l'invisibilité
    for part, transparency in pairs(originalTransparencies) do
      if part and part.Parent then
        part.Transparency = transparency
      end
    end
    originalTransparencies = {}
  end
end

-- Variables pour les contrôles mobiles
local flyGui = nil
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variables pour le bouton mobile du panel
local mobileToggleGui = nil
local isPanelVisible = true

-- Fonction pour créer le bouton mobile de toggle du panel
local function createMobileToggleButton()
  if not isMobile or mobileToggleGui then return end

  local playerGui = player:WaitForChild("PlayerGui")

  mobileToggleGui = Instance.new("ScreenGui")
  mobileToggleGui.Name = "MobileTogglePanel"
  mobileToggleGui.Parent = playerGui

  -- Bouton toggle principal
  local toggleButton = Instance.new("TextButton")
  toggleButton.Size = UDim2.new(0, 80, 0, 80)
  toggleButton.Position = UDim2.new(1, -90, 0, 10)
  toggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
  toggleButton.Text = "📱"
  toggleButton.TextSize = 32
  toggleButton.TextColor3 = Color3.new(1, 1, 1)
  toggleButton.BorderSizePixel = 0
  toggleButton.Parent = mobileToggleGui

  local toggleButtonCorner = Instance.new("UICorner")
  toggleButtonCorner.CornerRadius = UDim.new(0, 40)
  toggleButtonCorner.Parent = toggleButton

  -- Effet visuel au clic
  toggleButton.MouseButton1Click:Connect(function()
    isPanelVisible = not isPanelVisible
    
    -- Animer le bouton
    local tween = game:GetService("TweenService"):Create(
      toggleButton,
      TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
      {Size = UDim2.new(0, 70, 0, 70)}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
      local returnTween = game:GetService("TweenService"):Create(
        toggleButton,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {Size = UDim2.new(0, 80, 0, 80)}
      )
      returnTween:Play()
    end)

    -- Toggle du panel Rayfield
    if isPanelVisible then
      toggleButton.Text = "📱"
      toggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
      -- Montrer le panel Rayfield
      pcall(function()
        local rayFieldGui = playerGui:FindFirstChild("RayField")
        if rayFieldGui then
          rayFieldGui.Enabled = true
        end
      end)
      print("Panel ouvert")
    else
      toggleButton.Text = "❌"
      toggleButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
      -- Cacher le panel Rayfield
      pcall(function()
        local rayFieldGui = playerGui:FindFirstChild("RayField")
        if rayFieldGui then
          rayFieldGui.Enabled = false
        end
      end)
      print("Panel fermé")
    end
  end)

  -- Rendre le bouton déplaçable
  local dragging = false
  local dragStart = nil
  local startPos = nil

  toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      dragStart = input.Position
      startPos = toggleButton.Position
    end
  end)

  toggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
      local delta = input.Position - dragStart
      toggleButton.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
      )
    end
  end)

  toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
      dragging = false
    end
  end)

  print("Bouton mobile créé! Appuyez pour ouvrir/fermer le panel")
end

-- Fonction pour créer l'interface mobile de vol
local function createFlyMobileGui()
  if flyGui then return end

  local playerGui = player:WaitForChild("PlayerGui")

  flyGui = Instance.new("ScreenGui")
  flyGui.Name = "FlyControls"
  flyGui.Parent = playerGui

  -- Joystick de déplacement
  local moveFrame = Instance.new("Frame")
  moveFrame.Size = UDim2.new(0, 120, 0, 120)
  moveFrame.Position = UDim2.new(0, 20, 1, -140)
  moveFrame.BackgroundColor3 = Color3.new(0, 0, 0)
  moveFrame.BackgroundTransparency = 0.5
  moveFrame.BorderSizePixel = 0
  moveFrame.Parent = flyGui

  local moveFrameCorner = Instance.new("UICorner")
  moveFrameCorner.CornerRadius = UDim.new(0, 60)
  moveFrameCorner.Parent = moveFrame

  local moveStick = Instance.new("Frame")
  moveStick.Size = UDim2.new(0, 40, 0, 40)
  moveStick.Position = UDim2.new(0.5, -20, 0.5, -20)
  moveStick.BackgroundColor3 = Color3.new(1, 1, 1)
  moveStick.BorderSizePixel = 0
  moveStick.Parent = moveFrame

  local moveStickCorner = Instance.new("UICorner")
  moveStickCorner.CornerRadius = UDim.new(0, 20)
  moveStickCorner.Parent = moveStick

  -- Boutons verticaux
  local upButton = Instance.new("TextButton")
  upButton.Size = UDim2.new(0, 60, 0, 60)
  upButton.Position = UDim2.new(1, -80, 1, -200)
  upButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
  upButton.Text = "↑"
  upButton.TextSize = 24
  upButton.TextColor3 = Color3.new(1, 1, 1)
  upButton.BorderSizePixel = 0
  upButton.Parent = flyGui

  local upButtonCorner = Instance.new("UICorner")
  upButtonCorner.CornerRadius = UDim.new(0, 30)
  upButtonCorner.Parent = upButton

  local downButton = Instance.new("TextButton")
  downButton.Size = UDim2.new(0, 60, 0, 60)
  downButton.Position = UDim2.new(1, -80, 1, -130)
  downButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
  downButton.Text = "↓"
  downButton.TextSize = 24
  downButton.TextColor3 = Color3.new(1, 1, 1)
  downButton.BorderSizePixel = 0
  downButton.Parent = flyGui

  local downButtonCorner = Instance.new("UICorner")
  downButtonCorner.CornerRadius = UDim.new(0, 30)
  downButtonCorner.Parent = downButton

  return moveFrame, moveStick, upButton, downButton
end

-- Variables pour les contrôles mobiles
local mobileControls = {
  moveX = 0,
  moveY = 0,
  up = false,
  down = false
}

-- Fonction pour activer/désactiver le fly
local function toggleFly()
  local char = player.Character
  if not char then return end

  local root = char:FindFirstChild("HumanoidRootPart")
  local humanoid = char:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid then return end

  if isFlying then
    -- Soulever le personnage avant d'activer le fly pour éviter le sol
    root.CFrame = root.CFrame + Vector3.new(0, 5, 0)

    -- Activer le fly
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = root

    humanoid.PlatformStand = true

    -- Créer l'interface mobile si nécessaire
    local moveFrame, moveStick, upButton, downButton
    if isMobile then
      moveFrame, moveStick, upButton, downButton = createFlyMobileGui()

      -- Gestion du joystick
      local isDragging = false
      local startPos = moveStick.Position

      moveFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
          isDragging = true
        end
      end)

      moveFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
          isDragging = false
          moveStick.Position = startPos
          mobileControls.moveX = 0
          mobileControls.moveY = 0
        end
      end)

      moveFrame.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.Touch then
          local delta = input.Position - moveFrame.AbsolutePosition - moveFrame.AbsoluteSize/2
          local distance = math.min(delta.Magnitude, 40)
          local angle = math.atan2(delta.Y, delta.X)

          local newX = math.cos(angle) * distance
          local newY = math.sin(angle) * distance

          moveStick.Position = UDim2.new(0.5, newX, 0.5, newY)

          mobileControls.moveX = newX / 40
          mobileControls.moveY = -newY / 40 -- Inverser Y pour correspondre aux contrôles
        end
      end)

      -- Boutons haut/bas
      upButton.TouchTap:Connect(function()
        mobileControls.up = not mobileControls.up
        upButton.BackgroundColor3 = mobileControls.up and Color3.new(0, 1, 0) or Color3.new(0, 0.8, 0)
      end)

      downButton.TouchTap:Connect(function()
        mobileControls.down = not mobileControls.down
        downButton.BackgroundColor3 = mobileControls.down and Color3.new(1, 0, 0) or Color3.new(0.8, 0, 0)
      end)
    end

    flyConnection = RunService.Heartbeat:Connect(function()
      if not root or not root.Parent then return end

      local camera = workspace.CurrentCamera
      local lookDirection = camera.CFrame.LookVector
      local rightDirection = camera.CFrame.RightVector
      local upDirection = camera.CFrame.UpVector -- Utiliser l'UpVector de la caméra pour suivre son orientation

      local velocity = Vector3.new(0, 0, 0)

      if isMobile then
        -- Contrôles mobiles
        if mobileControls.moveY ~= 0 then
          -- Utiliser la direction complète de la caméra (incluant l'inclinaison)
          velocity = velocity + (lookDirection * mobileControls.moveY * flySpeed)
        end
        if mobileControls.moveX ~= 0 then
          velocity = velocity + (rightDirection * mobileControls.moveX * flySpeed)
        end
        if mobileControls.up then
          velocity = velocity + (Vector3.new(0, 1, 0) * flySpeed) -- Toujours monter verticalement
        end
        if mobileControls.down then
          velocity = velocity - (Vector3.new(0, 1, 0) * flySpeed) -- Toujours descendre verticalement
        end
      else
        -- Contrôles PC - suit parfaitement la direction de la caméra
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
          -- Utiliser la direction complète de la caméra (incluant l'inclinaison verticale)
          velocity = velocity + (lookDirection * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
          velocity = velocity - (lookDirection * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
          velocity = velocity - (rightDirection * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
          velocity = velocity + (rightDirection * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
          velocity = velocity + (Vector3.new(0, 1, 0) * flySpeed) -- Monter verticalement pur
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
          velocity = velocity - (Vector3.new(0, 1, 0) * flySpeed) -- Descendre verticalement pur
        end
      end

      -- Appliquer la vélocité
      if bodyVelocity and bodyVelocity.Parent then
        bodyVelocity.Velocity = velocity
      end
    end)
  else
    -- Désactiver le fly
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() bodyAngularVelocity = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end

    -- Supprimer l'interface mobile
    if flyGui then
      flyGui:Destroy()
      flyGui = nil
    end

    -- Réinitialiser les contrôles mobiles
    mobileControls.moveX = 0
    mobileControls.moveY = 0
    mobileControls.up = false
    mobileControls.down = false

    -- Nettoyer tous les BodyObjects
    for _, obj in pairs(root:GetChildren()) do
      if obj:IsA("BodyPosition") or obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") then
        obj:Destroy()
      end
    end

    humanoid.PlatformStand = false
  end
end

-- Fonction pour le spin attack (rotation modérée mais efficace)
local function toggleSpinAttack()
  local char = player.Character
  if not char then return end

  local root = char:FindFirstChild("HumanoidRootPart")
  if not root then return end

  if isSpinAttackEnabled then
    -- Activer le spin attack avec rotation modérée (réduite à 1000 pour être plus contrôlable)
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 1000, 0) -- Réduit de 628318 à 1000
    bodyAngularVelocity.Parent = root

    -- Stabiliser le personnage pour éviter qu'il soit propulsé
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.Position = root.Position
    bodyPosition.D = 1000 -- Amortissement
    bodyPosition.P = 10000 -- Puissance
    bodyPosition.Parent = root

    -- Activer l'effet visuel seulement
    for _, part in pairs(char:GetChildren()) do
      if part:IsA("BasePart") then
        part.Material = Enum.Material.Neon -- Effet visuel
        -- Garder CanCollide false pour éviter l'auto-propulsion
        if part.Name ~= "HumanoidRootPart" then
          part.CanCollide = false
        end
      end
    end

    -- Zone d'effet invisible pour affecter les autres joueurs
    local effectPart = Instance.new("Part")
    effectPart.Name = "SpinAttackEffect"
    effectPart.Parent = workspace
    effectPart.Anchored = true
    effectPart.CanCollide = false
    effectPart.Transparency = 1
    effectPart.Size = Vector3.new(10, 10, 10)
    effectPart.Shape = Enum.PartType.Ball

    -- Maintenir la rotation ultra-rapide et l'effet
    spinConnection = RunService.Stepped:Connect(function()
      if root and root.Parent then
        -- Maintenir la rotation
        local currentAngularVelocity = root:FindFirstChildOfClass("BodyAngularVelocity")
        if currentAngularVelocity then
          currentAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
          currentAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        else
          -- Recréer si détruit
          local newBodyAngularVelocity = Instance.new("BodyAngularVelocity")
          newBodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
          newBodyAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
          newBodyAngularVelocity.Parent = root
        end

        -- Maintenir la position stable
        local currentBodyPosition = root:FindFirstChildOfClass("BodyPosition")
        if currentBodyPosition then
          currentBodyPosition.Position = root.Position
        end

        -- Positionner la zone d'effet
        if effectPart and effectPart.Parent then
          effectPart.Position = root.Position

          -- Détecter et propulser les autres joueurs dans la zone
          for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
              local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
              if otherRoot then
                local distance = (otherRoot.Position - root.Position).Magnitude
                if distance <= 5 then -- Rayon d'effet de 5 studs
                  -- Créer une force de propulsion
                  local direction = (otherRoot.Position - root.Position).Unit
                  local forceValue = 50 -- Force de propulsion

                  -- Appliquer la force
                  local bodyVelocity = otherRoot:FindFirstChild("TempSpinForce")
                  if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "TempSpinForce"
                    bodyVelocity.Parent = otherRoot
                  end
                  bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                  bodyVelocity.Velocity = direction * forceValue

                  -- Supprimer la force après un court moment
                  game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
                end
              end
            end
          end
        end
      end
    end)
  else
    -- Désactiver le spin attack
    if spinConnection then
      spinConnection:Disconnect()
      spinConnection = nil
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
      for _, obj in pairs(root:GetChildren()) do
        if obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") then
          obj:Destroy()
        end
      end
    end

    -- Supprimer la zone d'effet
    local effectPart = workspace:FindFirstChild("SpinAttackEffect")
    if effectPart then
      effectPart:Destroy()
    end

    -- Restaurer l'apparence normale
    for _, part in pairs(char:GetChildren()) do
      if part:IsA("BasePart") then
        part.Material = Enum.Material.Plastic
        if part.Name ~= "HumanoidRootPart" then
          part.CanCollide = false
        end
      end
    end
  end
end

-- Fonction pour activer/désactiver l'anti-fall
local function toggleAntiFall()
  local char = player.Character
  if not char then return end

  local humanoid = char:FindFirstChildOfClass("Humanoid")
  if not humanoid then return end

  if isAntiFallEnabled then
    -- Activer l'anti-fall
    antiFallConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar then
        local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
        if currentHumanoid then
          local currentState = currentHumanoid:GetState()

          -- Détecter les états de chute
          if currentState == Enum.HumanoidStateType.Freefall or 
             currentState == Enum.HumanoidStateType.FallingDown or
             currentState == Enum.HumanoidStateType.Ragdoll then

            -- Remettre debout immédiatement
            currentHumanoid:ChangeState(Enum.HumanoidStateType.Running)

            -- S'assurer que le personnage est stable
            local root = currentChar:FindFirstChild("HumanoidRootPart")
            if root then
              root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
            end
          end
        end
      end
    end)
  else
    -- Désactiver l'anti-fall
    if antiFallConnection then
      antiFallConnection:Disconnect()
      antiFallConnection = nil
    end
  end
end

-- Fonction pour activer/désactiver l'anti-void
local function toggleAntiVoid()
  local char = player.Character
  if not char then return end

  if isAntiVoidEnabled then
    -- Activer l'anti-void
    antiVoidConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar then
        local root = currentChar:FindFirstChild("HumanoidRootPart")
        if root then
          -- Vérifier si le joueur est tombé sous la map
          if root.Position.Y < voidThreshold then
            -- Téléporter vers une position sûre (spawn ou dernière position connue)
            local spawnLocation = workspace:FindFirstChild("SpawnLocation")
            if spawnLocation then
              root.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
              print("Anti-void activé! Téléporté au spawn.")
            else
              -- Si pas de spawn, téléporter à une hauteur sûre
              root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
              print("Anti-void activé! Téléporté en hauteur.")
            end

            -- Réinitialiser la vélocité pour éviter de continuer à tomber
            root.Velocity = Vector3.new(0, 0, 0)
          end
        end
      end
    end)
    print("Anti-void activé! Seuil: Y < " .. voidThreshold)
  else
    -- Désactiver l'anti-void
    if antiVoidConnection then
      antiVoidConnection:Disconnect()
      antiVoidConnection = nil
    end
    print("Anti-void désactivé!")
  end
end













-- Fonctions ESP avancées
local function createPlayerHighlight(targetPlayer)
  if not targetPlayer.Character then return end

  local highlight = Instance.new("Highlight")
  highlight.Parent = targetPlayer.Character
  highlight.FillColor = espColor
  highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
  highlight.FillTransparency = 0.5
  highlight.OutlineTransparency = 0
  highlight.Adornee = targetPlayer.Character

  espObjects[targetPlayer.Name .. "_highlight"] = highlight
end

local function createPlayerTracer(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
  if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

  local camera = workspace.CurrentCamera
  local targetRoot = targetPlayer.Character.HumanoidRootPart
  local myRoot = player.Character.HumanoidRootPart

  -- Calculer la distance
  local distance = (targetRoot.Position - myRoot.Position).Magnitude
  if distance > tracerDistance then return end

  -- Créer le tracer (ligne)
  local beam = Instance.new("Beam")
  local attachment0 = Instance.new("Attachment")
  local attachment1 = Instance.new("Attachment")

  attachment0.Parent = myRoot
  attachment1.Parent = targetRoot

  beam.Attachment0 = attachment0
  beam.Attachment1 = attachment1
  beam.Color = ColorSequence.new(espColor)
  beam.Width0 = 0.5
  beam.Width1 = 0.5
  beam.Transparency = NumberSequence.new(0.3)
  beam.Parent = workspace

  espObjects[targetPlayer.Name .. "_tracer"] = {beam, attachment0, attachment1}
end

local function createPlayerNametag(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return end

  local head = targetPlayer.Character.Head

  -- Créer le BillboardGui pour le nametag
  local billboard = Instance.new("BillboardGui")
  billboard.Size = UDim2.new(0, 200, 0, 50)
  billboard.StudsOffset = Vector3.new(0, 3, 0)
  billboard.Parent = head

  -- Nom du joueur
  local nameLabel = Instance.new("TextLabel")
  nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
  nameLabel.Position = UDim2.new(0, 0, 0, 0)
  nameLabel.BackgroundTransparency = 1
  nameLabel.Text = targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
  nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
  nameLabel.TextStrokeTransparency = 0
  nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  nameLabel.TextScaled = true
  nameLabel.Font = Enum.Font.GothamBold
  nameLabel.Parent = billboard

  -- Distance (si activée)
  local distanceLabel = Instance.new("TextLabel")
  distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
  distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
  distanceLabel.BackgroundTransparency = 1
  distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
  distanceLabel.TextStrokeTransparency = 0
  distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  distanceLabel.TextScaled = true
  distanceLabel.Font = Enum.Font.Gotham
  distanceLabel.Parent = billboard

  espObjects[targetPlayer.Name .. "_nametag"] = billboard
  espObjects[targetPlayer.Name .. "_distance"] = distanceLabel
end

local function updatePlayerDistance(targetPlayer)
  if not isDistanceEnabled then return end
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
  if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

  local distanceLabel = espObjects[targetPlayer.Name .. "_distance"]
  if distanceLabel then
    local distance = (targetPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    distanceLabel.Text = math.floor(distance) .. " studs"
  end
end

local function createESPForPlayer(targetPlayer)
  if targetPlayer == player then return end

  if isHighlightEnabled then
    createPlayerHighlight(targetPlayer)
  end

  if isTracersEnabled then
    createPlayerTracer(targetPlayer)
  end

  if isNametagsEnabled then
    createPlayerNametag(targetPlayer)
  end
end

local function removeESPForPlayer(targetPlayer)
  -- Supprimer highlight
  local highlight = espObjects[targetPlayer.Name .. "_highlight"]
  if highlight then
    highlight:Destroy()
    espObjects[targetPlayer.Name .. "_highlight"] = nil
  end

  -- Supprimer tracer
  local tracer = espObjects[targetPlayer.Name .. "_tracer"]
  if tracer then
    for _, obj in pairs(tracer) do
      if obj and obj.Parent then
        obj:Destroy()
      end
    end
    espObjects[targetPlayer.Name .. "_tracer"] = nil
  end

  -- Supprimer nametag
  local nametag = espObjects[targetPlayer.Name .. "_nametag"]
  if nametag then
    nametag:Destroy()
    espObjects[targetPlayer.Name .. "_nametag"] = nil
    espObjects[targetPlayer.Name .. "_distance"] = nil
  end
end

local function toggleESP()
  if isEspEnabled then
    -- Activer ESP
    for _, targetPlayer in pairs(Players:GetPlayers()) do
      createESPForPlayer(targetPlayer)
    end

    -- Connexion pour nouveaux joueurs
    espConnections.playerAdded = Players.PlayerAdded:Connect(function(targetPlayer)
      targetPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if isEspEnabled then
          createESPForPlayer(targetPlayer)
        end
      end)
    end)

    -- Connexion pour joueurs qui partent
    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(targetPlayer)
      removeESPForPlayer(targetPlayer)
    end)

    -- Mise à jour continue des tracers et distances
    espConnections.update = RunService.Heartbeat:Connect(function()
      for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
          -- Mettre à jour les tracers
          if isTracersEnabled then
            local tracer = espObjects[targetPlayer.Name .. "_tracer"]
            if not tracer and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
              createPlayerTracer(targetPlayer)
            end
          end

          -- Mettre à jour les distances
          updatePlayerDistance(targetPlayer)
        end
      end
    end)

    print("ESP activé - Highlighting, tracers et nametags activés!")
  else
    -- Désactiver ESP
    for _, targetPlayer in pairs(Players:GetPlayers()) do
      removeESPForPlayer(targetPlayer)
    end

    -- Déconnecter tous les événements
    for _, connection in pairs(espConnections) do
      if connection then
        connection:Disconnect()
      end
    end
    espConnections = {}

    print("ESP désactivé!")
  end
end

-- Fonction pour se téléporter sur tous les joueurs actifs
local function toggleTpToPlayers()
  if isTpToPlayersEnabled then
    tpToPlayersConnection = task.spawn(function()
      while isTpToPlayersEnabled do
        local char = player.Character
        if char then
          local root = char:FindFirstChild("HumanoidRootPart")
          if root then
            -- Trouver tous les joueurs actifs
            local players = {}
            for _, targetPlayer in pairs(Players:GetPlayers()) do
              if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(players, targetPlayer)
              end
            end

            if #players > 0 then
              local randomPlayer = players[math.random(1, #players)]
              if randomPlayer and randomPlayer.Character then
                local targetRoot = randomPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                  root.CFrame = targetRoot.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                end
              end
            end
          end
        end
        task.wait(2) -- Téléportation toutes les 2 secondes
      end
    end)
  else
    if tpToPlayersConnection then
      task.cancel(tpToPlayersConnection)
      tpToPlayersConnection = nil
    end
  end
end

-- Fonction pour rotation lente contrôlée (25 tours/sec)
local function toggleSlowSpin()
  local char = player.Character
  if not char then return end

  local root = char:FindFirstChild("HumanoidRootPart")
  if not root then return end

  if isSlowSpinEnabled then
    -- Activer rotation contrôlée
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, slowSpinSpeed, 0)
    bodyAngularVelocity.Parent = root

    slowSpinConnection = RunService.Heartbeat:Connect(function()
      if root and root.Parent then
        local currentAngularVelocity = root:FindFirstChildOfClass("BodyAngularVelocity")
        if currentAngularVelocity then
          currentAngularVelocity.AngularVelocity = Vector3.new(0, slowSpinSpeed, 0)
        else
          local newBodyAngularVelocity = Instance.new("BodyAngularVelocity")
          newBodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
          newBodyAngularVelocity.AngularVelocity = Vector3.new(0, slowSpinSpeed, 0)
          newBodyAngularVelocity.Parent = root
        end
      end
    end)
    print("Rotation contrôlée activée: 25 tours/seconde")
  else
    -- Désactiver rotation
    if slowSpinConnection then
      slowSpinConnection:Disconnect()
      slowSpinConnection = nil
    end

    if root then
      for _, obj in pairs(root:GetChildren()) do
        if obj:IsA("BodyAngularVelocity") then
          obj:Destroy()
        end
      end
    end
    print("Rotation contrôlée désactivée")
  end
end

-- Fonction pour screen shake (secouer l'écran)
local function toggleScreenShake()
  if isScreenShakeEnabled then
    local camera = workspace.CurrentCamera
    screenShakeConnection = RunService.Heartbeat:Connect(function()
      if camera then
        local shakeIntensity = 2
        local randomX = (math.random() - 0.5) * shakeIntensity
        local randomY = (math.random() - 0.5) * shakeIntensity
        local randomZ = (math.random() - 0.5) * shakeIntensity
        
        camera.CFrame = camera.CFrame * CFrame.new(randomX, randomY, randomZ)
      end
    end)
    print("Screen shake activé!")
  else
    if screenShakeConnection then
      screenShakeConnection:Disconnect()
      screenShakeConnection = nil
    end
    print("Screen shake désactivé!")
  end
end

-- Fonction pour spam de saut
local function toggleJumpSpam()
  if isJumpSpamEnabled then
    jumpSpamConnection = task.spawn(function()
      while isJumpSpamEnabled do
        local char = player.Character
        if char then
          local humanoid = char:FindFirstChildOfClass("Humanoid")
          if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
          end
        end
        task.wait(0.1) -- Saut toutes les 0.1 secondes
      end
    end)
    print("Jump spam activé!")
  else
    if jumpSpamConnection then
      task.cancel(jumpSpamConnection)
      jumpSpamConnection = nil
    end
    print("Jump spam désactivé!")
  end
end

-- Fonction pour chat spam
local function toggleChatSpam()
  if isChatSpamEnabled then
    local messages = {
      "TROLL MODE ACTIVATED! 🔥",
      "Script by Pro Hacker 💀",
      "Get rekt! 😈",
      "Ez Ez Ez 🎮",
      "Skill issue? 🤔",
      "Too easy! 💪",
      "GG EZ CLAP 👏",
      "Noob detected! 🤡"
    }
    
    chatSpamConnection = task.spawn(function()
      while isChatSpamEnabled do
        local randomMessage = messages[math.random(1, #messages)]
        pcall(function()
          game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMessage, "All")
        end)
        task.wait(3) -- Message toutes les 3 secondes
      end
    end)
    print("Chat spam activé!")
  else
    if chatSpamConnection then
      task.cancel(chatSpamConnection)
      chatSpamConnection = nil
    end
    print("Chat spam désactivé!")
  end
end

-- Fonction pour lag bomb (créer du lag)
local function toggleLagBomb()
  if isLagBombEnabled then
    lagBombConnection = task.spawn(function()
      while isLagBombEnabled do
        -- Créer plusieurs parties invisibles pour lag
        for i = 1, 20 do
          local part = Instance.new("Part")
          part.Parent = workspace
          part.Anchored = true
          part.CanCollide = false
          part.Transparency = 1
          part.Size = Vector3.new(0.1, 0.1, 0.1)
          part.Position = Vector3.new(math.random(-100, 100), math.random(0, 100), math.random(-100, 100))
          
          -- Supprimer après 1 seconde
          game:GetService("Debris"):AddItem(part, 1)
        end
        task.wait(0.5)
      end
    end)
    print("Lag bomb activé! (Attention: peut affecter vos performances)")
  else
    if lagBombConnection then
      task.cancel(lagBombConnection)
      lagBombConnection = nil
    end
    print("Lag bomb désactivé!")
  end
end

-- Fonction pour flip camera
local function toggleCameraFlip()
  if isCameraFlipEnabled then
    local camera = workspace.CurrentCamera
    cameraFlipConnection = RunService.Heartbeat:Connect(function()
      if camera then
        -- Rotation aléatoire de la caméra
        local randomRoll = math.sin(tick() * 5) * 45 -- Oscillation entre -45 et 45 degrés
        camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(randomRoll))
      end
    end)
    print("Camera flip activé!")
  else
    if cameraFlipConnection then
      cameraFlipConnection:Disconnect()
      cameraFlipConnection = nil
    end
    print("Camera flip désactivé!")
  end
end

-- Interface Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Steal A Dungeon",
   LoadingTitle = "Chargement...",
   LoadingSubtitle = "by Script",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MultifunctionalScript"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Onglet Téléportation
local TeleportTab = Window:CreateTab("Téléportation", 4483362458)

local DistanceSlider = TeleportTab:CreateSlider({
   Name = "Distance de téléportation",
   Range = {5, 100},
   Increment = 1,
   Suffix = "studs",
   CurrentValue = 15,
   Flag = "DistanceSlider",
   Callback = function(Value)
      currentDistance = Value
      print("Distance de téléportation: " .. Value .. " studs")
   end,
})

local ResetDistanceButton = TeleportTab:CreateButton({
   Name = "Reset distance (15 studs)",
   Callback = function()
      currentDistance = 15
      DistanceSlider:Set(15)
      print("Distance de téléportation remise à 15 studs")
   end,
})

local TeleportButton = TeleportTab:CreateButton({
   Name = "Se téléporter",
   Callback = function()
      teleport()
      print("Téléportation effectuée! Distance: " .. currentDistance .. " studs")
   end,
})

local VoidThresholdSlider = TeleportTab:CreateSlider({
   Name = "Seuil anti-void (position Y)",
   Range = {-1000, 0},
   Increment = 50,
   Suffix = "Y",
   CurrentValue = -500,
   Flag = "VoidThresholdSlider",
   Callback = function(Value)
      voidThreshold = Value
      print("Seuil anti-void mis à jour: Y < " .. Value)
   end,
})

local AntiVoidToggle = TeleportTab:CreateToggle({
   Name = "Anti-void (éviter de tomber sous la map)",
   CurrentValue = false,
   Flag = "AntiVoidToggle",
   Callback = function(Value)
      isAntiVoidEnabled = Value
      toggleAntiVoid()
   end,
})

local AntiVoidInfo = TeleportTab:CreateParagraph({
   Title = "Info Anti-void",
   Content = "L'anti-void détecte quand vous tombez sous la map (en dessous du seuil Y) et vous téléporte automatiquement au spawn ou en sécurité."
})

-- Onglet Boost
local BoostTab = Window:CreateTab("Boost", 4483362458)

local SpeedSlider = BoostTab:CreateSlider({
   Name = "Vitesse de marche",
   Range = {16, 200},
   Increment = 1,
   Suffix = "studs/s",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      walkSpeedBoost = Value
      if isSpeedEnabled then
        toggleSpeed()
      end
   end,
})

local SpeedToggle = BoostTab:CreateToggle({
   Name = "Activer boost de vitesse",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      isSpeedEnabled = Value
      toggleSpeed()
   end,
})

local JumpSlider = BoostTab:CreateSlider({
   Name = "Puissance de saut",
   Range = {50, 300},
   Increment = 1,
   Suffix = "power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      jumpPowerBoost = Value
      if isJumpEnabled then
        toggleJump()
      end
   end,
})

local JumpToggle = BoostTab:CreateToggle({
   Name = "Activer boost de saut",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
      isJumpEnabled = Value
      toggleJump()
   end,
})

local infiniteJumpConnection = nil

local InfiniteJumpToggle = BoostTab:CreateToggle({
   Name = "Saut infini",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      if Value then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
          local char = player.Character
          if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
              humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
          end
        end)
      else
        if infiniteJumpConnection then
          infiniteJumpConnection:Disconnect()
          infiniteJumpConnection = nil
        end
      end
   end,
})

local NoClipToggle = BoostTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value)
      isNoClipEnabled = Value
      toggleNoClip()
   end,
})

local InvisibilityToggle = BoostTab:CreateToggle({
   Name = "Invisibilité",
   CurrentValue = false,
   Flag = "InvisibilityToggle",
   Callback = function(Value)
      isInvisible = Value
      toggleInvisibility()
   end,
})

-- Onglet Fly
local FlyTab = Window:CreateTab("Fly", 4483362458)

local FlySpeedSlider = FlyTab:CreateSlider({
   Name = "Vitesse de vol",
   Range = {10, 200},
   Increment = 1,
   Suffix = "studs/s",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      flySpeed = Value
   end,
})

local FlyToggle = FlyTab:CreateToggle({
   Name = "Activer le vol",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      isFlying = Value
      toggleFly()
   end,
})

local FlyInfo = FlyTab:CreateParagraph({
   Title = "Contrôles de vol",
   Content = "PC: WASD - Déplacement (suit la caméra)\nEspace - Monter\nShift Gauche - Descendre\n\nMobile: Joystick tactile pour bouger\nBoutons ↑↓ pour monter/descendre"
})

-- Onglet ESP
local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPToggle = ESPTab:CreateToggle({
   Name = "Activer ESP Master",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      isEspEnabled = Value
      toggleESP()
   end,
})

local HighlightToggle = ESPTab:CreateToggle({
   Name = "Highlighting joueurs",
   CurrentValue = false,
   Flag = "HighlightToggle",
   Callback = function(Value)
      isHighlightEnabled = Value
      if isEspEnabled then
        -- Recréer l'ESP pour appliquer les changements
        toggleESP()
        toggleESP()
      end
   end,
})

local TracersToggle = ESPTab:CreateToggle({
   Name = "Tracers (lignes vers joueurs)",
   CurrentValue = false,
   Flag = "TracersToggle",
   Callback = function(Value)
      isTracersEnabled = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local NametagsToggle = ESPTab:CreateToggle({
   Name = "Nametags 3D",
   CurrentValue = false,
   Flag = "NametagsToggle",
   Callback = function(Value)
      isNametagsEnabled = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local DistanceToggle = ESPTab:CreateToggle({
   Name = "Afficher distances",
   CurrentValue = false,
   Flag = "DistanceToggle",
   Callback = function(Value)
      isDistanceEnabled = Value
   end,
})

local TracerDistanceSlider = ESPTab:CreateSlider({
   Name = "Distance max tracers",
   Range = {100, 2000},
   Increment = 50,
   Suffix = "studs",
   CurrentValue = 1000,
   Flag = "TracerDistanceSlider",
   Callback = function(Value)
      tracerDistance = Value
   end,
})

local ESPColorPicker = ESPTab:CreateColorPicker({
   Name = "Couleur ESP",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColorPicker",
   Callback = function(Value)
      espColor = Value
      if isEspEnabled then
        -- Recréer l'ESP avec la nouvelle couleur
        toggleESP()
        toggleESP()
      end
   end,
})

local ESPInfo = ESPTab:CreateParagraph({
   Title = "Informations ESP",
   Content = "ESP Master: Active/désactive tout l'ESP.\n\nHighlighting: Contour coloré autour des joueurs.\n\nTracers: Lignes depuis vous vers les autres joueurs.\n\nNametags 3D: Affiche les noms au-dessus des joueurs.\n\nDistances: Affiche la distance en temps réel.\n\nPersonnalisez la couleur et la portée des tracers!"
})

-- Onglet Troll
local TrollTab = Window:CreateTab("Troll", 4483362458)

local SpinAttackToggle = TrollTab:CreateToggle({
   Name = "Spin Attack (Modéré)",
   CurrentValue = false,
   Flag = "SpinAttackToggle",
   Callback = function(Value)
      isSpinAttackEnabled = Value
      toggleSpinAttack()
   end,
})

local SlowSpinSpeedSlider = TrollTab:CreateSlider({
   Name = "Vitesse rotation contrôlée",
   Range = {50, 500},
   Increment = 10,
   Suffix = "rad/s",
   CurrentValue = 157,
   Flag = "SlowSpinSpeedSlider",
   Callback = function(Value)
      slowSpinSpeed = Value
   end,
})

local SlowSpinToggle = TrollTab:CreateToggle({
   Name = "Rotation Contrôlée (25 tours/sec)",
   CurrentValue = false,
   Flag = "SlowSpinToggle",
   Callback = function(Value)
      isSlowSpinEnabled = Value
      toggleSlowSpin()
   end,
})

local TpToPlayersToggle = TrollTab:CreateToggle({
   Name = "TP sur joueurs actifs",
   CurrentValue = false,
   Flag = "TpToPlayersToggle",
   Callback = function(Value)
      isTpToPlayersEnabled = Value
      toggleTpToPlayers()
   end,
})

local AntiFallToggle = TrollTab:CreateToggle({
   Name = "Anti-Fall (rester debout)",
   CurrentValue = false,
   Flag = "AntiFallToggle",
   Callback = function(Value)
      isAntiFallEnabled = Value
      toggleAntiFall()
   end,
})

local ScreenShakeToggle = TrollTab:CreateToggle({
   Name = "Screen Shake (secouer écran)",
   CurrentValue = false,
   Flag = "ScreenShakeToggle",
   Callback = function(Value)
      isScreenShakeEnabled = Value
      toggleScreenShake()
   end,
})

local JumpSpamToggle = TrollTab:CreateToggle({
   Name = "Jump Spam",
   CurrentValue = false,
   Flag = "JumpSpamToggle",
   Callback = function(Value)
      isJumpSpamEnabled = Value
      toggleJumpSpam()
   end,
})

local ChatSpamToggle = TrollTab:CreateToggle({
   Name = "Chat Spam",
   CurrentValue = false,
   Flag = "ChatSpamToggle",
   Callback = function(Value)
      isChatSpamEnabled = Value
      toggleChatSpam()
   end,
})

local CameraFlipToggle = TrollTab:CreateToggle({
   Name = "Camera Flip (rotation cam)",
   CurrentValue = false,
   Flag = "CameraFlipToggle",
   Callback = function(Value)
      isCameraFlipEnabled = Value
      toggleCameraFlip()
   end,
})

local LagBombToggle = TrollTab:CreateToggle({
   Name = "Lag Bomb ⚠️ (Dangereux)",
   CurrentValue = false,
   Flag = "LagBombToggle",
   Callback = function(Value)
      isLagBombEnabled = Value
      toggleLagBomb()
   end,
})

local TrollInfo = TrollTab:CreateParagraph({
   Title = "⚠️ SECTION BETA - TROLL ADVANCED ⚠️",
   Content = "🔧 VERSION BETA - CERTAINS BOUTONS PEUVENT NE PAS FONCTIONNER 🔧\n\n🔥 NOUVELLES OPTIONS TROLL 🔥\n\nSpin Attack: Rotation modérée mais efficace.\n\nRotation Contrôlée: Exactement 25 tours/seconde.\n\nScreen Shake: Secoue votre écran.\n\nJump Spam: Saute en continu.\n\nChat Spam: Messages automatiques.\n\nCamera Flip: Rotation de caméra.\n\nLag Bomb: Créer du lag (ATTENTION!)\n\n⚠️ ATTENTION: Cette section est en développement, certaines fonctionnalités peuvent être instables."
})



-- Onglet Paramètres
local SettingsTab = Window:CreateTab("Paramètres", 4483362458)

local AutoRestoreToggle = SettingsTab:CreateToggle({
   Name = "Auto-restaurer config au démarrage",
   CurrentValue = configData.autoRestoreSettings,
   Flag = "AutoRestoreToggle",
   Callback = function(Value)
      configData.autoRestoreSettings = Value
   end,
})

local FpsBoostToggle = SettingsTab:CreateToggle({
   Name = "Boost FPS (réduire qualité graphique)",
   CurrentValue = false,
   Flag = "FpsBoostToggle",
   Callback = function(Value)
      isFpsBoostEnabled = Value
      toggleFpsBoost()
   end,
})

local SaveConfigButton = SettingsTab:CreateButton({
   Name = "Sauvegarder configuration actuelle",
   Callback = function()
      saveConfiguration()
      print("Configuration sauvegardée!")
   end,
})

local RestoreConfigButton = SettingsTab:CreateButton({
   Name = "Restaurer configuration",
   Callback = function()
      restoreConfiguration()
      print("Configuration restaurée!")
   end,
})

local SettingsInfo = SettingsTab:CreateParagraph({
   Title = "Infos Paramètres",
   Content = "Auto-restaurer: Restaure automatiquement tous vos réglages au démarrage du script.\n\nBoost FPS: Réduit la qualité graphique pour améliorer les performances (supprime ombres, effets, particules).\n\nSauvegarder: Sauvegarde votre configuration actuelle.\n\nRestaurer: Applique la configuration sauvegardée."
})

-- Onglet Admin
local AdminTab = Window:CreateTab("Admin", 4483362458)

local AdminPanelButton = AdminTab:CreateButton({
   Name = "Admin Panel",
   Callback = function()
      local player = game.Players.LocalPlayer
      local adminGui = player.PlayerGui:FindFirstChild("AdminGui")
      if adminGui then
          adminGui.Enabled = true
          print("Admin panel activé !")
      else
          warn("AdminGui pas trouvé dans PlayerGui !")
      end
   end,
})

local LuckyInfiniteButton = AdminTab:CreateButton({
   Name = "Lucky Infinite (x2 & x3 Luck)",
   Callback = function()
      local AdminEvent = game.ReplicatedStorage.Events:FindFirstChild("Admin")
      if AdminEvent then
          AdminEvent:FireServer("x2")
          AdminEvent:FireServer("x3")
          print("Essayé d'activer x2 et x3 luck.")
      else
          warn("Admin RemoteEvent introuvable !")
      end
   end,
})

-- Auto-application des boosts lors du respawn
player.CharacterAdded:Connect(function()
  task.wait(1)

  -- Restaurer la configuration si activé
  if configData.autoRestoreSettings then
    restoreConfiguration()
  else
    -- Application normale des boosts
    if isSpeedEnabled then toggleSpeed() end
    if isJumpEnabled then toggleJump() end
    if isNoClipEnabled then toggleNoClip() end
    if isInvisible then toggleInvisibility() end
  end

  -- Recréer l'ESP pour le nouveau personnage
  if isEspEnabled then
    task.wait(0.5)
    toggleESP()
    toggleESP()
  end

  if isFlying then 
    isFlying = false
    FlyToggle:Set(false)
    -- Nettoyer l'interface mobile
    if flyGui then
      flyGui:Destroy()
      flyGui = nil
    end
  end
  -- Réinitialiser la connexion du saut infini
  if infiniteJumpConnection then
    infiniteJumpConnection:Disconnect()
    infiniteJumpConnection = nil
    InfiniteJumpToggle:Set(false)
  end
  -- Réinitialiser les fonctions de troll
  if isSpinAttackEnabled then
    isSpinAttackEnabled = false
    SpinAttackToggle:Set(false)
  end
  if isSlowSpinEnabled then
    isSlowSpinEnabled = false
    SlowSpinToggle:Set(false)
  end
  if isTpToPlayersEnabled then
    isTpToPlayersEnabled = false
    TpToPlayersToggle:Set(false)
  end
  if isAntiFallEnabled then
    isAntiFallEnabled = false
    AntiFallToggle:Set(false)
  end
  if isAntiVoidEnabled then
    isAntiVoidEnabled = false
    AntiVoidToggle:Set(false)
  end
  if isFpsBoostEnabled then
    isFpsBoostEnabled = false
    FpsBoostToggle:Set(false)
  end
  if isScreenShakeEnabled then
    isScreenShakeEnabled = false
    ScreenShakeToggle:Set(false)
  end
  if isJumpSpamEnabled then
    isJumpSpamEnabled = false
    JumpSpamToggle:Set(false)
  end
  if isChatSpamEnabled then
    isChatSpamEnabled = false
    ChatSpamToggle:Set(false)
  end
  if isLagBombEnabled then
    isLagBombEnabled = false
    LagBombToggle:Set(false)
  end
  if isCameraFlipEnabled then
    isCameraFlipEnabled = false
    CameraFlipToggle:Set(false)
  end
  -- Nettoyage du bouton mobile
  if mobileToggleGui then
    mobileToggleGui:Destroy()
    mobileToggleGui = nil
    isPanelVisible = true
  end

  -- Nettoyage des connexions
  if spinConnection then
    spinConnection:Disconnect()
    spinConnection = nil
  end
  if slowSpinConnection then
    slowSpinConnection:Disconnect()
    slowSpinConnection = nil
  end
  if tpToPlayersConnection then
    task.cancel(tpToPlayersConnection)
    tpToPlayersConnection = nil
  end
  if antiFallConnection then
    antiFallConnection:Disconnect()
    antiFallConnection = nil
  end
  if antiVoidConnection then
    antiVoidConnection:Disconnect()
    antiVoidConnection = nil
  end
  if screenShakeConnection then
    screenShakeConnection:Disconnect()
    screenShakeConnection = nil
  end
  if jumpSpamConnection then
    task.cancel(jumpSpamConnection)
    jumpSpamConnection = nil
  end
  if chatSpamConnection then
    task.cancel(chatSpamConnection)
    chatSpamConnection = nil
  end
  if lagBombConnection then
    task.cancel(lagBombConnection)
    lagBombConnection = nil
  end
  if cameraFlipConnection then
    cameraFlipConnection:Disconnect()
    cameraFlipConnection = nil
  end



end)

-- Initialiser la restauration automatique au démarrage
task.spawn(function()
  task.wait(2) -- Attendre que tout soit chargé
  if configData.autoRestoreSettings then
    restoreConfiguration()
  end
  
  -- Créer le bouton mobile si on est sur mobile
  if isMobile then
    task.wait(1) -- Attendre que l'interface soit complètement chargée
    createMobileToggleButton()
  end
-- Recréer le bouton mobile si nécessaire
  if isMobile then
    task.wait(1)
    createMobileToggleButton()
  end
end)

print("Script multifunctionnel avec Téléportation, Boost, Fly et Admin chargé!")
