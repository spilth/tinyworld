require 'gosu'
require 'chingu'

include Gosu

class TinyWorld < Chingu::Window
  def initialize
    super(1024, 768)

    (4..95).each do |y|
      (0..127).each do |x|
        block = Block.create(:x => x * 8, :y => y * 8)
      end
    end
    @player = Player.create

  end

end

class Block < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection

  def setup
    self.image = Image["block.png"]
    self.center_x = 0
    self.center_y = 0
    cache_bounding_box
  end

  def self.nearby(x,y)
    Block.all.reject do |block|
      (block.x - x).abs > 16 && (block.y - y).abs > 16
    end
  end

end

class Player < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection
  trait :velocity
  
  SPEED = 4

  def setup
    @jumping = false
    self.center_x = 0
    self.center_y = 0
    self.x = 8
    self.y = 24
    self.acceleration_y = 0.4
    self.max_velocity = 5
    self.image = Image["player.png"]
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
    self.velocity_y = -4
    @jumping = true
  end

  def update
    
    self.each_bounding_box_collision(Block.nearby(self.x, self.y)) do |player, block|
      self.y = self.previous_y
      self.x = self.previous_x
      @jumping = false
    end

  end

end

TinyWorld.new.show
