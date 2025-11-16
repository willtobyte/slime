_G.engine = EngineFactory.new()
    :with_title("Slime")
    :with_width(1920)
    :with_height(1080)
    :with_scale(3.0)
    :with_gravity(9.8)
    :with_fullscreen(false)
    :create()

function setup()
  scenemanager:register("default")
  scenemanager:set("default")
end

function loop()
  engine:run()
end
