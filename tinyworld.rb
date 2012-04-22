require 'gosu'
require 'chingu'

include Gosu

class TinyWorld < Chingu::Window
  def initialize
    super(1024, 768)

    Image.autoload_dirs << File.join(ROOT, '..', 'application', 'gfx')
    Image.autoload_dirs << File.join(ROOT, '..', 'gfx')
    Sound.autoload_dirs << File.join(ROOT, '..', 'application', 'sfx')
    Sound.autoload_dirs << File.join(ROOT, '..', 'sfx')
    Song.autoload_dirs << File.join(ROOT, '..', 'application', 'songs')
    Song.autoload_dirs << File.join(ROOT, '..', 'songs')
    push_game_state(Play)
  end
end

class Play < Chingu::GameState
  trait :viewport

  def initialize
    super
    load_game_objects
  end

  def setup
    @player = Player.create
    viewport.game_area = [0,0,2048,2048]
    self.input = {
      :escape => :exit,
      :e => :edit,
      :r => :restart
    }
  end

  def finalize
    @player.destroy
  end

  def make_level
    (4..127).each do |y|
      (0..127).each do |x|
        if Random.rand(6) + 1 < 3
          block = Block.create(:x => x * 16, :y => y * 16)
        else
          if Random.rand(40) == 1
            donut = Donut.create(:x => x * 16, :y => y * 16)
          elsif Random.rand(10) == 1
            ladder = Ladder.create(:x => x * 16, :y => y * 16)
          end
        end
      end
    end
  end

  def restart
    switch_game_state(Play)
  end

  def edit
    push_game_state(Chingu::GameStates::Edit.new(:grid => [16,16], :classes => [Block, Donut, Ladder]))
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

class Ladder < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection

  def setup
    self.image = Image["ladder.png"]
    self.center_x = 0
    self.center_y = 0
    self.zorder = 200
  end

  def self.nearby(x,y)
    Ladder.all.reject do |ladder|
      (ladder.x - x).abs > 32 && (ladder.y - y).abs > 32
    end
  end
end

class Donut < Chingu::GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection

  def setup
    puts "Donut made!"
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
  trait :bounding_box, :scale => [0.6, 0.8], :debug => false
  trait :collision_detection
  trait :velocity
  
  SPEED = 2
  JUMP = -4
  GRAVITY = 0.2

  def setup
    @climable = false
    @jumping = false
    self.zorder = 255
    self.center_y = 1
    self.x = 8
    self.y = 24
    self.acceleration_y = GRAVITY
    self.max_velocity = 10
    self.image = Image["player_16x16_default.png"]
    @animation = Chingu::Animation.new(:file => "player_16x16_animated.png")
    @animation.frame_names = { :default => 0..0, :left => 1..2, :right => 3..4, :climbing => 5..6}
    @frame_name = :default
    
    @jump_sound = Sound["jump.wav"]
    self.input = {
      :holding_left => :move_left,
      :holding_right => :move_right,
      :holding_up => :move_up,
      :holding_down => :move_down,
    }
    cache_bounding_box
  end

  def move_left
    move(-SPEED,0)
    @frame_name = :left
  end

  def move_right
    move(SPEED,0)
    @frame_name = :right
  end
  
  def move(x,y)
    self.x += x
    self.y += y
    self.each_collision(Block.nearby(self.x, self.y)) do |player, block|
      self.x = previous_x
      self.y = previous_y
      break
    end

  end
  
  def move_up
    if @climable
      move(0, -SPEED)
      @frame_name = :climbing
    end
  end

  def move_down
    if @climable
      move(0, SPEED)
      @frame_name = :climbing
    end
  end
  
  def jump
    if @climable
      move(0,-SPEED)
      @frame_name = :climbing
      return
    end

    return if @jumping
    self.velocity_y = JUMP
    @jump_sound.play
    @jumping = true
  end

  def update
    @image = @animation[@frame_name].next

    self.each_bounding_box_collision(Block.nearby(self.x, self.y)) do |player, block|

      if self.velocity_y < 0 # Moving upwards and hit something
        puts "moving up"
        self.velocity_y = 0
        self.y = block.y + 16
      end

      if self.velocity_y > 0 # Moving downwards and hit something
        puts "moving down"
        self.velocity_y = 0
        self.y = previous_y
        @jumping = false
      end
    end
    
    if self.x = previous_x
      @frame_name = :default
    end

    self.each_bounding_box_collision(Donut.nearby(self.x, self.y)) do |player, donut|
      donut.destroy
      Sound["pickup.wav"].play
    end

    @climable = false
    self.acceleration_y = GRAVITY
    self.each_bounding_box_collision(Ladder.nearby(self.x, self.y)) do |player, ladder|
      @climable = true
      @frame_name = :climbing
      self.acceleration_y = 0
      self.velocity_y = 0
    end
  end

end

TinyWorld.new.show
