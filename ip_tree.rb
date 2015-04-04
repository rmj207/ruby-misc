require 'ipaddr'

class IPTree
  def initialize(type = Socket::AF_INET)
    @root = Node.new(nil, nil)
    @type = type
  end

  def find_best_networks(base = 20)
    nodes = get_nodes(@root, base)
    nodes.inject({}) do |acc, n|
      best = best_network(n)
      net,mask = best.split("/")
      acc[best] = ips_in_network(net,mask.to_i)
      acc
    end
  end

  def best_network(node)
    if (node.one_child and node.zero_child) or node.leaf?
      return node.to_s + "/" + node.depth.to_s
    end
    node.one_child ? best_network(node.one_child) : best_network(node.zero_child)
  end

  def get_nodes(node, depth)
    return [] if node.nil?
    return [node] if depth == 0
    get_nodes(node.zero_child, depth - 1) + get_nodes(node.one_child, depth - 1)
  end

  def ips_in_network(network, mask)
    ips(find_node(@root, ensure_complete_ip(network), mask))
  end

  def find_node(node, elems, mask)
    return nil if node.nil?
    return node if mask == 0
    next_node = nil
    if elems[0] == "0"
      next_node = node.zero_child
    else
      next_node = node.one_child
    end
    find_node(next_node, elems[1..-1], mask - 1)
  end

  def ips(node = @root)
    return [] if node.nil?
    return [IPAddr.new(node.mask.to_i(2), @type).to_s] if node.leaf?
    ips(node.zero_child) + ips(node.one_child)
  end

  def tree
    @root
  end

  def ensure_complete_ip(ip)
    ip = IPAddr.new(ip).to_i.to_s(2)
    "0" * (32 - ip.length) + ip
  end

  def << (ip)
    build_tree(@root, ensure_complete_ip(ip))
  end

  def build_tree(node, ip)
    return if ip.nil? or ip.empty?
    head = ip[0]
    next_node = nil
    if head == "0"
      node.zero_child = Node.new(node, head) if node.zero_child.nil?
      next_node = node.zero_child
    else
      node.one_child = Node.new(node, head) if node.one_child.nil?
      next_node = node.one_child
    end
    build_tree(next_node, ip[1..-1])
  end

  class Node
    attr_accessor :zero_child, :one_child
    attr_reader :parent, :value
    def initialize(parent,value)
      @value = value
      @parent = parent
    end
    def leaf?
      not (zero_child or one_child)
    end
    def depth
      parent.nil? ? 0 : 1 + parent.depth
    end
    def mask_value
      parent.value.nil? ? @value : parent.mask_value + @value
    end
    def to_s
      IPAddr.new(mask.to_i(2), Socket::AF_INET).to_s
    end
    def mask
      mask_value + "0" * (32 - mask_value.length)
    end
  end
end
