local M = {}

M.outputPorts = {[1] = true} --set dynamically
M.deviceCategories = {engine = true}

local delayLine = require("delayLine")

local max = math.max
local min = math.min
local abs = math.abs
local floor = math.floor
local random = math.random
local smoothmin = smoothmin

local rpmToAV = 0.104719755
local avToRPM = 9.549296596425384
local torqueToPower = 0.0001404345295653085
local psToWatt = 735.499
local hydrolockThreshold = 0.9

local function getTorqueData(device)
  local curves = {}
  local curveCounter = 1
  local maxTorque = 0
  local maxTorqueRPM = 0
  local maxPower = 0
  local maxPowerRPM = 0
  local maxRPM = device.maxRPM

  local turboCoefs = nil
  local superchargerCoefs = nil
  local nitrousTorques = nil

  local torqueCurve = {}
  local powerCurve = {}

  for k, v in pairs(device.torqueCurve) do
    if type(k) == "number" and k < maxRPM then
      torqueCurve[k + 1] = v - device.friction * device.wearFrictionCoef * device.damageFrictionCoef - (device.dynamicFriction * device.wearDynamicFrictionCoef * device.damageDynamicFrictionCoef * k * rpmToAV)
      powerCurve[k + 1] = torqueCurve[k + 1] * k * torqueToPower
      if torqueCurve[k + 1] > maxTorque then
        maxTorque = torqueCurve[k + 1]
        maxTorqueRPM = k + 1
      end
      if powerCurve[k + 1] > maxPower then
        maxPower = powerCurve[k + 1]
        maxPowerRPM = k + 1
      end
    end
  end

  table.insert(curves, curveCounter, {torque = torqueCurve, power = powerCurve, name = "NA", priority = 10})
