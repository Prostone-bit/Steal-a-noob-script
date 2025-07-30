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
local jumpPowerBoost = 100
local isSpeedEnabled = false
local isJumpEnabled = false
local isNoClipEnabled = false
local noClipConnection = nil


-- Variables de fly
local flySpeed = 50
local isFlying = false
local bodyVelocity = nil
local bodyAngularVelocity = nil
local flyConnection = nil
local isFlyNoClipEnabled = false
local flyNoClipConnection = nil

-- Variables de troll
local isSpinAttackEnabled = false
local spinConnection = nil
local spinSpeed = 2000000 -- Vitesse ultra rapide

local isStalkerEnabled = false
local stalkerConnection = nil
local stalkerDistance = 3 -- Distance derrière le joueur
local selectedStalkerTarget = "" -- Joueur ciblé pour le stalker
local stalkerPlayerDropdown = nil
local stalkerSpeed = 1.0 -- Multiplicateur de vitesse du stalker (1.0 = normal)

-- Variables pour la liste TP joueurs
local playerListDropdown = nil
local selectedPlayerName = ""

-- Nouvelles variables de troll
local isSlowSpinEnabled = false
local slowSpinConnection = nil
local slowSpinSpeed = 157 -- 25 tours par seconde (25 * 2π)



-- Variables d'anti-fall
local isAntiFallEnabled = false
local antiFallConnection = nil

-- Variables d'anti-void amélioré
local isAntiVoidEnabled = false
local antiVoidConnection = nil
local voidThreshold = -500 -- Seuil Y en dessous duquel c'est considéré comme le vide
local lastSafePosition = nil -- Dernière position sûre sauvegardée
local safePositionTimer = 0 -- Timer pour sauvegarder les positions sûres

-- Variables anti-spin attack
local isAntiSpinEnabled = false
local antiSpinConnection = nil
local lastAntiSpinPosition = nil
local antiSpinPositionTimer = 0

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
local selectedSavedPosition = ""
local savedPositionsDropdown = nil

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

    isFlying = false,
    isSpinAttackEnabled = false,
    isAntiFallEnabled = false,
    isFpsBoostEnabled = false
  }
}

-- Variables pour le boost FPS
local isFpsBoostEnabled = false
local originalSettings = {}





-- Fonction pour sauvegarder une position
local function saveCurrentPosition(name)
  local success = false
  pcall(function()
    if not name or name == "" then 
      print("Nom de position invalide!")
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

    savedPositions[name] = {
      position = root.Position,
      cframe = root.CFrame
    }

    print("Position sauvegardée: " .. name .. " à " .. tostring(root.Position))
    success = true
  end)
  return success
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

-- Fonction pour mettre à jour la dropdown des positions sauvegardées
local function updateSavedPositionsDropdown()
  if not savedPositionsDropdown then return end

  local positionNames = {}
  for name, _ in pairs(savedPositions) do
    table.insert(positionNames, name)
  end

  if #positionNames == 0 then
    positionNames = {"Aucune position sauvegardée"}
  end

  -- Mettre à jour la dropdown
  pcall(function()
    savedPositionsDropdown:Refresh(positionNames, true)
  end)

  print("Dropdown mise à jour: " .. #positionNames .. " positions disponibles")
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

    isFlying = isFlying,
    isSpinAttackEnabled = isSpinAttackEnabled,
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
  walkSpeedBoost = settings.walkSpeed or 16
  jumpPowerBoost = settings.jumpPower or 50
  flySpeed = settings.flySpeed or 50
  spinSpeed = settings.spinSpeed or 628318



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
        -- Vérifier si le nouveau système JumpHeight existe
        local success, _ = pcall(function()
          return humanoid.JumpHeight
        end)
        
        if success then
          -- Nouveau système - utiliser JumpHeight
          humanoid.JumpHeight = jumpPowerBoost / 3.5
          print("✅ Boost de saut activé (JumpHeight): " .. (jumpPowerBoost / 3.5))
        else
          -- Ancien système - utiliser JumpPower
          humanoid.JumpPower = jumpPowerBoost
          print("✅ Boost de saut activé (JumpPower): " .. jumpPowerBoost)
        end
      else
        -- Restaurer les valeurs par défaut
        local success, _ = pcall(function()
          return humanoid.JumpHeight
        end)
        
        if success then
          humanoid.JumpHeight = 7.2 -- Valeur par défaut JumpHeight
          print("❌ Boost de saut désactivé (JumpHeight restauré)")
        else
          humanoid.JumpPower = 50 -- Valeur par défaut JumpPower
          print("❌ Boost de saut désactivé (JumpPower restauré)")
        end
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

-- Fonction d'invisibilité simple supprimée

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

-- Fonction pour NoClip ultra pendant le fly (traverse vraiment tout)
local function toggleFlyNoClip()
  local char = player.Character
  if not char then return end

  if isFlyNoClipEnabled then
    -- Activer NoClip ULTRA - traverse absolument tout
    flyNoClipConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar and isFlying then
        -- Désactiver TOUTES les collisions de TOUT le personnage
        for _, part in pairs(currentChar:GetDescendants()) do
          if part:IsA("BasePart") then
            part.CanCollide = false
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Neutraliser la physique
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
          end
        end

        -- Désactiver complètement la physique du personnage
        local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
          humanoid.PlatformStand = true
          humanoid.Sit = false
          -- Empêcher tous les états qui causent des collisions
          if humanoid:GetState() == Enum.HumanoidStateType.Physics or
             humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
             humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
          end
        end

        -- Forcer la position du root sans collision
        local root = currentChar:FindFirstChild("HumanoidRootPart")
        if root then
          root.CanCollide = false
          root.Anchored = false
          -- Supprimer toutes les forces externes qui pourraient causer des collisions
          for _, obj in pairs(root:GetChildren()) do
            if obj:IsA("Attachment") or obj:IsA("Weld") or obj:IsA("Motor6D") then
              -- Garder les attachments nécessaires mais supprimer les contraintes de collision
            end
          end
        end
      end
    end)
    print("NoClip ULTRA activé pour le fly - Traverse absolument tout!")
  else
    -- Désactiver NoClip ultra
    if flyNoClipConnection then
      flyNoClipConnection:Disconnect()
      flyNoClipConnection = nil
    end

    -- Restaurer les collisions normales (uniquement si pas en fly normal)
    if not isFlying then
      local char = player.Character
      if char then
        for _, part in pairs(char:GetDescendants()) do
          if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" then
              part.CanCollide = false -- HumanoidRootPart reste sans collision
            else
              part.CanCollide = true -- Autres parties retrouvent leurs collisions
            end
          end
        end
      end
    end
    print("NoClip ULTRA désactivé pour le fly!")
  end
end

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
      local upDirection = camera.CFrame.UpVector

      -- NOUVEAU: Faire tourner le personnage selon la direction de la caméra
      local cameraLookDirectionFlat = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit
      if cameraLookDirectionFlat.Magnitude > 0 then
        local targetCFrame = CFrame.lookAt(root.Position, root.Position + cameraLookDirectionFlat, Vector3.new(0, 1, 0))
        root.CFrame = targetCFrame
      end

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

    -- Désactiver le NoClip ultra si activé
    if isFlyNoClipEnabled then
      isFlyNoClipEnabled = false
      toggleFlyNoClip()
    end

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

