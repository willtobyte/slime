---@diagnostic disable: undefined-global, undefined-field, lowercase-global

local io
local fontfactory
local scenemanager
local soundmanager
local entitymanager
local statemanager
local timemanager
local overlay

local keystate = {}
local ignore = { stun = true }

local hand
local slime

local score

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

  entitymanager = engine:entitymanager()
  fontfactory = engine:fontfactory()
  scenemanager = engine:scenemanager()
  soundmanager = engine:soundmanager()
  statemanager = engine:statemanager()
  overlay = engine:overlay()

  score = overlay:create(WidgetType.label)
  score.font = fontfactory:get("fixedsys")
  score:set("Score 9999", 540, 10)

  timemanager = TimeManager.new()

  slime = entitymanager:spawn("slime")
  slime.action:set("idle")
  slime.placement:set(0, 0)

  hand = entitymanager:spawn("hand")
  hand.action:set("idle")
  hand.placement:set(0, 0)
  hand:on_collision("slime", function(self)
    if hand.action:get() ~= "attack" then
      return
    end

    slime.action:set("stun")

    local position = slime.placement:get()
    local sx, sy = position.x, position.y

    local distance = math.random(3, 9) * 10

    local angle = math.random() * (2 * math.pi)

    local nx = sx + distance * math.cos(angle)
    local ny = sy + distance * math.sin(angle)

    slime.placement:set(nx, ny)

    timemanager:singleshot(3000, function()
      slime.action:set("idle")
    end)
  end)
  -- end)
  --   slime.action:set("stun")

  --   local position = slime.placement:get()
  --   local sx, sy = position.x, position.y

  --   local distance = math.random(3, 9) * 10

  --   local angle = math.random() * (2 * math.pi)

  --   local nx = sx + distance * math.cos(angle)
  --   local ny = sy + distance * math.sin(angle)

  --   slime.placement:set(nx, ny)

  --   timemanager:singleshot(3000, function()
  --     slime.action:set("idle")
  --   end)
  -- end)

  hand:on_animationfinished(function(self)
    hand.action:set("idle")
    -- slime.action:set("stun")
    -- timemanager:singleshot(2000, function()
    --   slime.action:set("idle")
    -- end)
  end)

  scenemanager:set("default")
end

function loop()
  hand.velocity.x, hand.velocity.y = 0, 0
  slime.velocity.x, slime.velocity.y = 0, 0
  slime.reflection:unset()

  if ignore[slime.action:get()] then
    return
  end

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
