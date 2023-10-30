function VEHICLE:Text(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

function VEHICLE:CanUse()
    return self.Vehicle > 0 and GetPedInVehicleSeat(self.Vehicle, -1) == PlayerPedId()
end

function VEHICLE:SetPlayerSeat(Seat)
    TaskWarpPedIntoVehicle(PlayerPedId(), self.Vehicle, Seat)

    CreateThread(function()
        self.CoolDown = true
        Wait(1000)
        self.CoolDown = false
    end)
end

function VEHICLE:SetDoorState(DoorState, Door)
    if DoorState then
        SetVehicleDoorOpen(self.Vehicle, Door, false, false)
    else
        SetVehicleDoorShut(self.Vehicle, Door, false)
    end
end

function VEHICLE:SetIndicatorLights(side)
    local Toggle = GetVehicleIndicatorLights(self.Vehicle)

    if Toggle == 0 then
        SetVehicleIndicatorLights(self.Vehicle, side, true)
    elseif Toggle == 1 then
        SetVehicleIndicatorLights(self.Vehicle, side, side == 0)
    elseif Toggle == 2 then
        SetVehicleIndicatorLights(self.Vehicle, side, side == 1)
    elseif Toggle == 3 then
        SetVehicleIndicatorLights(self.Vehicle, side, false)
    end
end