-- Fonction pour le spin attack GLOBAL (affecte TOUS les joueurs)
local function toggleSpinAttack()
  local char = player.Character
  if not char then return end

  local root = char:FindFirstChild("HumanoidRootPart")
  if not root then return end

  if isSpinAttackEnabled then
    -- Spin attack ULTRA RAPIDE sans limitations
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
    bodyAngularVelocity.Parent = root

    -- Effet visuel intense
    for _, part in pairs(char:GetChildren()) do
      if part:IsA("BasePart") then
        part.Material = Enum.Material.ForceField
        part.CanCollide = false
      end
    end

    -- Maintenir la rotation ULTRA rapide et affecter TOUS les joueurs
    spinConnection = RunService.Heartbeat:Connect(function()
      if root and root.Parent then
        -- Force la rotation maximale
        local currentAngularVelocity = root:FindFirstChildOfClass("BodyAngularVelocity")
        if currentAngularVelocity then
          currentAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
          currentAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        else
          local newBodyAngularVelocity = Instance.new("BodyAngularVelocity")
          newBodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
          newBodyAngularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
          newBodyAngularVelocity.Parent = root
        end

        -- NOUVEAU: Affecter TOUS les joueurs sur le serveur (distance illimitée)
        for _, otherPlayer in pairs(Players:GetPlayers()) do
          if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local otherHumanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")

            if otherRoot and otherHumanoid then
              pcall(function()
                -- Force de spin globale ULTRA puissante
                local spinForce = otherRoot:FindFirstChild("GlobalSpinForce")
                if not spinForce then
                  spinForce = Instance.new("BodyAngularVelocity")
                  spinForce.Name = "GlobalSpinForce"
                  spinForce.Parent = otherRoot
                end

                spinForce.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                spinForce.AngularVelocity = Vector3.new(
                  math.random(-spinSpeed, spinSpeed) * 0.3,
                  spinSpeed * 0.8,
                  math.random(-spinSpeed, spinSpeed) * 0.3
                )

                -- Force de LANCEMENT spectaculaire vers le ciel
                local launchForce = otherRoot:FindFirstChild("GlobalLaunch")
                if not launchForce then
                  launchForce = Instance.new("BodyVelocity")
                  launchForce.Name = "GlobalLaunch"
                  launchForce.Parent = otherRoot
                end

                -- LANCEMENT SPECTACULAIRE - très haut dans le ciel
                local launchDirection = Vector3.new(
                  math.random(-50, 50),  -- Un peu de côté
                  math.random(200, 500), -- TRÈS HAUT
                  math.random(-50, 50)   -- Un peu de côté
                )

                launchForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                launchForce.Velocity = launchDirection

                -- Force anti-gravité temporaire pour maintenir en l'air
                local antiGravity = otherRoot:FindFirstChild("AntiGravity")
                if not antiGravity then
                  antiGravity = Instance.new("BodyPosition")
                  antiGravity.Name = "AntiGravity"
                  antiGravity.Parent = otherRoot
                end

                antiGravity.MaxForce = Vector3.new(0, math.huge, 0)
                antiGravity.Position = otherRoot.Position + Vector3.new(0, math.random(100, 300), 0)

                -- État chaotique plus fréquent
                if math.random(1, 5) == 1 then -- 20% de chance
                  otherHumanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                  task.spawn(function()
                    task.wait(0.5)
                    if otherHumanoid and otherHumanoid.Parent then
                      otherHumanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                  end)
                end

                -- Nettoyer après des délais différents pour un effet prolongé
                game:GetService("Debris"):AddItem(spinForce, 1.5)
                game:GetService("Debris"):AddItem(launchForce, 0.8)
                game:GetService("Debris"):AddItem(antiGravity, 2.0)
              end)
            end
          end
        end
      end
    end)

    print("🌪️ SPIN ATTACK GLOBAL ACTIVÉ! Affecte TOUS les joueurs sur le serveur!")
    print("💥 Vitesse: " .. spinSpeed .. " rad/s - IMPACT MONDIAL!")
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

    -- Nettoyer les effets sur tous les joueurs
    for _, otherPlayer in pairs(Players:GetPlayers()) do
      if otherPlayer ~= player and otherPlayer.Character then
        local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
        if otherRoot then
          for _, obj in pairs(otherRoot:GetChildren()) do
            if obj.Name == "GlobalSpinForce" or obj.Name == "GlobalLaunch" or obj.Name == "AntiGravity" then
              obj:Destroy()
            end
          end
        end
      end
    end

    -- Restaurer l'apparence normale
    for _, part in pairs(char:GetChildren()) do
      if part:IsA("BasePart") then
        part.Material = Enum.Material.Plastic
        if part.Name ~= "HumanoidRootPart" then
          part.CanCollide = true
        end
      end
    end

    print("Spin attack global désactivé - Tous les joueurs libérés!")
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

-- Fonction pour activer/désactiver l'anti-spin attack
local function toggleAntiSpin()
  local char = player.Character
  if not char then return end

  if isAntiSpinEnabled then
    -- Initialiser la position de sécurité
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
      lastAntiSpinPosition = root.CFrame
      antiSpinPositionTimer = 0
    end

    -- Activer l'anti-spin attack amélioré
    antiSpinConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar then
        local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
        if currentRoot then
          -- Sauvegarder régulièrement la position sûre
          if not isSpinAttackEnabled and not isSlowSpinEnabled then
            antiSpinPositionTimer = antiSpinPositionTimer + 1
            if antiSpinPositionTimer >= 15 then -- Toutes les 15 frames (environ 0.25 sec)
              lastAntiSpinPosition = currentRoot.CFrame
              antiSpinPositionTimer = 0
            end
          end

          local wasSpinAttacked = false

          -- Détecter et supprimer tous les BodyAngularVelocity non autorisés
          for _, obj in pairs(currentRoot:GetChildren()) do
            if obj:IsA("BodyAngularVelocity") then
              -- Vérifier si c'est un spin attack externe (pas le nôtre)
              if obj.Name == "GlobalSpinForce" or 
                 (not isSpinAttackEnabled and not isSlowSpinEnabled) or
                 (obj.AngularVelocity.Y > 1000 and not isSpinAttackEnabled) then

                wasSpinAttacked = true
                obj:Destroy()
                print("🛡️ Spin attack détecté et bloqué!")
              end
            end
          end

          -- Détecter et supprimer les forces de lancement non autorisées
          for _, obj in pairs(currentRoot:GetChildren()) do
            if obj:IsA("BodyVelocity") and obj.Name == "GlobalLaunch" then
              wasSpinAttacked = true
              obj:Destroy()
              print("🛡️ Force de lancement bloquée!")
            end
          end

          -- Détecter et supprimer l'anti-gravité forcée
          for _, obj in pairs(currentRoot:GetChildren()) do
            if obj:IsA("BodyPosition") and obj.Name == "AntiGravity" then
              wasSpinAttacked = true
              obj:Destroy()
              print("🛡️ Anti-gravité forcée bloquée!")
            end
          end

          -- Détecter la rotation excessive non autorisée
          local currentAngularVelocity = currentRoot.AssemblyAngularVelocity
          if not isSpinAttackEnabled and not isSlowSpinEnabled then
            if currentAngularVelocity.Magnitude > 50 then -- Rotation trop rapide détectée
              wasSpinAttacked = true
              currentRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
              print("🛡️ Rotation excessive détectée et arrêtée!")
            end
          end

          -- Si un spin attack a été détecté, téléporter à la position de sécurité
          if wasSpinAttacked and lastAntiSpinPosition then
            -- Arrêter complètement toute rotation
            currentRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

            -- Téléporter à la position de sécurité
            currentRoot.CFrame = lastAntiSpinPosition

            -- Stabiliser le personnage
            local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
              humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end

            print("🚀 Téléporté à la position de sécurité après détection de spin attack!")

            -- Mettre à jour la position de sécurité
            lastAntiSpinPosition = currentRoot.CFrame
          end

          -- Stabiliser le personnage s'il est en ragdoll à cause d'un spin attack
          local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
          if humanoid then
            local currentState = humanoid:GetState()
            if currentState == Enum.HumanoidStateType.Ragdoll or 
               currentState == Enum.HumanoidStateType.Physics then
              -- Vérifier si c'est à cause d'un spin attack externe
              if not isSpinAttackEnabled then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                print("🛡️ État ragdoll bloqué!")

                -- Si on a une position de sécurité, s'y téléporter
                if lastAntiSpinPosition then
                  currentRoot.CFrame = lastAntiSpinPosition
                  print("🚀 Retour à la position de sécurité après ragdoll!")
                end
              end
            end
          end

          -- Nettoyer la vélocité excessive non autorisée
          if currentRoot.Velocity.Y > 100 and not isFlying and not isSpinAttackEnabled then
            currentRoot.Velocity = Vector3.new(currentRoot.Velocity.X, 0, currentRoot.Velocity.Z)
            print("🛡️ Vélocité excessive bloquée!")
          end
        end
      end
    end)
    print("🛡️ Anti-spin attack AMÉLIORÉ activé!")
    print("📍 Système de sauvegarde de position activé!")
  else
    -- Désactiver l'anti-spin attack
    if antiSpinConnection then
      antiSpinConnection:Disconnect()
      antiSpinConnection = nil
    end
    lastAntiSpinPosition = nil
    antiSpinPositionTimer = 0
    print("❌ Anti-spin attack désactivé! Position de sécurité effacée.")
  end
