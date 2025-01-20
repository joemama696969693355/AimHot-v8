-- Create the UI elements and assign properties using the correct syntax

-- ScreenGui
local ui = Instance.new("ScreenGui")
ui.Name = "ui"
ui.ClassName = "ScreenGui"
ui.Parent = game.Players.LocalPlayer.PlayerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.ClassName = "Frame"
Main.Position = UDim2.new(0, 0, 0, 0)
Main.Size = UDim2.new(1, 0, 1, 0)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.Parent = ui

-- Folder for Templates
local Templates = Instance.new("Folder")
Templates.Name = "Templates"
Templates.ClassName = "Folder"
Templates.Parent = ui

-- Button Frame
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "Button"
ButtonFrame.ClassName = "Frame"
ButtonFrame.Position = UDim2.new(0, 0, 0, 0)
ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
ButtonFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
ButtonFrame.Parent = Templates

-- Button TextButton
local Button = Instance.new("TextButton")
Button.Name = "Button"
Button.ClassName = "TextButton"
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "button, todo"
Button.TextColor3 = Color3.fromRGB(251, 251, 251)
Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 16
Button.Parent = ButtonFrame

-- Category Frame
local Category = Instance.new("Frame")
Category.Name = "Category"
Category.ClassName = "Frame"
Category.Position = UDim2.new(0, 0, 0, 0)
Category.Size = UDim2.new(1, 0, 0, 30)
Category.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Category.Parent = Templates

-- Top Frame
local Top = Instance.new("Frame")
Top.Name = "Top"
Top.ClassName = "Frame"
Top.Position = UDim2.new(0, 0, 0, 0)
Top.Size = UDim2.new(1, 0, 0, 30)
Top.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
Top.Parent = Category

-- Body Label
local Body = Instance.new("TextLabel")
Body.Name = "Body"
Body.ClassName = "TextLabel"
Body.Position = UDim2.new(0, 0, 0, 0)
Body.Size = UDim2.new(1, 0, 1, 0)
Body.Text = "label"
Body.TextColor3 = Color3.fromRGB(255, 250, 250)
Body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Body.TextSize = 16
Body.Parent = Top

-- Open TextButton for Category
local Open = Instance.new("TextButton")
Open.Name = "Open"
Open.ClassName = "TextButton"
Open.Position = UDim2.new(0.85, 0, 0, 0)
Open.Size = UDim2.new(0.15, 0, 1, 0)
Open.Text = "^"
Open.TextColor3 = Color3.fromRGB(255, 255, 255)
Open.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Open.TextSize = 16
Open.Parent = Category

-- Keybind Frame
local Keybind = Instance.new("Frame")
Keybind.Name = "Keybind"
Keybind.ClassName = "Frame"
Keybind.Position = UDim2.new(0, 0, 0, 0)
Keybind.Size = UDim2.new(1, 0, 0, 30)
Keybind.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Keybind.Parent = Templates

-- Keybind Body Label
local KeybindBody = Instance.new("TextLabel")
KeybindBody.Name = "Body"
KeybindBody.ClassName = "TextLabel"
KeybindBody.Position = UDim2.new(0, 0, 0, 0)
KeybindBody.Size = UDim2.new(1, 0, 1, 0)
KeybindBody.Text = "keybind"
KeybindBody.TextColor3 = Color3.fromRGB(255, 250, 250)
KeybindBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KeybindBody.TextSize = 16
KeybindBody.Parent = Keybind

-- Keybind Button
local KeybindButton = Instance.new("TextButton")
KeybindButton.Name = "Button"
KeybindButton.ClassName = "TextButton"
KeybindButton.Position = UDim2.new(0.76, 0, 0, 0)
KeybindButton.Size = UDim2.new(0.2, 0, 1, 0)
KeybindButton.Text = "MouseButton1"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
KeybindButton.TextSize = 16
KeybindButton.Parent = Keybind

-- Label Frame
local Label = Instance.new("Frame")
Label.Name = "Label"
Label.ClassName = "Frame"
Label.Position = UDim2.new(0, 0, 0, 0)
Label.Size = UDim2.new(1, 0, 0, 30)
Label.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Label.Parent = Templates

