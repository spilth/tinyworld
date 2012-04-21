require 'gosu'
require 'chingu'

include Gosu

class TinyWorld < Chingu::Window
  def initialize
    super(1024, 768)

  end

end

TinyWorld.new.show