end

-- Fonction pour activer/désactiver l'anti-void amélioré
local function toggleAntiVoid()
  local char = player.Character
  if not char then return end

  if isAntiVoidEnabled then
    -- Initialiser la première position sûre
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y > voidThreshold then
      lastSafePosition = root.CFrame
    end

    -- Activer l'anti-void amélioré
    antiVoidConnection = RunService.Heartbeat:Connect(function()
      local currentChar = player.Character
      if currentChar then
        local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
        if currentRoot then
          local currentPosition = currentRoot.Position

          -- Sauvegarder les positions sûres régulièrement
          if currentPosition.Y > voidThreshold + 50 then -- Position bien au-dessus du seuil
            safePositionTimer = safePositionTimer + 1
            if safePositionTimer >= 30 then -- Sauvegarder toutes les 30 frames (environ 0.5 sec)
              lastSafePosition = currentRoot.CFrame
              safePositionTimer = 0
            end
          end

          -- Vérifier si le joueur est tombé dans le vide
          if currentPosition.Y < voidThreshold then
            -- Méthode 1: Utiliser la dernière position sûre sauvegardée
            if lastSafePosition then
              currentRoot.CFrame = lastSafePosition + Vector3.new(0, 5, 0)
              print("🛡️ Anti-void activé! Téléporté à la dernière position sûre.")
            else
              -- Méthode 2: Chercher le spawn
              local spawnLocation = workspace:FindFirstChild("SpawnLocation")
              if spawnLocation then
                currentRoot.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
                print("🛡️ Anti-void activé! Téléporté au spawn.")
              else
                -- Méthode 3: Position de secours au centre de la map
                local safeHeight = math.max(100, math.abs(voidThreshold) + 200)
                currentRoot.CFrame = CFrame.new(0, safeHeight, 0)
                print("🛡️ Anti-void activé! Téléporté à une position de secours.")
              end
            end

            -- Réinitialiser complètement la vélocité et les forces
            currentRoot.Velocity = Vector3.new(0, 0, 0)
            currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            currentRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            -- Stabiliser le personnage
            local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
              humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- Mettre à jour la position sûre avec la nouvelle position
            lastSafePosition = currentRoot.CFrame
            print("📍 Nouvelle position sûre enregistrée: " .. tostring(currentRoot.Position))
          end
        end
      end
    end)
    print("🛡️ Anti-void AMÉLIORÉ activé!")
    print("📊 Seuil: Y < " .. voidThreshold)
    print("💾 Système de positions sûres: ACTIVÉ")
  else
    -- Désactiver l'anti-void
    if antiVoidConnection then
      antiVoidConnection:Disconnect()
      antiVoidConnection = nil
    end
    lastSafePosition = nil
    safePositionTimer = 0
    print("❌ Anti-void désactivé - Positions sûres effacées!")
  end
end













-- Variables ESP avancées
local espThickness = 2
local espTransparency = 0.3
local espAnimation = false
local espGradient = false
local espHealthBar = false
local espBoxes = false

-- Fonctions ESP améliorées
local function createPlayerHighlight(targetPlayer)
  if not targetPlayer.Character then return end

  local highlight = Instance.new("Highlight")
  highlight.Parent = targetPlayer.Character
  highlight.FillColor = espColor
  highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
  highlight.FillTransparency = espTransparency
  highlight.OutlineTransparency = 0
  highlight.Adornee = targetPlayer.Character

  -- Animation pulsante si activée
  if espAnimation then
    local connection = RunService.Heartbeat:Connect(function()
      if highlight and highlight.Parent then
        local time = tick()
        local pulse = (math.sin(time * 3) + 1) / 2
        highlight.FillTransparency = espTransparency + (pulse * 0.3)
      else
        connection:Disconnect()
      end
    end)
    espObjects[targetPlayer.Name .. "_highlight_animation"] = connection
  end

  espObjects[targetPlayer.Name .. "_highlight"] = highlight
end

