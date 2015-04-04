class LambdaStack
  attr_reader :size

  def initialize
    @head = nil
    @size = 0
  end

  def push add
    old_head = @head
    @head = ->{ @head = old_head; add}
    @size += 1
  end

  def pop
    return nil unless @size > 0
    value = @head.call
    @size -= 1
    value
  end

  def peek
    return nil unless @size > 0
    val = pop
    push val
    val
  end

  def empty?
    @size.eql? 0
  end
end


class LinkStack
  attr_reader :size
  def initialize
    @stack = nil
    @size = 0
  end
  def push value
    @stack = LinkStack::Node.new value, @stack
    @size += 1
  end
  def pop
    return nil unless @size > 0
    value = @stack.value
    @stack = @stack.next
    @size -= 1
    value
  end
  def peek
    return nil unless @size > 0
    @stack.value
  end
  def empty?
    @size.eql? 0
  end
  class Node
    attr_reader :value, :next
    def initialize value, other = nil
      @value = value
      @next = other
    end
  end
end
