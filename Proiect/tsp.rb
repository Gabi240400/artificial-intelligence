class Chromosome
  attr_reader :solution, :fitness, :distances

  def initialize(solution, distances)
    @solution = solution
    @distances = distances
    @fitness = calculate_fitness(solution)
  end

  private

  def calculate_fitness(solution)
    fit = 0
    n = solution.length
    (0..n - 2).each do |i|
      fit += distances[solution[i] - 1][solution[i+1] - 1]
    end
    fit + distances[solution[n-1] - 1][solution[0] - 1]
  end
end

def read_config_file(file_path)
  lines = []
  File.open(file_path, 'r') do |file|
    lines = file.readlines
  end
  objects = []
  n = lines[0].strip.to_i
  (1..n).each do |i|
    line = lines[i].strip
    parts = line.split(' ')
    objects[i-1] = {}
    objects[i-1]['poz'] = parts[0].to_i
    objects[i-1]['x'] = parts[1].to_i
    objects[i-1]['y'] = parts[2].to_i
  end
  [n, objects]
end

def read_config_file_asym(file_path)
  lines = []
  File.open(file_path, 'r') do |file|
    lines = file.readlines
  end
  dist = []
  n = lines[0].strip.to_i
  distances = lines.drop(1)
  distances.map! { |l| l.strip.split(' ') }
           .flatten!
           .map! { |l| l.to_i }
  index = 0
  (0..n-1).each do |i|
    dist[i] = []
    (0..n-1).each do |j|
      dist[i][j] = distances[index]
      index += 1
    end
  end
  [n, dist]
end

def get_all_distances(n, objects)
  dist = []
  (0..n-1).each do |i|
    dist[i] = []
    (0..n-1).each do |j|
      if i == j
        dist[i][j] = 999999999
      else
        dist[i][j] = distance(objects[i], objects[j])
      end
    end
  end
  dist
end

def distance(a, b)
  dif1 = (a['x'] - b['x']) * (a['x'] - b['x'])
  dif2 = (a['y'] - b['y']) * (a['y'] - b['y'])
  Math.sqrt(dif1 + dif2).round
end

def generate_random_chromosome(n, dist)
  sol = []
  (0..n - 1).each do |i|
    sol[i] = i + 1
  end
  sol.shuffle!
  Chromosome.new(sol, dist)
end

def generate_population(n, population_size, dist)
  population = []
  (1..population_size).each do |i|
    population << generate_random_chromosome(n, dist)
  end
  population
end

def generate_parents(dist, p_r, population)
  parents = []
  population.sort_by! { |c| c.fitness }
  i = 0
  population_size = population.length
  parents_size = population_size * 2
  while i < parents_size
    r = rand()
    if r < p_r
      parents << population[0]
    else
      parents << Chromosome.new(population[rand(population_size - 1)].solution.dup, dist)
    end
    i += 1
  end
  parents
end

def generate_children(dist, p_c, parents, crossover_type)
  children = []
  parents_size = parents.length
  i = 0
  while i < parents_size
    p1 = parents[i]
    p2 = parents[i + 1]
    r = rand()
    if r < p_c
      case crossover_type
      when 'spcx'
        c1, c2 = crossover_spcx(p1.solution, p2.solution)
        children << Chromosome.new(c1, dist)
        children << Chromosome.new(c2, dist)
      when 'scx'
        c = crossover_scx(p1.solution, p2.solution, dist)
        children << Chromosome.new(c, dist)
      when 'ncx'
        c = crossover_ncx(p1.solution, p2.solution, dist)
        children << Chromosome.new(c, dist)
      end
    end
    i += 2
  end
  children
end

def crossover_spcx(p1, p2)
  solution_size = p1.length
  rand_pos = rand(1..solution_size - 2)
  c1 = []
  c2 = []
  i = 0
  while i < rand_pos
    c1 << p1[i]
    c2 << p2[i]
    i += 1
  end
  while i < solution_size
    c1 << p2[i] unless c1.include?(p2[i])
    c2 << p1[i] unless c2.include?(p1[i])
    i += 1
  end
  i = 0
  while i < rand_pos
    c1 << p2[i] unless c1.include?(p2[i])
    c2 << p1[i] unless c2.include?(p1[i])
    i += 1
  end
  [c1, c2]
end

def crossover_scx(p1, p2, dist)
  solution_size = p1.length
  c = []
  c << 1
  curr_node = 1
  while c.length != solution_size
    index_p1 = p1.find_index(curr_node) + 1
    index_p2 = p2.find_index(curr_node) + 1
    legitimate_node_p1 = -1
    legitimate_node_p2 = -1
    while index_p1 < solution_size
      legitimate_node_p1 = p1[index_p1]
      if !c.include?(p1[index_p1])
        break
      else
        index_p1 += 1
      end
    end
    if index_p1 == solution_size
      (1..solution_size).each do |ind|
        unless c.include?(ind)
          legitimate_node_p1 = ind
          break
        end
      end
    end
    while index_p2 < solution_size
      legitimate_node_p2 = p2[index_p2]
      if !c.include?(p2[index_p2])
        break
      else
        index_p2 += 1
      end
    end
    if index_p2 == solution_size
      (1..solution_size).each do |ind|
        unless c.include?(ind)
          legitimate_node_p2 = ind
          break
        end
      end
    end

    legitimate_node_p1_distance = dist[curr_node - 1][legitimate_node_p1 - 1]
    legitimate_node_p2_distance = dist[curr_node - 1][legitimate_node_p2 - 1]
    if legitimate_node_p1_distance < legitimate_node_p2_distance
      c << legitimate_node_p1
      curr_node = legitimate_node_p1
    else
      c << legitimate_node_p2
      curr_node = legitimate_node_p2
    end
  end
  c
