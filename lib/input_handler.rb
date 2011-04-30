class InputHandler
  MOUSE_BUTTONS          = [Gosu::MsLeft,Gosu::MsMiddle,Gosu::MsRight]
  def initialize(window)
    @window         = window
    @input_clients  = []
    @down_events    = {}
    @click_events   = {}
  end

  def register_input_client(client,opts={})
    x = opts[:x] || client.x
    y = opts[:y] || client.y
    z = opts[:z] || client.z
    w = opts[:width]  || client.width
    h = opts[:height] || client.height
    e = opts[:event]  || :all
    @input_clients << [x,y,x+w,y+h,z,client,e]
    @input_clients = @input_clients.sort_by{|record|record[3]}
  end

  def deregister_clients(*clients)
    @input_clients.reject!{|record| clients.include?(record[5]) }
  end

  def update
    @mouse_event = MouseEvent.new(@window)
    MOUSE_BUTTONS.each do |button|
      if @window.button_down?(button) && @down_events[button].nil?
        mouse_down!(button)
      elsif @down_events[button] && !@window.button_down?(button)
        mouse_up!(button)
      elsif @click_events[button] && !MouseEvent.new(@window).within_double_click_threshold_of(@click_events[button])
        mouse_click!(button)
      end
    end
  end

  private
  class MouseEvent
    CLICK_TIME_THRESHOLD        = 121
    DOUBLE_CLICK_TIME_THRESHOLD = 201

    def initialize(window)
      @milliseconds = Gosu::milliseconds
      @x            = window.mouse_x
      @y            = window.mouse_y
    end

    attr_reader :milliseconds, :x, :y

    def within_click_threshold_of(mouse_event)
      (self.milliseconds-mouse_event.milliseconds).abs <= CLICK_TIME_THRESHOLD
    end
    def within_double_click_threshold_of(mouse_event)
      (self.milliseconds-mouse_event.milliseconds).abs <= DOUBLE_CLICK_TIME_THRESHOLD
    end
  end

  attr_reader :mouse_event

  def mouse_down!(button)
    register_event(:mouse_down, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    @down_events[button] = mouse_event
  end

  def mouse_up!(button)
    register_event(:mouse_up, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    if MouseEvent.new(@window).within_click_threshold_of(@down_events.delete(button))
      if @click_events[button]
        mouse_double_click!(button)
        @click_events[button] = nil
      else
        @click_events[button] = mouse_event
      end
    end
  end

  def mouse_click!(button)
    register_event(:mouse_click, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    @click_events[button] = nil
  end

  def mouse_double_click!(button)
    register_event(:mouse_double_click, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
  end

  def register_event(event, opts={})
    x = opts[:x]
    y = opts[:y]
    @input_clients.each do |i|
      x1,y1,x2,y2,z,client,accepted_event = *i
      if x1 < x && x2 > x && y1 < y && y2 > y && (accepted_event==event||accepted_event==:all) && client.respond_to?(event)
        return if client.send(event,opts)
      end
    end
  end

end
