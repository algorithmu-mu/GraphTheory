class TopologicalSort
  def exec(graph)
    topological_sort(graph)
  end

  private

  def topological_sort(graph, sorted_node_ids = [])
    if graph.is_empty?
      p sorted_node_ids
      return
    end

    graph.nodes_that_have_no_from_nodes.each do |node|
      _sorted_node_ids, _graph = sorted_node_ids.dup, graph.dup

      _sorted_node_ids << node.id
      _graph.remove_node_and_its_direction(node.id)
      topological_sort(_graph, _sorted_node_ids)
    end
  end
end

class Graph
  attr_reader :nodes

  def initialize(nodes)
    @nodes = nodes
  end

  def dup
    _nodes = @nodes.map { |node| node.dup }
    Graph.new(_nodes)
  end

  def find(node_id)
    @nodes.find do |node|
      node.id == node_id
    end
  end

  def nodes_that_have_no_from_nodes
    @nodes.select do |node|
      node.from_node_ids.empty?
    end
  end

  def nodes_that_have_no_to_nodes
    @nodes.select do |node|
      node.to_node_ids.empty?
    end
  end

  def remove_node_and_its_direction(node_id)
    node = find(node_id)
    raise 'cannot remove non-existent node' if node == nil
    raise 'cannot remove the node which have from_nodes.' if node.from_node_ids.any?

    node.to_node_ids.each do |to_node_id|
      target_node = find(to_node_id)
      target_node.from_node_ids.delete(node.id)
    end

    @nodes.delete_if do |_node|
      _node.id == node_id
    end
  end

  def is_empty?
    @nodes.empty?
  end
end

class Node
  attr_reader :id, :from_node_ids, :to_node_ids

  def initialize(id, from_node_ids = [], to_node_ids = [])
    @id = id
    @from_node_ids = from_node_ids
    @to_node_ids = to_node_ids
  end

  def dup
    Node.new(@id, @from_node_ids.dup, @to_node_ids.dup)
  end
end

class GraphCreator
  # text_input like below:
  # 5 5 # the number of nodes, the number of input for direction
  # 1 2 # the node 1 is directed toward the node 2
  # 2 3
  # 3 5
  # 1 4
  # 4 5
  def exec(input_text)
    @inputs = input_array_from_string(input_text)
    nodes_count, direction_count = @inputs.first

    unless direction_count == (@inputs.count - 1)
      raise "Invalid input. direction_count: #{direction_count} but there are #{@inputs.count - 1} inputs."
    end

    nodes = nodes_with_count(nodes_count)
    @graph = Graph.new(nodes)

    direction_inputs = @inputs[1..-1]
    add_direction_information_to_nodes(direction_inputs)
    @graph
  end

  private

  def input_array_from_string(input_text)
    input_text.split("\n").map do |one_line_input|
      one_line_input.split(' ').map(&:to_i)
    end
  end

  def nodes_with_count(count)
    Array.new(count) do |i|
      id = i + 1
      Node.new(id)
    end
  end

  def add_direction_information_to_nodes(direction_inputs)
    direction_inputs.each do |input|
      from_node_id, to_node_id = input
      from_node, to_node = @graph.find(from_node_id), @graph.find(to_node_id)

      if [from_node, to_node].include?(nil)
        raise "Invalid input. the direction: '#{from_node_id} -> #{to_node_id}' includes non-existent node."
      end

      if from_node.to_node_ids.include?(to_node_id) || to_node.from_node_ids.include?(from_node_id)
        raise "Invalid input. direction from #{from_node_id} to #{to_node_id} is declared more than once."
      end

      from_node.to_node_ids << to_node_id
      to_node.from_node_ids << from_node_id
    end
  end
end

input_text = <<EOS
3 2
2 1
2 3
EOS

graph = GraphCreator.new.exec(input_text)
TopologicalSort.new.exec(graph)
