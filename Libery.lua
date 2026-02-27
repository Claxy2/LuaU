local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Theme = {
        MainColor = Color3.fromRGB(20, 20, 20),
        SecondaryColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(0, 150, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        DimTextColor = Color3.fromRGB(180, 180, 180),
        BorderColor = Color3.fromRGB(40, 40, 40),
        Rounding = UDim.new(0, 6)
    },
    Windows = {},
    Flags = {},
    Toggled = true
}

-- Utility Functions
function Library:Tween(object, data, time)
    time = time or 0.3
    TweenService:Create(object, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), data):Play()
end

function Library:Create(class, properties)
    local instance = Instance.new(class)
    for i, v in pairs(properties) do
        if i ~= "Parent" then
            instance[i] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Library:MakeDraggable(gui, dragPart)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Core Notification System
function Library:Notification(title, text, duration)
    local NotificationGui = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Notifications") or (not RunService:IsStudio() and game:GetService("CoreGui"):FindFirstChild("Notifications"))
    
    if not NotificationGui then
        NotificationGui = Library:Create("ScreenGui", {
            Name = "Notifications",
            Parent = RunService:IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
            ResetOnSpawn = false
        })
        Library:Create("UIListLayout", {
            Parent = NotificationGui,
            Padding = UDim.new(0, 5),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right
        })
        Library:Create("UIPadding", {
            Parent = NotificationGui,
            PaddingBottom = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20)
        })
    end

    local Main = Library:Create("Frame", {
        Name = "Notification",
        Parent = NotificationGui,
        BackgroundColor3 = Library.Theme.MainColor,
        Size = UDim2.new(0, 250, 0, 60),
        Transparency = 1
    })
    Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Main })
    Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Main, Transparency = 1 })

    local Title = Library:Create("TextLabel", {
        Name = "Title",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.Theme.AccentColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local Content = Library:Create("TextLabel", {
        Name = "Content",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTransparency = 1
    })

    Library:Tween(Main, { Transparency = 0 })
    Library:Tween(Main:FindFirstChildOfClass("UIStroke"), { Transparency = 0 })
    Library:Tween(Title, { TextTransparency = 0 })
    Library:Tween(Content, { TextTransparency = 0 })

    task.delay(duration or 5, function()
        Library:Tween(Main, { Transparency = 1 })
        Library:Tween(Main:FindFirstChildOfClass("UIStroke"), { Transparency = 1 })
        Library:Tween(Title, { TextTransparency = 1 })
        Library:Tween(Content, { TextTransparency = 1 })
        task.wait(0.3)
        Main:Destroy()
    end)
end

-- CreateWindow
function Library:CreateWindow(name)
    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    local ScreenGui = Library:Create("ScreenGui", {
        Name = "PrivateUI",
        Parent = RunService:IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
        ResetOnSpawn = false
    })

    local Main = Library:Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.MainColor,
        Position = UDim2.new(0.5, -250, 0.5, -175),
        Size = UDim2.new(0, 500, 0, 350),
        ClipsDescendants = true
    })
    Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Main })
    Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Main })

    local Header = Library:Create("Frame", {
        Name = "Header",
        Parent = Main,
        BackgroundColor3 = Library.Theme.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 35)
    })
    Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Header })
    
    local Title = Library:Create("TextLabel", {
        Name = "Title",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseBtn = Library:Create("TextButton", {
        Name = "Close",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Library.Theme.DimTextColor,
        TextSize = 14
    })

    CloseBtn.MouseEnter:Connect(function() Library:Tween(CloseBtn, { TextColor3 = Color3.fromRGB(255, 100, 100) }) end)
    CloseBtn.MouseLeave:Connect(function() Library:Tween(CloseBtn, { TextColor3 = Library.Theme.DimTextColor }) end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Sidebar = Library:Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = Library.Theme.SecondaryColor,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 140, 1, -35)
    })
    Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Sidebar })

    local TabContainer = Library:Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 1, -10),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Library:Create("UIListLayout", { Padding = UDim.new(0, 5), Parent = TabContainer })

    local ContentArea = Library:Create("Frame", {
        Name = "ContentArea",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 35),
        Size = UDim2.new(1, -140, 1, -35)
    })

    Library:MakeDraggable(Main, Header)

    function Window:CreateTab(tabName)
        local Tab = {
            Sections = {}
        }
        
        local TabButton = Library:Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Library.Theme.MainColor,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Library.Theme.DimTextColor,
            TextSize = 13,
            AutoButtonColor = false
        })
        Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = TabButton })

        local Container = Library:Create("ScrollingFrame", {
            Name = tabName .. "_Container",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        Library:Create("UIListLayout", { Padding = UDim.new(0, 8), Parent = Container, HorizontalAlignment = Enum.HorizontalAlignment.Center })
        Library:Create("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = Container })

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Container.Visible = false
                Library:Tween(t.Button, { TextColor3 = Library.Theme.DimTextColor, BackgroundColor3 = Library.Theme.MainColor })
            end
            Container.Visible = true
            Library:Tween(TabButton, { TextColor3 = Library.Theme.TextColor, BackgroundColor3 = Library.Theme.AccentColor })
        end)

        Tab.Button = TabButton
        Tab.Container = Container
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Container.Visible = true
            TabButton.TextColor3 = Library.Theme.TextColor
            TabButton.BackgroundColor3 = Library.Theme.AccentColor
        end

        function Tab:CreateSection(sectionName)
            local Section = {}
            
            local SectionLabel = Library:Create("TextLabel", {
                Name = sectionName .. "_Label",
                Parent = Container,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName:upper(),
                TextColor3 = Library.Theme.AccentColor,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            function Section:AddButton(text, callback)
                local Button = Library:Create("TextButton", {
                    Name = text,
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.SecondaryColor,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Button })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Button })

                return Button
            end

            function Section:AddToggle(text, default, callback)
                local Toggled = default or false
                local Toggle = {}

                local Button = Library:Create("TextButton", {
                    Name = text,
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.SecondaryColor,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Button })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Button })

                local Label = Library:Create("TextLabel", {
                    Name = "Label",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ToggleFrame = Library:Create("Frame", {
                    Name = "ToggleFrame",
                    Parent = Button,
                    BackgroundColor3 = Library.Theme.MainColor,
                    Position = UDim2.new(1, -40, 0.5, -9),
                    Size = UDim2.new(0, 32, 0, 18)
                })
                Library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleFrame })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = ToggleFrame })

                local Knob = Library:Create("Frame", {
                    Name = "Knob",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Theme.TextColor,
                    Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14)
                })
                Library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

                if Toggled then ToggleFrame.BackgroundColor3 = Library.Theme.AccentColor end

                Button.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Library:Tween(Knob, { Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
                    Library:Tween(ToggleFrame, { BackgroundColor3 = Toggled and Library.Theme.AccentColor or Library.Theme.MainColor }, 0.2)
                    callback(Toggled)
                end)

                function Toggle:Set(state)
                    Toggled = state
                    Library:Tween(Knob, { Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
                    Library:Tween(ToggleFrame, { BackgroundColor3 = Toggled and Library.Theme.AccentColor or Library.Theme.MainColor }, 0.2)
                    callback(Toggled)
                end

                return Toggle
            end

            function Section:AddSlider(text, min, max, default, callback)
                local Value = default or min
                local Slider = {}

                local Main = Library:Create("Frame", {
                    Name = text,
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.SecondaryColor,
                    Size = UDim2.new(0.9, 0, 0, 45)
                })
                Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Main })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Main })

                local Label = Library:Create("TextLabel", {
                    Name = "Label",
                    Parent = Main,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Library:Create("TextLabel", {
                    Name = "ValueLabel",
                    Parent = Main,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(Value),
                    TextColor3 = Library.Theme.DimTextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBar = Library:Create("Frame", {
                    Name = "SliderBar",
                    Parent = Main,
                    BackgroundColor3 = Library.Theme.MainColor,
                    Position = UDim2.new(0, 10, 1, -15),
                    Size = UDim2.new(1, -20, 0, 6)
                })
                Library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })

                local Fill = Library:Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBar,
                    BackgroundColor3 = Library.Theme.AccentColor,
                    Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                })
                Library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

                local function update(input)
                    local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Value = math.floor(min + (max - min) * percent)
                    ValueLabel.Text = tostring(Value)
                    Library:Tween(Fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.1)
                    callback(Value)
                end

                local dragging = false
                Main.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)

                return Slider
            end

            function Section:AddDropdown(text, list, default, callback)
                local Dropdown = {
                    Open = false,
                    List = list or {}
                }
                
                local Main = Library:Create("Frame", {
                    Name = text,
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.SecondaryColor,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    ClipsDescendants = true
                })
                Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Main })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Main })

                local Button = Library:Create("TextButton", {
                    Name = "Button",
                    Parent = Main,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })

                local Label = Library:Create("TextLabel", {
                    Name = "Label",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text .. ": " .. (default or "None"),
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Icon = Library:Create("TextLabel", {
                    Name = "Icon",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "+",
                    TextColor3 = Library.Theme.DimTextColor,
                    TextSize = 16
                })

                local ListContainer = Library:Create("Frame", {
                    Name = "List",
                    Parent = Main,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                Library:Create("UIListLayout", { Padding = UDim.new(0, 2), Parent = ListContainer })

                local function refresh()
                    for _, v in pairs(ListContainer:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end

                    for _, v in pairs(Dropdown.List) do
                        local Item = Library:Create("TextButton", {
                            Name = v,
                            Parent = ListContainer,
                            BackgroundColor3 = Library.Theme.MainColor,
                            Size = UDim2.new(1, 0, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = v,
                            TextColor3 = Library.Theme.DimTextColor,
                            TextSize = 12,
                            AutoButtonColor = false
                        })
                        Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Item })

                        Item.MouseButton1Click:Connect(function()
                            Label.Text = text .. ": " .. v
                            callback(v)
                            Dropdown.Open = false
                            Library:Tween(Main, { Size = UDim2.new(0.9, 0, 0, 35) })
                            Icon.Text = "+"
                        end)
                    end
                end

                Button.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    refresh()
                    local targetSize = Dropdown.Open and (35 + (#Dropdown.List * 27)) or 35
                    Library:Tween(Main, { Size = UDim2.new(0.9, 0, 0, targetSize) })
                    Icon.Text = Dropdown.Open and "-" or "+"
                end)

                return Dropdown
            end

            function Section:AddTextBox(text, placeholder, callback)
                local TextBox = {}

                local Main = Library:Create("Frame", {
                    Name = text,
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.SecondaryColor,
                    Size = UDim2.new(0.9, 0, 0, 45)
                })
                Library:Create("UICorner", { CornerRadius = Library.Theme.Rounding, Parent = Main })
                Library:Create("UIStroke", { Color = Library.Theme.BorderColor, Thickness = 1, Parent = Main })

                local Label = Library:Create("TextLabel", {
                    Name = "Label",
                    Parent = Main,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Input = Library:Create("TextBox", {
                    Name = "Input",
                    Parent = Main,
                    BackgroundColor3 = Library.Theme.MainColor,
                    Position = UDim2.new(0, 10, 1, -18),
                    Size = UDim2.new(1, -20, 0, 14),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder or "Type here...",
                    Text = "",
                    TextColor3 = Library.Theme.TextColor,
                    PlaceholderColor3 = Library.Theme.DimTextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                Library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Input })
                Library:Create("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = Input })

                Input.FocusLost:Connect(function(enterPressed)
                    callback(Input.Text, enterPressed)
                end)

                return TextBox
            end

            function Section:AddLabel(text)
                local Label = Library:Create("TextLabel", {
                    Name = "Label",
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    RichText = true,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                
                return Label
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
