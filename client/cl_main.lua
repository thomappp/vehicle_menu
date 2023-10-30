function VEHICLE:Thread()

    MainMenu = RageUI.CreateMenu("Véhicule", "Gestion du vehicule");
    SeatMenu = RageUI.CreateSubMenu(MainMenu, "Véhicule", "Sieges");
    DoorMenu = RageUI.CreateSubMenu(MainMenu, "Véhicule", "Portes");

    CreateThread(function()
        while true do
    
            local PlayerWait = 1000
            local PlayerPed = PlayerPedId()
            self.Vehicle = GetVehiclePedIsIn(PlayerPed, false)
            
            if self:CanUse() then

                self.Engine = GetIsVehicleEngineRunning(self.Vehicle)

                PlayerWait = 5

                if IsControlJustReleased(0, 174) then
                    self:SetIndicatorLights(1)
                elseif IsControlJustReleased(0, 175) then
                    self:SetIndicatorLights(0)
                end
            else
                if RageUI.Visible(MainMenu) or
                    RageUI.Visible(DoorMenu) or
                    RageUI.Visible(HelpMenu) then
                    
                    RageUI.GoBack()
                end
            end
    
            Wait(PlayerWait)
        end
    end)

    function RageUI.PoolMenus:CreatorMenu()
        MainMenu:IsVisible(function(Items)

            Items:AddSeparator("~y~Gestion")

            Items:CheckBox("Moteur", nil, VEHICLE.Engine, { IsDisabled = false }, function(onSelected, IsChecked)
                if (onSelected) then
                    if VEHICLE.Engine then
                        SetVehicleEngineOn(VEHICLE.Vehicle, false, false, true)
                    elseif not VEHICLE.Engine then
                        SetVehicleEngineOn(VEHICLE.Vehicle, true, false, true)
                    end
                end
            end)

            Items:AddButton("Sièges", nil, { IsDisabled = false }, function(onSelected)
            end, SeatMenu)

            Items:AddButton("Portes", nil, { IsDisabled = false }, function(onSelected)
            end, DoorMenu)

            Items:AddSeparator("~y~Informations")
            
            Items:AddButton("Plaque", nil, { IsDisabled = false, RightLabel = GetVehicleNumberPlateText(VEHICLE.Vehicle) }, function(onSelected)
            end)

            Items:AddButton("Vitesse", nil, { IsDisabled = false, RightLabel = string.format("%.0f km/h", GetEntitySpeed(VEHICLE.Vehicle) * 3.6) }, function(onSelected)
            end)

            Items:AddButton("Etat véhicule", nil, { IsDisabled = false, RightLabel = string.format("%.0f/100", GetVehicleBodyHealth(VEHICLE.Vehicle) * 0.1) }, function(onSelected)
            end)

            Items:AddButton("Etat moteur", nil, { IsDisabled = false, RightLabel = string.format("%.0f/100", GetVehicleEngineHealth(VEHICLE.Vehicle) * 0.1) }, function(onSelected)
            end)

            Items:AddButton("Température moteur", nil, { IsDisabled = false, RightLabel = string.format("%.1f", GetVehicleEngineTemperature(VEHICLE.Vehicle)) }, function(onSelected)
            end)

        end, function()
        end)

        SeatMenu:IsVisible(function(Items)

            for i = 1, GetVehicleModelNumberOfSeats(GetEntityModel(VEHICLE.Vehicle)) do
                local Seat = i - 2
                local CanSeat = IsVehicleSeatFree(VEHICLE.Vehicle, Seat)
                
                Items:AddButton(("Siège %s"):format(i), (CanSeat == false and "Siège occupé" or nil), { IsDisabled = VEHICLE.CoolDown }, function(onSelected)
                    if (onSelected) then

                        if CanSeat then
                            VEHICLE:SetPlayerSeat(Seat)
                        else
                            VEHICLE:Text("~y~Véhicule\n~s~Le siège est occupé.")
                        end
                    end
                end)
            end

        end, function()
        end)

        DoorMenu:IsVisible(function(Items)

            for i = 1, GetNumberOfVehicleDoors(VEHICLE.Vehicle) do
                local Door = i - 1
                local DoorState = GetVehicleDoorAngleRatio(VEHICLE.Vehicle, Door) < 0.1
                local DoorDestroy = IsVehicleDoorDamaged(VEHICLE.Vehicle, Door)
                
                Items:CheckBox(("Porte %s"):format(i), (DoorDestroy == 1 and "Porte endommagée" or nil), DoorState, { IsDisabled = false }, function(onSelected, IsChecked)
                    if (onSelected) then

                        if not DoorDestroy then
                            VEHICLE:SetDoorState(DoorState, Door)
                        else
                            VEHICLE:Text("~y~Véhicule\n~s~La porte est endommagée.")
                        end
                    end
                end)
            end

        end, function()
        end)
    end

    Keys.Register("F10", "F10", "Menu véhicule", function()
        if self:CanUse() then
            RageUI.Visible(MainMenu, not RageUI.Visible(MainMenu))
        end
    end)
end

AddEventHandler("onResourceStart", function(ResourceName)
    if ResourceName == GetCurrentResourceName() then
        VEHICLE:Thread()
    end
end)