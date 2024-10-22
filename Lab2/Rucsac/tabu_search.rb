require 'csv'
require_relative 'generate_random_solution'
require_relative 'read_config_file'

def get_neighbors_non_tabu(n, objects, max_sum, tabu_list, sol)
  neighbors = []
  (1..n).each do |i|
    if tabu_list[i] == 0
      neighbor = []
      sol.each{|e| neighbor << e.dup}
      neighbor[i] = 1 - neighbor[i]
      neighbors.push(neighbor) if is_solution(n, neighbor, objects, max_sum)
    end
  end
  return_solution = []
  neighbors.each{|e| return_solution << e}
  return_solution
end

def get_best_neighbor_non_tabu(n, objects, max_sum, tabu_list, sol)
  neighbors = get_neighbors_non_tabu(n, objects, max_sum, tabu_list, sol)
  best_sol = []
  best_fit = -1
  best_poz = 1
  poz = 1
  neighbors.each do |curr_sol|
    curr_fit = eval(n, curr_sol, objects)
    if curr_fit > best_fit
      best_sol = []
      curr_sol.each { |e| best_sol << e.dup}
      best_fit = curr_fit
      best_poz = poz
    end
    poz += 1
  end
  return_solution = []
  best_sol.each{|e| return_solution << e.dup}
  [return_solution, best_fit, best_poz]
end

def update_memory(tabu_list, poz, n, memory)
  ret_list = []
  tabu_list.each { |e| ret_list << e }
  (1..n).each do |i|
    if i == poz
      ret_list[i] = memory
    elsif ret_list[i] != 0
      ret_list[i] += -1
    end
  end
  ret_list
end

def tabu_search(n, k, objects, max_sum, memory)
  best_sol = generate_random_solution(n, objects, max_sum)
  curr_sol = []
  best_sol.each{|e| curr_sol << e}
  best_fit = eval(n, best_sol, objects)
  tabu_list = []
  (1..n).each do |i|
    tabu_list[i] = 0
  end
  i = 0
  while i < k
    response = get_best_neighbor_non_tabu(n, objects, max_sum, tabu_list, curr_sol)
    tabu_list = update_memory(tabu_list, response[2], n, memory).dup
    curr_sol = response[0].dup
    if response[1] > best_fit
      best_sol = curr_sol.dup
      best_fit = response[1]
    end
    i += 1
  end
  [best_fit, best_sol]
end

# n - integer, total number of objects
# k - integer, the number of randomly generated solutions
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# repeat - integer, number of final solutions
def write_data(n, objects, k, max_sum, repeat: 10, memory: 3)
  i = 1
  all_sol = []
  all_fit = []
  t0 = Time.now
  while i <= repeat
    sol = tabu_search(n, k, objects, max_sum, memory)
    p sol
    all_fit.push(sol[0])
    all_sol.push(sol)
    i += 1
  end
  t1 = Time.now - t0
  worst = all_fit.min
  best = all_fit.max
  avg = all_fit.sum(0.0)/all_fit.size
  all_sol.push(['Worst', worst])
  all_sol.push(['Best', best])
  all_sol.push(['Average', avg])
  all_sol.push(['Runtime', t1])
  File.write("rand_kp_#{n}_k_#{k}_memory_#{memory}.csv", all_sol.map(&:to_csv).join)
end

# k - integer, the number of randomly generated solutions
def main(k)
  values = read_config_file('input_file_200.txt')
  n = values[0]
  max_sum = values[1]
  objects = values[2]
  write_data(n, objects, k, max_sum, memory: 7)
end

main(10000)
