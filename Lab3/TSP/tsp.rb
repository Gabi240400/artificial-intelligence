# file_path - string, file with input data
# @return - array
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

def distance(a, b)
  dif1 = (a['x'] - b['x']) * (a['x'] - b['x'])
  dif2 = (a['y'] - b['y']) * (a['y'] - b['y'])
  Math.sqrt(dif1 + dif2).round
end

def fitness(n, solution, dist)
  fit = 0
  (0..n-2).each do |i|
    fit += dist[solution[i] - 1][solution[i+1] - 1]
  end
  fit + dist[solution[n-1] - 1][solution[0] - 1]
end

def get_closest_city(poz, cities, dist)
  closest_city_distance = 999999
  closest_city_poz = -1
  cities.each do |city|
    curr_dist = dist[poz][city['poz'] - 1]
    if curr_dist < closest_city_distance
      closest_city_distance = curr_dist
      closest_city_poz = city['poz'] - 1
    end
  end
  closest_city_poz
end

def greedy(n, objects, dist)
  start_poz = rand(n-1)
  obj = []
  objects.each{|e| obj << e.dup}
  obj.delete_at(start_poz)
  solution = []
  curr_object_poz = objects[start_poz]['poz'] - 1
  solution << objects[start_poz]['poz']
  until obj.empty?
    closest_city_poz = get_closest_city(curr_object_poz, obj, dist)
    solution << closest_city_poz + 1
    obj.each do |city|
      if city['poz'] == closest_city_poz + 1
        obj.delete(city)
        break
      end
    end
    curr_object_poz = closest_city_poz
  end
  solution
end

def get_all_distances(n, objects)
  dist = []
  (0..n-1).each do |i|
    dist[i] = []
    (0..n-1).each do |j|
      if i == j
        dist[i][j] = 0
      else
        dist[i][j] = distance(objects[i], objects[j])
      end
    end
  end
  dist
end

def get_neighbor_2_swap(n, solution)
  poz1 = rand(n-1)
  poz2 = rand(n-1)
  cpy = solution.dup
  aux = cpy[poz1]
  cpy[poz1] = cpy[poz2]
  cpy[poz2] = aux
  cpy
end

def get_neighbor_2_opt(n, solution)
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

def generate_random_solution(n, objects)
  sol = []
  (1..n).each do |i|
    sol[i] = i
  end
  sol.shuffle
end

def generate_population(num, n, objects)
  population = []
  i = 0
  while i < num
    population << generate_random_solution(n, objects)
    i += 1
  end
  pop_cpy = []
  population.each { |e| pop_cpy << e.dup}
  pop_cpy
end

def generate_parents(num, k, population, objects, n)
  parents = []
  i = 0
  number_of_pop = population.length
  while i < num
    rand_pos_i = rand(number_of_pop - 1)
    chosen_parent = population[rand_pos_i]
    i_fit = fitness(n, population[rand_pos_i], objects)
    j = 0
    while j < k
      rand_pos = rand(number_of_pop - 1)
      new_fit = fitness(n, population[rand_pos], objects)
      if new_fit  < i_fit
        chosen_parent = population[rand_pos].dup
        i_fit = new_fit
      end
      j += 1
    end
    parents << chosen_parent
    i += 1
  end
  par_cpy = []
  parents.each { |e| par_cpy << e.dup}
  par_cpy
end

def cross_parents(n, parents)
  children = []
  i = 0
  while i < parents.length
    p1 = parents[i]
    p2 = parents[i + 1]
    i += 2
    c = get_children(p1, p2, n)
    children << c[0]
    children << c[1]
  end
  c_cpy = []
  children.each { |e| c_cpy << e.dup}
  c_cpy
end

def get_children(p1, p2)
  c1 = []
  c2 = []
  sol_length = p1.length
  cut1 = rand(1..sol_length - 2)
  cut2 = rand(1..sol_length - 2)
  while cut1 == cut2
    cut2 = rand(1..sol_length - 2)
  end
  if cut2 < cut1
    aux = cut1
    cut1 = cut2
    cut2 = aux
  end
  (cut2 + 1..sol_length-1).each do |i|
    c1 << p1[i]
    c2 << p2[i]
  end
  (0..cut1-1).each do |i|
    c1 << p1[i]
    c2 << p2[i]
  end
  (cut1..cut2).each do |i|
    c1 << p2[i] unless c1.include?(p2[i])
    c2 << p1[i] unless c2.include?(p1[i])
  end
end
