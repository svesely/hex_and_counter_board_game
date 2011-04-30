class HexAndCounterBoardGame < Gosu::Window
  def initialize(tile_set="default")
    @width, @height = 1800, 1000
    super(@width, @height, false)
    self.caption = "Hex-and-Counter Board"
    ResourceBundle.load(self,tile_set)
    @input_handler = InputHandler.new(self)
    @hex_board     = HexBoard.new(  1000, 1000,    0, 0, 10, 15, 22, 100, 100, self)
    @hex_palette   = HexPalette.new( 1000, 50, 10, 800,  300, self)
    @input_handler.register_input_client(@hex_board)
    @input_handler.register_input_client(@hex_palette)
  end

  attr_reader :input_handler, :hex_palette

  def draw
    ResourceBundle.cursor.draw(self.mouse_x,self.mouse_y,999)
    @hex_board.draw
    @hex_palette.draw
  end

  def update
    @input_handler.update
    @hex_board.update
    @hex_palette.update
  end
end