-- Label Body TextLabel
local LabelBody = Instance.new("TextLabel")
LabelBody.Name = "Body"
LabelBody.ClassName = "TextLabel"
LabelBody.Position = UDim2.new(0, 0, 0, 0)
LabelBody.Size = UDim2.new(1, 0, 1, 0)
LabelBody.Text = "label"
LabelBody.TextColor3 = Color3.fromRGB(255, 250, 250)
LabelBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LabelBody.TextSize = 16
LabelBody.Parent = Label

-- Rotate Frame
local Rotate = Instance.new("Frame")
Rotate.Name = "Rotate"
Rotate.ClassName = "Frame"
Rotate.Position = UDim2.new(0, 0, 0, 0)
Rotate.Size = UDim2.new(1, 0, 0, 43)
Rotate.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Rotate.Parent = Templates

-- Rotate Body TextLabel
local RotateBody = Instance.new("TextLabel")
RotateBody.Name = "Body"
RotateBody.ClassName = "TextLabel"
RotateBody.Position = UDim2.new(0, 12, 0, 0)
RotateBody.Size = UDim2.new(1, 0, 0, 27)
RotateBody.Text = "scroll type"
RotateBody.TextColor3 = Color3.fromRGB(255, 250, 250)
RotateBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RotateBody.TextSize = 16
RotateBody.Parent = Rotate

-- Rotate Option TextLabel
local RotateOption = Instance.new("TextLabel")
RotateOption.Name = "Option"
RotateOption.ClassName = "TextLabel"
RotateOption.Position = UDim2.new(0.175, 0, 0.5, 0)
RotateOption.Size = UDim2.new(0.65, 0, 0.5, 0)
RotateOption.Text = "current option"
RotateOption.TextColor3 = Color3.fromRGB(255, 250, 250)
RotateOption.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RotateOption.TextSize = 16
RotateOption.Parent = Rotate

-- Rotate Left Button
local RotateLeft = Instance.new("TextButton")
RotateLeft.Name = "L"
RotateLeft.ClassName = "TextButton"
RotateLeft.Position = UDim2.new(-0.15, 0, 0, 0)
RotateLeft.Size = UDim2.new(0.15, 0, 1, 0)
RotateLeft.Text = "<"
RotateLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
RotateLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RotateLeft.TextSize = 16
RotateLeft.Parent = Rotate

-- Rotate Right Button
local RotateRight = Instance.new("TextButton")
RotateRight.Name = "R"
RotateRight.ClassName = "TextButton"
RotateRight.Position = UDim2.new(1, 0, 0, 0)
RotateRight.Size = UDim2.new(0.15, 0, 1, 0)
RotateRight.Text = ">"
RotateRight.TextColor3 = Color3.fromRGB(255, 255, 255)
RotateRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RotateRight.TextSize = 16
RotateRight.Parent = Rotate

-- Slider Frame
local Slider = Instance.new("Frame")
Slider.Name = "Slider"
Slider.ClassName = "Frame"
Slider.Position = UDim2.new(0, 0, 0, 0)
Slider.Size = UDim2.new(1, 0, 0, 35)
Slider.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Slider.Parent = Templates

-- Slider Body TextLabel
local SliderBody = Instance.new("TextLabel")
SliderBody.Name = "Body"
SliderBody.ClassName = "TextLabel"
SliderBody.Position = UDim2.new(0, 12, 0, 0)
SliderBody.Size = UDim2.new(1, 0, 0, 27)
SliderBody.Text = "slider 1-100"
SliderBody.TextColor3 = Color3.fromRGB(255, 250, 250)
SliderBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBody.TextSize = 16
SliderBody.Parent = Slider

-- Slider Value TextLabel
local SliderValue = Instance.new("TextLabel")
SliderValue.Name = "Value"
SliderValue.ClassName = "TextLabel"
SliderValue.Position = UDim2.new(0.725, 0, 0.5, 0)
SliderValue.Size = UDim2.new(0.25, 0, 0.5, 0)
SliderValue.Text = "100"
SliderValue.TextColor3 = Color3.fromRGB(255, 250, 250)
SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderValue.TextSize = 16
SliderValue.Parent = Slider

-- Slider Button
local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.ClassName = "TextButton"
SliderButton.Position = UDim2.new(0.05, 0, 0.5, 0)
SliderButton.Size = UDim2.new(0.65, 0, 0.5, 0)
SliderButton.Text = "slider button"
SliderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.TextSize = 16
SliderButton.Parent = Slider
