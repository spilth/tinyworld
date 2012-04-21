require 'gosu'
require 'chingu'

include Gosu

class TinyWorld < Chingu::Window
  def initialize
    super(1024, 768)

    push_game_state(Play)
  end
end

class Play < Chingu::GameState
  trait :viewport

  def setup
    (4..95).each do |y|
      (0..127).each do |x|
        if Random.rand(6) + 1 < 3
          block = Block.create(:x => x * 16, :y => y * 16)
        else
          if Random.rand(20) == 1
            donut = Donut.create(:x => x * 16, :y => y * 16)
          end
        end
      end
    end
    @player = Player.create
    viewport.game_area = [0,0,2048,1536]
  end

  def update
    super
    viewport.center_around(@player)
  end
end

class Block < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection

  def setup
    self.image = Image["block16.png"]
    self.center_x = 0
    self.center_y = 0
    cache_bounding_box
  end

  def self.nearby(x,y)
    Block.all.reject do |block|
      (block.x - x).abs > 32 && (block.y - y).abs > 32
    end
  end

end

class Donut < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection

  def setup
    self.image = Image["donut.png"]
    self.center_x = 0
    self.center_y = 0
  end
  
  def self.nearby(x,y)
    Donut.all.reject do |donut|
      (donut.x - x).abs > 32 && (donut.y - y).abs > 32
    end
  end
end

class Player < Chingu::GameObject
  trait :bounding_box, :scale => [1.0, 1.0], :debug => false
  trait :collision_detection
  trait :velocity
  
  SPEED = 4

  def setup
    @jumping = false
    self.center_y = 0
    self.x = 8
    self.y = 24
    self.acceleration_y = 0.4
    self.max_velocity = 10
    self.image = Image["player.png"]
    @jump_sound = Sound["jump.wav"]
    self.input = {
      :holding_left => :move_left,
      :holding_right => :move_right,
      [:space, :up] => :jump
    }
    cache_bounding_box
  end

  def move_left
    self.x -= SPEED
  end

  def move_right
    self.x += SPEED
  end

  def jump
    return if @jumping
    self.velocity_y = -6
    @jump_sound.play
    @jumping = true
  end

  def update
    
    self.each_bounding_box_collision(Block.nearby(self.x, self.y)) do |player, block|
      self.y = self.previous_y
      self.x = self.previous_x
      @jumping = false
      block.color = Color::RED
    end
    
    self.each_bounding_box_collision(Donut.nearby(self.x, self.y)) do |player, donut|
      donut.destroy
      Sound["pickup.wav"].play
    end

  end

end

TinyWorld.new.show