end

def crossover_ncx(p1, p2, dist)
  solution_size = p1.length
  c = []
  c << 1
  curr_node = 1
  while c.length != solution_size
    index_p1 = p1.find_index(curr_node)
    index_p2 = p2.find_index(curr_node)
    neighbors = []

    if index_p1 == 0
      right_neighbor = p1[1]
      neighbors << right_neighbor unless c.include?(right_neighbor)
      left_neighbor = p1[solution_size - 1]
      neighbors << left_neighbor unless c.include?(left_neighbor)
    elsif index_p1 == solution_size - 1
      left_neighbor = p1[solution_size - 2]
      neighbors << left_neighbor unless c.include?(left_neighbor)
      right_neighbor = p1[0]
      neighbors << right_neighbor unless c.include?(right_neighbor)
    else
      left_neighbor = p1[index_p1 - 1]
      neighbors << left_neighbor unless c.include?(left_neighbor)
      right_neighbor = p1[index_p1 + 1]
      neighbors << right_neighbor unless c.include?(right_neighbor)
    end

    if index_p2 == 0
      right_neighbor = p2[1]
      neighbors << right_neighbor unless c.include?(right_neighbor)
      left_neighbor = p2[solution_size - 1]
      neighbors << left_neighbor unless c.include?(left_neighbor)
    elsif index_p2 == solution_size - 1
      left_neighbor = p2[solution_size - 2]
      neighbors << left_neighbor unless c.include?(left_neighbor)
      right_neighbor = p2[0]
      neighbors << right_neighbor unless c.include?(right_neighbor)
    else
      left_neighbor = p2[index_p2 - 1]
      neighbors << left_neighbor unless c.include?(left_neighbor)
      right_neighbor = p2[index_p2 + 1]
      neighbors << right_neighbor unless c.include?(right_neighbor)
    end

    if neighbors.empty?
      (1..solution_size).each do |ind|
        unless c.include?(ind)
          c << ind
          curr_node = ind
          break
        end
      end
    else
      lowest_fitness = 999999999999
      node = -1
      neighbors.each do |potential_node|
        curr_dist = dist[curr_node - 1][potential_node - 1]
        if curr_dist < lowest_fitness
          lowest_fitness = curr_dist
          node = potential_node
        end
      end
      c << node
      curr_node = node
    end
  end
  c
end

def get_neighbor_2_swap(solution)
  n = solution.length
  poz1 = rand(n-1)
  poz2 = rand(n-1)
  cpy = solution.dup
  aux = cpy[poz1]
  cpy[poz1] = cpy[poz2]
  cpy[poz2] = aux
  cpy
end

def get_neighbor_2_opt(solution)
  n = solution.length
  poz1 = rand(n-1)
  poz2 = rand(n-1)
  if poz2 < poz1
    aux = poz1
    poz1 = poz2
    poz2 = aux
  end
  cpy = solution.dup
  while poz1 < poz2
    aux = cpy[poz1]
    cpy[poz1] = cpy[poz2]
    cpy[poz2] = aux
    poz1 += 1
    poz2 -= 1
  end
  cpy
end

def generate_mutated_children(p_m, children, swap_type, dist)
  mutated_children = []
  children.each do |c|
    r = rand()
    if r < p_m
      case swap_type
      when 'swap'
        mutated_children << Chromosome.new(get_neighbor_2_swap(c.solution.dup).dup, dist)
      when 'opt'
        mutated_children << Chromosome.new(get_neighbor_2_opt(c.solution.dup).dup, dist)
      end
    end
  end
  mutated_children
end

def select_survivors(parents, children, mutated_children, population_size)
  survivors = []
  parents.each { |p| survivors << p }
  children.each { |c| survivors << c }
  mutated_children.each { |m| survivors << m }
  survivors.sort_by! { |s| s.fitness }
  survivors.first(population_size)
end

def genetic_algorithm(population_size, p_r, p_c, p_m, max_generations, dist, n, crossover_type, swap_type)
  # crossover_type = 'spcx'
  # swap_type = 'swap'
  population = generate_population(n, population_size, dist)
  population.sort_by! { |s| s.fitness }
  curr_generation = 0
  bests = []
  bests << population.first.fitness
  while curr_generation < max_generations
    curr_generation += 1
    parents = generate_parents(dist, p_r, population)
    children = generate_children(dist, p_c, parents, crossover_type)
    mutated_children = generate_mutated_children(p_m, children, swap_type, dist)
    population = select_survivors(parents, children, mutated_children, population_size)
    bests << population.first.fitness
  end
  bests
end

def main
  n, objects = read_config_file('pr76')
  dist = get_all_distances(n, objects)
  p dist.length
  all_data = []
  all_data << genetic_algorithm(50, 0.1, 0.8, 0.1, 1000, dist, n, 'ncx', 'swap').to_s
  all_data << genetic_algorithm(50, 0.1, 0.8, 0.1, 1000, dist, n, 'ncx', 'opt').to_s
  write_data = all_data.join("\n")
  File.open("pr76_stats_mutation", "w") { |f| f.write write_data }
end

def get_excess(actual_value, best_value)
  1.0 * (actual_value - best_value) / best_value * 100
end

def is_valid(solution)
  check_sol = solution.dup.sort
  (1..51).each { |i| p 'aoleu' unless check_sol[i - 1] == i}
end

main