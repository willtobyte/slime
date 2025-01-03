---@diagnostic disable: undefined-global, undefined-field, lowercase-global

local io
local scenemanager
local soundmanager
local entitymanager
local statemanager
local timemanager

local keystate = {}

local hand
local slime

function setup()
  _G.engine = EngineFactory.new()
      :with_title("Slime")
      :with_width(1920)
      :with_height(1080)
      :with_scale(3.0)
      :with_gravity(9.8)
      :with_fullscreen(false)
      :create()

  io = Socket.new()
  io:connect()

  scenemanager = engine:scenemanager()
  soundmanager = engine:soundmanager()
  entitymanager = engine:entitymanager()
  statemanager = engine:statemanager()

  timemanager = TimeManager.new()

  slime = entitymanager:spawn("slime")
  slime.action:set("idle")
  slime.placement:set(0, 0)

  hand = entitymanager:spawn("hand")
  hand.action:set("idle")
  hand.placement:set(0, 0)
  hand:on_animationfinished(function(self)
    self.action:set("idle")
  end)

  scenemanager:set("default")
end

function loop()
  hand.velocity.x, hand.velocity.y = 0, 0
  slime.velocity.x, slime.velocity.y = 0, 0
  slime.reflection:unset()

  if statemanager:player(Player.one):on(Controller.up) then
    slime.velocity.y = -80
  elseif statemanager:player(Player.one):on(Controller.down) then
    slime.velocity.y = 80
  end

  if statemanager:player(Player.one):on(Controller.left) then
    slime.velocity.x = -80
    slime.reflection:set(Reflection.horizontal)
  elseif statemanager:player(Player.one):on(Controller.right) then
    slime.velocity.x = 80
  end

  local action = "idle"
  if slime.velocity.y > 0 then
    action = "down"
  elseif slime.velocity.y < 0 then
    action = "up"
  elseif slime.velocity.x ~= 0 then
    action = "side"
  end

  slime.action:set(action)

  if statemanager:player(Player.two):on(Controller.up) then
    hand.velocity.y = -80
  elseif statemanager:player(Player.two):on(Controller.down) then
    hand.velocity.y = 80
  end
  if statemanager:player(Player.two):on(Controller.left) then
    hand.velocity.x = -80
  elseif statemanager:player(Player.two):on(Controller.right) then
    hand.velocity.x = 80
  end

  if statemanager:player(Player.two):on(Controller.square) then
    if not keystate[Controller.square] then
      keystate[Controller.square] = true
      hand.action:set("attack")
    else
      keystate[Controller.square] = false
    end
  end
end

function run()
  engine:run()
end
