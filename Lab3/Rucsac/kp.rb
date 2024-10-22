require 'csv'

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
    objects[i-1]['value'] = parts[1].to_i
    objects[i-1]['weight'] = parts[2].to_i
  end
  max_sum = lines[n+1].strip.to_i
  [n, max_sum, objects]
end

# n - integer, total number of objects
# rand_arr - array, a possible solution
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# @return - boolean
def is_solution(n, rand_arr, objects, max_sum)
  sum = 0
  (0..n-1).each do |i|
    sum += objects[i]['weight']*rand_arr[i]
  end
  return true if sum <= max_sum
  false
end

# n - integer, total number of objects
# @return - array
def generate_random_array(n)
  rand_solution = []
  (0..n-1).each do |i|
    rand_solution[i] = rand(0..1)
  end
  rand_solution.dup
end

# n - integer, total number of objects
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# @return - array
def generate_random_solution(n, objects, max_sum)
  rand_arr = generate_random_array(n)
  while is_solution(n, rand_arr, objects, max_sum) == false
    rand_arr = generate_random_array(n)
  end
  rand_arr.dup
end

# n - integer, total number of objects
# objects - array of hashes, contains value and weight for each object
# solution - array, a solution
# @return - integer
def eval(n, solution, objects)
  sum = 0
  (0..n-1).each do |i|
    sum += objects[i]['value']*solution[i]
  end
  sum
end

def greedy(n, objects, max_sum)
  solution = []
  (0..n-1).each do |i|
    solution[i] = 1
  end
  obj = []
  objects.each{|e| obj << e.dup}
  obj_cpy = []
  obj.each { |e| obj_cpy << e.dup}
  obj_cpy.sort_by! { |e| e['value']}
  i = 0
  while is_solution(n, solution, objects, max_sum) == false
    a = obj.index { |e| e['value'] == obj_cpy[i]['value'] }
    solution[a] = 0
    i += 1
  end
  [eval(n, solution, objects), solution.dup]
end

def generate_population(num, n, objects, max_sum)
  population = []
  i = 0
  while i < num
    population << generate_random_solution(n, objects, max_sum)
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
    i_fit = eval(n, population[rand_pos_i], objects)
    j = 0
    while j < k
      rand_pos = rand(number_of_pop - 1)
      new_fit = eval(n, population[rand_pos], objects)
      if new_fit  > i_fit
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

def cross_parents(n, objects, max_sum, parents)
  children = []
  i = 0
  while i < parents.length
    p1 = parents[i]
    p2 = parents[i + 1]
    i += 2
    c = get_children(p1, p2, n, objects, max_sum)
    children << c[0]
    children << c[1]
  end
  c_cpy = []
  children.each { |e| c_cpy << e.dup}
  c_cpy
end

def fix_arr(n, rand_arr, objects, max_sum)
  i = -1
  until is_solution(n, rand_arr, objects, max_sum)
    while i < rand_arr.length
      i += 1
      if rand_arr[i] == 1
        rand_arr[i] = 0
        break
      end
    end
  end
  rand_arr.dup
end

def get_children(p1, p2, n, objects, max_sum)
  sol_length = p1.length
  cut_position = rand(1..sol_length - 2)
  i = 0
  c1 = []
  c2 = []
  while i < sol_length
    if i <= cut_position
      c1[i] = p1[i]
      c2[i] = p2[i]
    else
      c1[i] = p2[i]
      c2[i] = p1[i]
    end
    i += 1
  end
  c1 = fix_arr(n, c1, objects, max_sum)
  c2 = fix_arr(n, c2, objects, max_sum)
  [c1.dup, c2.dup]
end

def mutate_children(n, objects, max_sum, children)
  mutations = []
  children.each do |c|
    rand_flip = rand(n-1)
    c[rand_flip] = 1 - c[rand_flip]
    c = fix_arr(n, c, objects, max_sum)
    mutations << c.dup
  end
  m_cpy = []
  mutations.each { |e| m_cpy << e.dup}
  m_cpy
end

# miu + lambda
def select_survivors(num, parents, children, mutated_children, n, objects)
  potential_survivors = []
  survivors = []
  parents.each do |p|
    potential_survivors << p.dup
  end
  children.each do |c|
    potential_survivors << c.dup
  end
  mutated_children.each do |m|
    potential_survivors << m.dup
  end
  potential_survivors.sort_by!{ |e| -eval(n, e, objects) }
  (0..num-1).each do |i|
    survivors << potential_survivors[i].dup
  end
  survivors
end

def best_and_average(solutions, n, objects)
  best_fit = eval(n, solutions[0], objects)
  average_fit = 0
  solutions.each do |s|
    average_fit += eval(n, s, objects)
  end
  average_fit = average_fit*1.0/solutions.length
  [best_fit, average_fit]
end

def best_and_average_unordered(solutions, n, objects)
  best_fit = 0
  average_fit = 0
  solutions.each do |s|
    fit = eval(n, s, objects)
    best_fit = fit if best_fit < fit
    average_fit += fit
  end
  average_fit = average_fit*1.0/solutions.length
  [best_fit, average_fit]
end

def alg(n_param, m_param, objects, n, max_sum)
  best = []
  values = []
  t = 0
  population = generate_population(n_param, n, objects, max_sum)
  data = best_and_average_unordered(population, n, objects)
  best << data[0]
  values << data
  while t < m_param
    parents = generate_parents(n_param, 3, population, objects, n)
    children = cross_parents(n, objects, max_sum, parents)
    mutated_children = mutate_children(n, objects, max_sum, children)
    population = select_survivors(n_param, parents, children, mutated_children, n, objects)
    t += 1
    data = best_and_average(population, n, objects)
    best << data[0]
    values << data
  end
  [best.max, values]
end

def write_data(n_param, m_param, n, objects, max_sum, repeat: 10)
  i = 1
  all_fit = []
  all = []
  t0 = Time.now
  while i <= repeat
    values = alg(n_param, m_param, objects, n, max_sum)
    best_fit = values[0]
    all_fit.push(best_fit)
    j = 1
    plot_best = []
    plot_avg = []
    values[1].each do |v|
      plot_best << "(#{j}, #{v[0]})"
      plot_avg << "(#{j}, #{v[1]})"
      j += 1
    end
    all.push([plot_best.join(", ")])
    all.push([plot_avg.join(", ")])
    i += 1
  end
  t1 = Time.now - t0
  worst = all_fit.min
  best = all_fit.max
  avg = all_fit.sum(0.0)/all_fit.size
  all.push(['Worst', worst])
  all.push(['Best', best])
  all.push(['Average', avg])
  all.push(['Runtime', t1])
  File.write("kp_#{n}_population_#{n_param}_generations_#{m_param}.csv", all.map(&:to_csv).join)
end

def main(n_param, m_param)
  values = read_config_file('input_file_200.txt')
  n = values[0]
  max_sum = values[1]
  objects = values[2]
  write_data(n_param, m_param, n, objects, max_sum)
end

main(200, 400)