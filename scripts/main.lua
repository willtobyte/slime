---@diagnostic disable: undefined-global, undefined-field, lowercase-global

local io
local scenemanager
local soundmanager
local entitymanager
local statemanager

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
  scenemanager = engine:scenemanager()
  soundmanager = engine:soundmanager()
  entitymanager = engine:entitymanager()
  statemanager = engine:statemanager()

  io:connect()

  -- hand = entitymanager:spawn("hand")
  -- hand.action:set("idle")
  -- hand.placement:set(0, 0)

  slime = entitymanager:spawn("slime")
  slime.action:set("idle")
  slime.placement:set(0, 0)

  scenemanager:set("default")
end

function loop()
  -- hand.velocity.x, hand.velocity.y = 0, 0
  slime.velocity.x, slime.velocity.y = 0, 0

  -- if statemanager.player[1]:event(Event.down) then
  --   print("down")
  -- end

  statemanager.player[4]:event()

  if statemanager:is_keydown(KeyEvent.left) then
    slime.reflection:set(Reflection.horizontal)
    slime.velocity.x = -80
  elseif statemanager:is_keydown(KeyEvent.right) then
    slime.reflection:unset()
    slime.velocity.x = 80
  end

  if statemanager:is_keydown(KeyEvent.up) then
    slime.velocity.y = -80
  elseif statemanager:is_keydown(KeyEvent.down) then
    slime.velocity.y = 80
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
end

function run()
  engine:run()
end