local function createPlayerTracer(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
  if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

  local targetRoot = targetPlayer.Character.HumanoidRootPart
  local myRoot = player.Character.HumanoidRootPart

  -- Calculer la distance
  local distance = (targetRoot.Position - myRoot.Position).Magnitude
  if distance > tracerDistance then return end

  -- Créer le tracer (ligne) amélioré
  local beam = Instance.new("Beam")
  local attachment0 = Instance.new("Attachment")
  local attachment1 = Instance.new("Attachment")

  attachment0.Parent = myRoot
  attachment1.Parent = targetRoot

  beam.Attachment0 = attachment0
  beam.Attachment1 = attachment1

  -- Design amélioré
  if espGradient then
    local colorSequence = ColorSequence.new({
      ColorSequenceKeypoint.new(0, espColor),
      ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
      ColorSequenceKeypoint.new(1, espColor)
    })
    beam.Color = colorSequence
  else
    beam.Color = ColorSequence.new(espColor)
  end

  beam.Width0 = espThickness
  beam.Width1 = 0.2
  beam.Transparency = NumberSequence.new(espTransparency)
  beam.FaceCamera = true
  beam.Parent = workspace

  -- Animation du tracer si activée
  if espAnimation then
    local connection = RunService.Heartbeat:Connect(function()
      if beam and beam.Parent then
        local time = tick()
        local wave = (math.sin(time * 5) + 1) / 2
        beam.Width0 = espThickness + (wave * 1)
      else
        connection:Disconnect()
      end
    end)
    espObjects[targetPlayer.Name .. "_tracer_animation"] = connection
  end

  espObjects[targetPlayer.Name .. "_tracer"] = {beam, attachment0, attachment1}
end

local function createPlayerBox(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

  local character = targetPlayer.Character
  local rootPart = character.HumanoidRootPart

  -- Créer une boîte 3D autour du joueur (taille réduite)
  local boxGui = Instance.new("BillboardGui")
  boxGui.Size = UDim2.new(4, 0, 6, 0)
  boxGui.StudsOffset = Vector3.new(0, 0, 0)
  boxGui.Parent = rootPart

  local boxFrame = Instance.new("Frame")
  boxFrame.Size = UDim2.new(1, 0, 1, 0)
  boxFrame.BackgroundTransparency = 1
  boxFrame.BorderSizePixel = espThickness
  boxFrame.BorderColor3 = espColor
  boxFrame.Parent = boxGui

  local boxCorner = Instance.new("UICorner")
  boxCorner.CornerRadius = UDim.new(0, 4)
  boxCorner.Parent = boxFrame

  espObjects[targetPlayer.Name .. "_box"] = boxGui
end

local function createPlayerHealthBar(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") then return end

  local character = targetPlayer.Character
  local humanoid = character.Humanoid
  local rootPart = character:FindFirstChild("HumanoidRootPart")
  if not rootPart then return end

  -- Créer la barre de vie (taille réduite)
  local healthGui = Instance.new("BillboardGui")
  healthGui.Size = UDim2.new(0, 60, 0, 12)
  healthGui.StudsOffset = Vector3.new(0, 3, 0)
  healthGui.Parent = rootPart

  -- Background de la barre
  local healthBg = Instance.new("Frame")
  healthBg.Size = UDim2.new(1, 0, 1, 0)
  healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
  healthBg.BorderSizePixel = 1
  healthBg.BorderColor3 = Color3.fromRGB(255, 255, 255)
  healthBg.Parent = healthGui

  local healthBgCorner = Instance.new("UICorner")
  healthBgCorner.CornerRadius = UDim.new(0, 2)
  healthBgCorner.Parent = healthBg

  -- Barre de vie colorée
  local healthBar = Instance.new("Frame")
  healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0.8, 0)
  healthBar.Position = UDim2.new(0, 0, 0.1, 0)
  healthBar.BorderSizePixel = 0
  healthBar.Parent = healthBg

  local healthBarCorner = Instance.new("UICorner")
  healthBarCorner.CornerRadius = UDim.new(0, 2)
  healthBarCorner.Parent = healthBar

  -- Texte de vie
  local healthText = Instance.new("TextLabel")
  healthText.Size = UDim2.new(1, 0, 1, 0)
  healthText.BackgroundTransparency = 1
  healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
  healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
  healthText.TextStrokeTransparency = 0
  healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  healthText.TextScaled = true
  healthText.Font = Enum.Font.GothamBold
  healthText.Parent = healthBg

  -- Mise à jour en temps réel
  local healthConnection = RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.Parent and healthBar and healthBar.Parent then
      local healthPercent = humanoid.Health / humanoid.MaxHealth
      healthBar.Size = UDim2.new(healthPercent, 0, 0.8, 0)

      -- Couleur dynamique selon la vie
      if healthPercent > 0.6 then
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Vert
      elseif healthPercent > 0.3 then
        healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Jaune
      else
        healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Rouge
      end

      healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    else
      healthConnection:Disconnect()
    end
  end)

  espObjects[targetPlayer.Name .. "_health"] = healthGui
  espObjects[targetPlayer.Name .. "_health_connection"] = healthConnection
end

local function createPlayerNametag(targetPlayer)
  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return end

  local head = targetPlayer.Character.Head

  -- Créer le BillboardGui amélioré pour le nametag (taille réduite)
  local billboard = Instance.new("BillboardGui")
  billboard.Size = UDim2.new(0, 150, 0, 50)
  billboard.StudsOffset = Vector3.new(0, 2.5, 0)
  billboard.Parent = head

  -- Background stylé
  local bgFrame = Instance.new("Frame")
  bgFrame.Size = UDim2.new(1, 0, 1, 0)
  bgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
  bgFrame.BackgroundTransparency = 0.3
  bgFrame.BorderSizePixel = 0
  bgFrame.Parent = billboard

  local bgCorner = Instance.new("UICorner")
  bgCorner.CornerRadius = UDim.new(0, 4)
  bgCorner.Parent = bgFrame

  -- Nom du joueur amélioré
  local nameLabel = Instance.new("TextLabel")
  nameLabel.Size = UDim2.new(1, -10, 0.5, 0)
  nameLabel.Position = UDim2.new(0, 5, 0, 0)
  nameLabel.BackgroundTransparency = 1
  nameLabel.Text = "👤 " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
  nameLabel.TextColor3 = espColor
  nameLabel.TextStrokeTransparency = 0
  nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  nameLabel.TextScaled = true
  nameLabel.Font = Enum.Font.GothamBold
  nameLabel.Parent = bgFrame

  -- Distance avec icône
  local distanceLabel = Instance.new("TextLabel")
  distanceLabel.Size = UDim2.new(1, -10, 0.5, 0)
  distanceLabel.Position = UDim2.new(0, 5, 0.5, 0)
  distanceLabel.BackgroundTransparency = 1
  distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
  distanceLabel.TextStrokeTransparency = 0
  distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  distanceLabel.TextScaled = true
  distanceLabel.Font = Enum.Font.Gotham
  distanceLabel.Parent = bgFrame

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
    local distanceText = "📏 " .. math.floor(distance) .. " studs"

    -- Changer la couleur selon la distance
    if distance < 50 then
      distanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Rouge proche
    elseif distance < 150 then
      distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Jaune moyen
    else
      distanceLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Vert loin
    end

    distanceLabel.Text = distanceText
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

  if espBoxes then
    createPlayerBox(targetPlayer)
  end

  if espHealthBar then
    createPlayerHealthBar(targetPlayer)
  end
end

local function removeESPForPlayer(targetPlayer)
  -- Supprimer highlight
  local highlight = espObjects[targetPlayer.Name .. "_highlight"]
  if highlight then
    pcall(function() highlight:Destroy() end)
    espObjects[targetPlayer.Name .. "_highlight"] = nil
  end

  -- Supprimer animation highlight
  local highlightAnim = espObjects[targetPlayer.Name .. "_highlight_animation"]
  if highlightAnim then
    pcall(function() highlightAnim:Disconnect() end)
    espObjects[targetPlayer.Name .. "_highlight_animation"] = nil
  end

  -- Supprimer tracer
  local tracer = espObjects[targetPlayer.Name .. "_tracer"]
  if tracer then
    for _, obj in pairs(tracer) do
      pcall(function() 
        if obj and obj.Parent then
          obj:Destroy()
        end
      end)
    end
    espObjects[targetPlayer.Name .. "_tracer"] = nil
  end

  -- Supprimer animation tracer
  local tracerAnim = espObjects[targetPlayer.Name .. "_tracer_animation"]
  if tracerAnim then
    pcall(function() tracerAnim:Disconnect() end)
    espObjects[targetPlayer.Name .. "_tracer_animation"] = nil
  end

  -- Supprimer nametag
  local nametag = espObjects[targetPlayer.Name .. "_nametag"]
  if nametag then
    pcall(function() nametag:Destroy() end)
    espObjects[targetPlayer.Name .. "_nametag"] = nil
    espObjects[targetPlayer.Name .. "_distance"] = nil
  end

  -- Supprimer boîte
  local box = espObjects[targetPlayer.Name .. "_box"]
  if box then
    pcall(function() box:Destroy() end)
    espObjects[targetPlayer.Name .. "_box"] = nil
  end

  -- Supprimer barre de vie
  local health = espObjects[targetPlayer.Name .. "_health"]
  if health then
    pcall(function() health:Destroy() end)
    espObjects[targetPlayer.Name .. "_health"] = nil
  end

  local healthConnection = espObjects[targetPlayer.Name .. "_health_connection"]
  if healthConnection then
    pcall(function() healthConnection:Disconnect() end)
    espObjects[targetPlayer.Name .. "_health_connection"] = nil
  end
end

-- Fonction de nettoyage ESP ultra renforcée
local function cleanupAllESP()
  print("🧹 Nettoyage ESP complet en cours...")

  -- 1. Arrêter toutes les connexions d'abord
  for connectionName, connection in pairs(espConnections) do
    pcall(function()
      if connection and connection.Connected then
        connection:Disconnect()
      end
    end)
    espConnections[connectionName] = nil
  end

  -- 2. Supprimer tous les objets ESP connus
  for objectName, object in pairs(espObjects) do
    pcall(function()
      if typeof(object) == "table" then
        for _, obj in pairs(object) do
          if obj and obj.Parent then
            obj:Destroy()
          end
        end
      elseif object and object.Parent then
        object:Destroy()
      end
    end)
    espObjects[objectName] = nil
  end

  -- 3. Recherche et destruction en profondeur dans tout le workspace
  pcall(function()
    for _, obj in pairs(workspace:GetDescendants()) do
      if obj:IsA("Highlight") then
        obj:Destroy()
      elseif obj:IsA("Beam") then  
        -- Vérifier si c'est un beam ESP (pas les beams du jeu)
        if obj.Parent == workspace or (obj.Attachment0 and obj.Attachment1) then
          obj:Destroy()
        end
      elseif obj:IsA("Attachment") then
        -- Supprimer les attachments orphelins
        if obj.Name == "" and obj.Parent and obj.Parent.Name == "HumanoidRootPart" then
          obj:Destroy()
        end
      end
    end
  end)

  -- 4. Nettoyage des BillboardGuis dans tous les personnages
  pcall(function()
    for _, targetPlayer in pairs(Players:GetPlayers()) do
      if targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
          for _, gui in pairs(head:GetChildren()) do
            if gui:IsA("BillboardGui") then
              gui:Destroy()
            end
          end
        end
      end
    end
  end)

  -- 5. Vider complètement les tables
  espObjects = {}
  espConnections = {}

  print("✅ ESP complètement nettoyé!")
end

local function toggleESP()
  if isEspEnabled then
    -- Activer ESP
    print("🔍 Activation ESP...")

    for _, targetPlayer in pairs(Players:GetPlayers()) do
      createESPForPlayer(targetPlayer)
    end

    -- Connexion pour nouveaux joueurs
    espConnections.playerAdded = Players.PlayerAdded:Connect(function(targetPlayer)
      if targetPlayer.Character then
        task.wait(1)
        if isEspEnabled then
          createESPForPlayer(targetPlayer)
        end
      else
        targetPlayer.CharacterAdded:Connect(function()
          task.wait(1)
          if isEspEnabled then
            createESPForPlayer(targetPlayer)
          end
        end)
      end
    end)

    -- Connexion pour joueurs qui partent
    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(targetPlayer)
      removeESPForPlayer(targetPlayer)
    end)

    -- Mise à jour continue des tracers et distances
    espConnections.update = RunService.Heartbeat:Connect(function()
      if not isEspEnabled then return end -- Double vérification

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

    print("✅ ESP activé - Highlighting, tracers et nametags activés!")
  else
    -- Désactiver ESP avec nettoyage renforcé
    print("❌ Désactivation ESP...")
    cleanupAllESP()
  end
end

-- Fonction pour mettre à jour la liste des joueurs
local function updatePlayerList()
  if not playerListDropdown then return end

  local playerNames = {}
  for _, targetPlayer in pairs(Players:GetPlayers()) do
    if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
      -- S'assurer que le nom est une string valide
      local playerName = tostring(targetPlayer.Name or "")
      if playerName ~= "" and playerName ~= "nil" then
        table.insert(playerNames, playerName)
      end
    end
  end

  if #playerNames == 0 then
    table.insert(playerNames, "Aucun joueur disponible")
  end

  -- Vérifier que tous les éléments sont des strings
  for i, name in ipairs(playerNames) do
    playerNames[i] = tostring(name)
  end

  -- Mettre à jour le dropdown avec une approche plus sûre
  pcall(function()
    playerListDropdown:Refresh(playerNames, true)
  end)

  print("Liste des joueurs mise à jour: " .. #playerNames .. " joueurs trouvés")
end

-- Fonction pour se téléporter sur un joueur spécifique
local function teleportToSelectedPlayer()
  -- Nettoyer et valider le nom du joueur sélectionné
  local playerName = tostring(selectedPlayerName or "")

  if playerName == "" or playerName == "nil" or playerName == "Aucun joueur disponible" then
    print("Aucun joueur sélectionné ou nom invalide!")
    print("Nom reçu: '" .. playerName .. "'")
    return
  end

  local targetPlayer = Players:FindFirstChild(playerName)
  if not targetPlayer then
    print("Joueur '" .. playerName .. "' introuvable!")
    print("Joueurs disponibles:")
    for _, p in pairs(Players:GetPlayers()) do
      if p ~= player then
        print("- " .. p.Name)
      end
    end
    return
  end

  if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
    print("Personnage du joueur " .. tostring(selectedPlayerName) .. " introuvable!")
    return
  end

  local char = player.Character
  if not char or not char:FindFirstChild("HumanoidRootPart") then
    print("Votre personnage est introuvable!")
    return
  end

  local myRoot = char.HumanoidRootPart
  local targetRoot = targetPlayer.Character.HumanoidRootPart

  -- Créer l'effet de flou avec vérification
  local screenGui, blurEffect
  pcall(function()
    screenGui, blurEffect = createBlurEffect()
  end)

  -- Téléportation avec méthodes multiples
  print("🔄 Tentative de téléportation...")

  -- Méthode 1: CFrame direct
  local originalPos = myRoot.Position
  myRoot.CFrame = targetRoot.CFrame

  -- Vérifier si la téléportation a fonctionné
  task.wait(0.1)
  local newPos = myRoot.Position
  local distance = (newPos - targetRoot.Position).Magnitude

  print("Distance après TP CFrame:", distance, "studs")

  if distance > 10 then
    print("⚠️ CFrame a échoué, essai avec Position...")
    -- Méthode 2: Position directe
    myRoot.Position = targetRoot.Position
    task.wait(0.1)
    distance = (myRoot.Position - targetRoot.Position).Magnitude
    print("Distance après TP Position:", distance, "studs")
  end

  if distance > 10 then
    print("⚠️ Position a échoué, essai avec Tween...")
    -- Méthode 3: Tween
    local tween = TweenService:Create(
      myRoot,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad),
      {CFrame = targetRoot.CFrame}
    )
    tween:Play()
    tween.Completed:Wait()
    distance = (myRoot.Position - targetRoot.Position).Magnitude
    print("Distance après Tween:", distance, "studs")
  end

  if distance <= 10 then
    print("✅ Téléportation réussie sur " .. targetPlayer.Name .. "!")
  else
    print("❌ Téléportation échouée - distance finale:", distance, "studs")
    print("Position finale:", myRoot.Position)
    print("Position cible:", targetRoot.Position)
  end

  print("=== FIN DEBUG ===")

  -- Supprimer l'effet de flou après un délai
  task.spawn(function()
    task.wait(0.5)
    pcall(function()
      removeBlurEffect(screenGui, blurEffect)
    end)
  end)
end



-- Fonction pour trouver le joueur le plus proche
local function findClosestPlayer()
  local char = player.Character
  if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

  local myRoot = char.HumanoidRootPart
  local closestPlayer = nil
  local closestDistance = math.huge

  for _, targetPlayer in pairs(Players:GetPlayers()) do
    if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local targetRoot = targetPlayer.Character.HumanoidRootPart
      local distance = (myRoot.Position - targetRoot.Position).Magnitude

      if distance < closestDistance then
        closestDistance = distance
        closestPlayer = targetPlayer
      end
    end
  end

  return closestPlayer
end

-- Fonction pour mettre à jour la liste des joueurs pour le stalker
local function updateStalkerPlayerList()
  if not stalkerPlayerDropdown then return end

  local playerNames = {}
  for _, targetPlayer in pairs(Players:GetPlayers()) do
    if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local playerName = tostring(targetPlayer.Name or "")
      if playerName ~= "" and playerName ~= "nil" then
        table.insert(playerNames, playerName)
      end
    end
  end

  if #playerNames == 0 then
    table.insert(playerNames, "Aucun joueur disponible")
  end

  pcall(function()
    stalkerPlayerDropdown:Refresh(playerNames, true)
  end)

  print("Liste stalker mise à jour: " .. #playerNames .. " joueurs disponibles")
end

-- Fonction pour le stalker troll (suit le joueur sélectionné)
local function toggleStalker()
  if isStalkerEnabled then
    stalkerConnection = RunService.Heartbeat:Connect(function()
      local char = player.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end

      local myRoot = char.HumanoidRootPart

      -- Vérifier si un joueur est sélectionné
      if not selectedStalkerTarget or selectedStalkerTarget == "" or selectedStalkerTarget == "Aucun joueur disponible" then
        return -- Ne rien faire si aucun joueur n'est sélectionné
      end

      -- Trouver le joueur ciblé
      local targetPlayer = Players:FindFirstChild(selectedStalkerTarget)
      if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return -- Joueur introuvable ou sans personnage
      end

      local targetRoot = targetPlayer.Character.HumanoidRootPart
      local targetLookVector = targetRoot.CFrame.LookVector

      -- Position derrière le joueur avec mouvement d'avant-arrière (vitesse configurable)
      local time = tick()
      local speedMultiplier = stalkerSpeed
      local wobble = math.sin(time * (8 * speedMultiplier)) * (2 * speedMultiplier) -- Mouvement d'avant-arrière avec vitesse
      local behindOffset = -targetLookVector * (stalkerDistance + wobble)
      local finalPosition = targetRoot.Position + behindOffset

      -- Se téléporter derrière avec un petit mouvement vertical (vitesse configurable)
      local verticalOffset = math.sin(time * (6 * speedMultiplier)) * (0.5 * speedMultiplier)
      myRoot.CFrame = CFrame.lookAt(
        finalPosition + Vector3.new(0, verticalOffset, 0),
        targetRoot.Position
      )

      -- Optionnel: faire du bruit/mouvement supplémentaire (fréquence basée sur la vitesse)
      local randomChance = math.max(1, math.floor(60 / speedMultiplier)) -- Plus rapide = plus de mouvements
      if math.random(1, randomChance) == 1 then
        local randomOffset = Vector3.new(
          math.random(-2, 2) * speedMultiplier,
          math.random(-1, 1) * speedMultiplier,
          math.random(-2, 2) * speedMultiplier
        )
        myRoot.CFrame = myRoot.CFrame + randomOffset
      end
    end)

    if selectedStalkerTarget and selectedStalkerTarget ~= "" and selectedStalkerTarget ~= "Aucun joueur disponible" then
      print("🎯 Oh ouiiiiii je kiff activé! Suit le joueur: " .. selectedStalkerTarget)
    else
      print("🎯 Oh ouiiiiii je kiff activé! Sélectionnez un joueur dans la liste.")
    end
  else
    if stalkerConnection then
      stalkerConnection:Disconnect()
      stalkerConnection = nil
    end
    print("Oh ouiiiiii je kiff désactivé!")
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

-- Section Sauvegarde de Positions
local PositionSection = TeleportTab:CreateSection("Sauvegarde de Positions")

local SavePositionInput = TeleportTab:CreateInput({
   Name = "Nom de la position à sauvegarder",
   PlaceholderText = "Ex: MonSpawn, CacheSecrète...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      currentSavedPositionName = Text
   end,
})

local SavePositionButton = TeleportTab:CreateButton({
   Name = "💾 Sauvegarder position actuelle",
   Callback = function()
      if currentSavedPositionName == "" then
         print("❌ Veuillez entrer un nom pour la position!")
         return
      end

      local success = saveCurrentPosition(currentSavedPositionName)
      if success then
         print("✅ Position '" .. currentSavedPositionName .. "' sauvegardée!")
         SavePositionInput:Set("") -- Vider le champ
         currentSavedPositionName = ""
         -- Mettre à jour la dropdown
         updateSavedPositionsDropdown()
      else
         print("❌ Erreur lors de la sauvegarde!")
      end
   end,
})

-- Dropdown pour sélectionner une position sauvegardée
savedPositionsDropdown = TeleportTab:CreateDropdown({
   Name = "🗺️ Positions sauvegardées",
   Options = {"Aucune position sauvegardée"},
   CurrentOption = {"Aucune position sauvegardée"},
   MultipleOptions = false,
   Flag = "SavedPositionsDropdown",
   Callback = function(Option)
      if Option[1] and Option[1] ~= "Aucune position sauvegardée" then
         selectedSavedPosition = Option[1]
         print("Position sélectionnée: " .. selectedSavedPosition)
      end
   end,
})

local TeleportToSavedButton = TeleportTab:CreateButton({
   Name = "🚀 Se téléporter à la position sauvegardée",
   Callback = function()
      if not selectedSavedPosition or selectedSavedPosition == "Aucune position sauvegardée" then
         print("❌ Aucune position sélectionnée!")
         return
      end

      local success = teleportToSavedPosition(selectedSavedPosition)
      if success then
         print("✅ Téléporté à: " .. selectedSavedPosition)
      else
         print("❌ Échec de la téléportation!")
      end
   end,
})

local DeleteSavedButton = TeleportTab:CreateButton({
   Name = "🗑️ Supprimer position sélectionnée",
   Callback = function()
      if not selectedSavedPosition or selectedSavedPosition == "Aucune position sauvegardée" then
         print("❌ Aucune position sélectionnée!")
         return
      end

      pcall(function()
         savedPositions[selectedSavedPosition] = nil
         print("✅ Position '" .. selectedSavedPosition .. "' supprimée!")
         selectedSavedPosition = ""
         updateSavedPositionsDropdown()
      end)
   end,
})

local ClearAllSavedButton = TeleportTab:CreateButton({
   Name = "💥 Supprimer TOUTES les positions",
   Callback = function()
      savedPositions = {}
      selectedSavedPosition = ""
      updateSavedPositionsDropdown()
      print("🧹 Toutes les positions sauvegardées ont été supprimées!")
   end,
})

local PositionInfo = TeleportTab:CreateParagraph({
   Title = "📍 Système de Sauvegarde",
   Content = "💾 SAUVEGARDE: Entrez un nom et cliquez sur sauvegarder\n🗺️ TÉLÉPORTATION: Sélectionnez une position et téléportez-vous\n🗑️ SUPPRESSION: Supprimez une position ou toutes\n\n✨ Vos positions sont sauvegardées pour toute la session!"
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
   Title = "🛡️ Anti-void AMÉLIORÉ",
   Content = "🔥 SYSTÈME AVANCÉ DE PROTECTION 🔥\n\n💾 SAUVEGARDE INTELLIGENTE: Enregistre automatiquement vos positions sûres toutes les 0.5 secondes\n🚀 TÉLÉPORTATION PRIORITAIRE: Vous ramène à votre dernière position sûre plutôt qu'au spawn\n🎯 DÉTECTION PRÉCISE: Surveille en permanence votre altitude\n⚡ STABILISATION AUTO: Annule toute vélocité de chute et stabilise votre personnage\n\n📍 Positions de secours (par ordre de priorité):\n1️⃣ Dernière position sûre enregistrée\n2️⃣ Point de spawn du jeu\n3️⃣ Position de secours au centre (hauteur sûre)\n\n🛡️ Protection garantie contre toutes les chutes dans le vide!"
})



-- Onglet Boost
local BoostTab = Window:CreateTab("Boost", 4483362458)



local SpeedSlider = BoostTab:CreateSlider({
   Name = "Vitesse de marche",
   Range = {16, 1000},
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
   Range = {50, 500},
   Increment = 5,
   Suffix = "power",
   CurrentValue = 100,
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
local isInfiniteJumpEnabled = false

-- Fonction pour activer/désactiver le saut infini
local function toggleInfiniteJump()
  if isInfiniteJumpEnabled then
    -- Activer le saut infini
    if infiniteJumpConnection then
      infiniteJumpConnection:Disconnect()
    end

    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
      local char = player.Character
      if char and isInfiniteJumpEnabled then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
          humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
      end
    end)
    print("🦘 Saut infini activé!")
  else
    -- Désactiver le saut infini
    if infiniteJumpConnection then
      infiniteJumpConnection:Disconnect()
      infiniteJumpConnection = nil
    end
    print("❌ Saut infini désactivé!")
  end
end

local InfiniteJumpToggle = BoostTab:CreateToggle({
   Name = "Saut infini",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      isInfiniteJumpEnabled = Value
      toggleInfiniteJump()
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



-- Onglet Fly
local FlyTab = Window:CreateTab("Fly", 4483362458)

local FlySpeedSlider = FlyTab:CreateSlider({
   Name = "Vitesse de vol",
   Range = {10, 1000},
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

local FlyNoClipToggle = FlyTab:CreateToggle({
   Name = "NoClip ULTRA (traverse vraiment tout)",
   CurrentValue = false,
   Flag = "FlyNoClipToggle",
   Callback = function(Value)
      isFlyNoClipEnabled = Value
      toggleFlyNoClip()
   end,
})

local FlyInfo = FlyTab:CreateParagraph({
   Title = "Contrôles de vol",
   Content = "PC: WASD - Déplacement (suit la caméra)\nEspace - Monter\nShift Gauche - Descendre\n\nMobile: Joystick tactile pour bouger\nBoutons ↑↓ pour monter/descendre"
})

local FlyNoClipInfo = FlyTab:CreateParagraph({
   Title = "NoClip ULTRA",
   Content = "⚡ SUPER NOCLIP POUR LE FLY ⚡\n\nCette option désactive COMPLÈTEMENT toutes les collisions pendant le vol.\n\nVous pourrez traverser:\n• Tous les murs\n• Tous les objets\n• Le terrain\n• Les barriers invisibles\n• Littéralement TOUT!\n\n⚠️ Fonctionne uniquement pendant le fly ⚠️"
})

-- Onglet ESP
local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPToggle = ESPTab:CreateToggle({
   Name = "🔍 Activer ESP Master",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      isEspEnabled = Value
      toggleESP()
   end,
})

local ESPSection1 = ESPTab:CreateSection("Options ESP de Base")

local HighlightToggle = ESPTab:CreateToggle({
   Name = "✨ Highlighting joueurs",
   CurrentValue = false,
   Flag = "HighlightToggle",
   Callback = function(Value)
      isHighlightEnabled = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local TracersToggle = ESPTab:CreateToggle({
   Name = "📏 Tracers (lignes vers joueurs)",
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
   Name = "🏷️ Nametags 3D stylés",
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

local BoxesToggle = ESPTab:CreateToggle({
   Name = "📦 Boîtes 3D autour joueurs",
   CurrentValue = false,
   Flag = "BoxesToggle",
   Callback = function(Value)
      espBoxes = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local HealthBarToggle = ESPTab:CreateToggle({
   Name = "❤️ Barres de vie en temps réel",
   CurrentValue = false,
   Flag = "HealthBarToggle",
   Callback = function(Value)
      espHealthBar = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local DistanceToggle = ESPTab:CreateToggle({
   Name = "📍 Afficher distances",
   CurrentValue = false,
   Flag = "DistanceToggle",
   Callback = function(Value)
      isDistanceEnabled = Value
   end,
})

local ESPSection2 = ESPTab:CreateSection("Personnalisation Avancée")

local ESPAnimationToggle = ESPTab:CreateToggle({
   Name = "🌟 Animations ESP (effet pulsant)",
   CurrentValue = false,
   Flag = "ESPAnimationToggle",
   Callback = function(Value)
      espAnimation = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local ESPGradientToggle = ESPTab:CreateToggle({
   Name = "🌈 Tracers avec dégradé",
   CurrentValue = false,
   Flag = "ESPGradientToggle",
   Callback = function(Value)
      espGradient = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local ESPThicknessSlider = ESPTab:CreateSlider({
   Name = "Épaisseur des lignes",
   Range = {0.5, 10},
   Increment = 0.5,
   Suffix = "px",
   CurrentValue = 2,
   Flag = "ESPThicknessSlider",
   Callback = function(Value)
      espThickness = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local ESPTransparencySlider = ESPTab:CreateSlider({
   Name = "Transparence ESP",
   Range = {0, 0.9},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0.3,
   Flag = "ESPTransparencySlider",
   Callback = function(Value)
      espTransparency = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
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
   Name = "🎨 Couleur ESP principale",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColorPicker",
   Callback = function(Value)
      espColor = Value
      if isEspEnabled then
        toggleESP()
        toggleESP()
      end
   end,
})

local ESPInfo = ESPTab:CreateParagraph({
   Title = "🔥 ESP PREMIUM AMÉLIORÉ 🔥",
   Content = "✨ NOUVELLES FONCTIONNALITÉS ✨\n\n📦 Boîtes 3D: Cadre stylé autour des joueurs\n❤️ Barres de vie: Affichage temps réel de la santé\n🌟 Animations: Effets pulsants et dynamiques\n🌈 Dégradés: Tracers avec couleurs fluides\n🎨 Personnalisation: Épaisseur, transparence, couleurs\n🏷️ Nametags stylés: Design moderne avec fond\n\n💡 Activez ESP Master puis choisissez vos options!"
})

-- Onglet Troll
local TrollTab = Window:CreateTab("Troll", 4483362458)

local SpinSpeedSlider = TrollTab:CreateSlider({
   Name = "Vitesse de rotation ULTRA",
   Range = {1000, 5000000},
   Increment = 100000,
   Suffix = "rad/s",
   CurrentValue = 2000000,
   Flag = "SpinSpeedSlider",
   Callback = function(Value)
      spinSpeed = Value
      print("Vitesse spin: " .. Value .. " rad/s")
   end,
})

local SpinAttackToggle = TrollTab:CreateToggle({
   Name = "🌪️ SPIN ATTACK GLOBAL (Affecte TOUS les joueurs)",
   CurrentValue = false,
   Flag = "SpinAttackToggle",
   Callback = function(Value)
      isSpinAttackEnabled = Value
      toggleSpinAttack()
   end,
})

local StalkerDistanceSlider = TrollTab:CreateSlider({
   Name = "Distance stalker (derrière le joueur)",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "studs",
   CurrentValue = 3,
   Flag = "StalkerDistanceSlider",
   Callback = function(Value)
      stalkerDistance = Value
      print("Distance stalker: " .. Value .. " studs")
   end,
})

local StalkerSpeedSlider = TrollTab:CreateSlider({
   Name = "🚀 Vitesse du Oh ouiiiiii je kiff",
   Range = {0.1, 5.0},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1.0,
   Flag = "StalkerSpeedSlider",
   Callback = function(Value)
      stalkerSpeed = Value
      print("Vitesse stalker: " .. Value .. "x")
   end,
})

-- Dropdown pour sélectionner le joueur à stalker
stalkerPlayerDropdown = TrollTab:CreateDropdown({
   Name = "👤 Joueur à stalker",
   Options = {"Aucun joueur disponible"},
   CurrentOption = {"Aucun joueur disponible"},
   MultipleOptions = false,
   Flag = "StalkerPlayerDropdown",
   Callback = function(Option)
      if Option[1] and Option[1] ~= "Aucun joueur disponible" then
         selectedStalkerTarget = Option[1]
         print("Joueur stalker sélectionné: " .. selectedStalkerTarget)
      else
         selectedStalkerTarget = ""
      end
   end,
})

local UpdateStalkerListButton = TrollTab:CreateButton({
   Name = "🔄 Mettre à jour liste des joueurs",
   Callback = function()
      updateStalkerPlayerList()
   end,
})

local StalkerToggle = TrollTab:CreateToggle({
   Name = "🎯 Oh ouiiiiii je kiff (Suit le joueur sélectionné)",
   CurrentValue = false,
   Flag = "StalkerToggle",
   Callback = function(Value)
      isStalkerEnabled = Value
      toggleStalker()
   end,
})

local StalkerInfo = TrollTab:CreateParagraph({
   Title = "🎯 OH OUIIIIII JE KIFF 🎯",
   Content = "👤 OH OUIIIIII JE KIFF MODE ACTIVÉ!\n\n🎯 SÉLECTION MANUELLE: Choisissez le joueur à stalker dans la liste\n🔄 MISE À JOUR: Cliquez sur le bouton pour actualiser la liste\n🏃 Se téléporte derrière le joueur sélectionné en permanence\n↔️ Fait des mouvements d'avant-arrière dans le joueur\n🎭 Mouvement erratique pour maximiser l'agacement\n\n⚙️ CONTRÔLES:\n📏 Distance: Contrôle à quelle distance vous restez\n🚀 Vitesse: Contrôle la rapidité des mouvements (0.1x = très lent, 5x = très rapide)\n\n📝 INSTRUCTIONS:\n1️⃣ Mettez à jour la liste des joueurs\n2️⃣ Sélectionnez un joueur dans la dropdown\n3️⃣ Ajustez distance et vitesse\n4️⃣ Activez le stalker"
})

local TrollInfo = TrollTab:CreateParagraph({
   Title = "⚠️ SPIN ATTACK GLOBAL AMÉLIORÉ ⚠️",
   Content = "🔥 SPIN ATTACK SPECTACULAIRE 🔥\n\n🌪️ SPIN ATTACK GLOBAL: Affecte TOUS les joueurs sur le serveur!\n🚀 LANCEMENT VERS LE CIEL: Les joueurs sont projetés très haut dans les airs!\n🌀 ROTATION MULTI-AXES: Spin sur tous les axes pour un effet chaotique!\n⬆️ ANTI-GRAVITÉ TEMPORAIRE: Maintient les joueurs en l'air plus longtemps!\n\n💥 Effet spectaculaire garanti - les joueurs s'envolent littéralement!\n\n⚡ Ajustez la vitesse avec le slider pour contrôler l'intensité!"
})

local AntiSpinSection = TrollTab:CreateSection("Protection Anti-Spin")

local AntiSpinToggle = TrollTab:CreateToggle({
   Name = "🛡️ Anti-Spin Attack (Protection contre les autres)",
   CurrentValue = false,
   Flag = "AntiSpinToggle",
   Callback = function(Value)
      isAntiSpinEnabled = Value
      toggleAntiSpin()
   end,
})

local AntiSpinInfo = TrollTab:CreateParagraph({
   Title = "🛡️ PROTECTION ANTI-SPIN ULTRA 🛡️",
   Content = "🔒 PROTECTION TOTALE AVEC TÉLÉPORTATION 🔒\n\n🛡️ BLOQUE AUTOMATIQUEMENT:\n• Tous les BodyAngularVelocity externes\n• Forces de lancement non autorisées\n• Anti-gravité forcée par d'autres scripts\n• États ragdoll causés par les spin attacks\n• Rotations excessives détectées\n\n🚀 NOUVEAU: SYSTÈME DE TÉLÉPORTATION:\n• Sauvegarde votre position toutes les 0.25 secondes\n• Détecte instantanément les spin attacks\n• Vous téléporte automatiquement à votre dernière position sûre\n• Arrête complètement toute rotation forcée\n\n✅ PERMET VOS PROPRES EFFETS:\n• Votre spin attack personnel fonctionne toujours\n• Votre fly n'est pas affecté\n• Vos autres fonctions restent actives\n\n⚡ Protection ULTIME - impossible de vous spin attack!"
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
  end

  -- Recréer l'ESP pour le nouveau personnage
  if isEspEnabled then
    task.wait(0.5)
    toggleESP()
    toggleESP()
  end

  -- Mettre à jour la liste stalker
  task.wait(1)
  updateStalkerPlayerList()

  if isFlying then 
    isFlying = false
    FlyToggle:Set(false)
    -- Nettoyer l'interface mobile
    if flyGui then
      flyGui:Destroy()
      flyGui = nil
    end
  end
  if isFlyNoClipEnabled then
    isFlyNoClipEnabled = false
    FlyNoClipToggle:Set(false)
  end
  -- Restaurer le saut infini si il était activé
  if isInfiniteJumpEnabled then
    toggleInfiniteJump()
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

  if isStalkerEnabled then
    isStalkerEnabled = false
    StalkerToggle:Set(false)
  end
  if isAntiFallEnabled then
    isAntiFallEnabled = false
    AntiFallToggle:Set(false)
  end
  if isAntiVoidEnabled then
    isAntiVoidEnabled = false
    AntiVoidToggle:Set(false)
  end
  if isAntiSpinEnabled then
    isAntiSpinEnabled = false
    AntiSpinToggle:Set(false)
  end
  if isFpsBoostEnabled then
    isFpsBoostEnabled = false
    FpsBoostToggle:Set(false)
  end

  -- Nettoyage du bouton mobile
  if mobileToggleGui then
    mobileToggleGui:Destroy()
    mobileToggleGui = nil
    isPanelVisible = true
  end

  -- Nettoyage des connexions
  if flyNoClipConnection then
    flyNoClipConnection:Disconnect()
    flyNoClipConnection = nil
  end
  if spinConnection then
    spinConnection:Disconnect()
    spinConnection = nil
  end
  if slowSpinConnection then
    slowSpinConnection:Disconnect()
    slowSpinConnection = nil
  end

  if stalkerConnection then
    stalkerConnection:Disconnect()
    stalkerConnection = nil
  end
  if antiFallConnection then
    antiFallConnection:Disconnect()
    antiFallConnection = nil
  end
  if antiVoidConnection then
    antiVoidConnection:Disconnect()
    antiVoidConnection = nil
  end
  if antiSpinConnection then
    antiSpinConnection:Disconnect()
    antiSpinConnection = nil
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

  -- Initialiser la liste des joueurs pour le stalker
  task.wait(2)
  updateStalkerPlayerList()
end)

print("Script multifunctionnel avec Téléportation, Boost, Fly et Admin chargé!")
