require 'csv'
require_relative 'read_config_file'
require_relative 'help'

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

def simulated_annealing(n, objects, t, min_t, k, alpha)
  curr_sol = greedy(n, objects)
  best_sol = curr_sol
  best_fit = fitness(n, objects, best_sol)
  while t > min_t
    p t
    p best_fit
    i = 0
    while i < k
      neighbor = get_neighbor_2_opt(n, curr_sol)
      neighbor_fit = fitness(n, objects, neighbor)
      if neighbor_fit < best_fit
        best_sol = neighbor.dup
        best_fit = neighbor_fit
      end
      delta = neighbor_fit - fitness(n, objects, curr_sol)
      if delta < 0
        curr_sol = neighbor.dup
      elsif rand < Math.exp(-delta/t)
        curr_sol = neighbor.dup
      end
      i += 1
    end
    t = t * alpha
  end
  [best_fit, best_sol.dup]
end

# n - integer, total number of objects
# k - integer, the number of randomly generated solutions
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# repeat - integer, number of final solutions
def write_data(n, objects, k, t, min_t, alpha, repeat: 10)
  i = 1
  all_sol = []
  all_fit = []
  t0 = Time.now
  while i <= repeat
    sol = simulated_annealing(n, objects, t, min_t, k, alpha)
    all_fit.push(sol[0])
    all_sol.push(sol)
    i += 1
  end
  t1 = Time.now - t0
  worst = all_fit.max
  best = all_fit.min
  avg = all_fit.sum(0.0)/all_fit.size
  all_sol.push(['Worst', worst])
  all_sol.push(['Best', best])
  all_sol.push(['Average', avg])
  all_sol.push(['Runtime', t1])
  File.write("sa_k_#{k}_T_#{t}_t_min_#{min_t}_alpha_#{alpha}_opt.csv", all_sol.map(&:to_csv).join)
end

def main(k, alpha, min_t, t)
  response = read_config_file('input.txt')
  n = response[0]
  objects = response[1]
  write_data(n, objects, k, t, min_t, alpha)
  # p fitness(n, objects, [1, 69, 27, 101, 53, 28, 26, 12, 80, 68, 29, 24, 54, 55, 25, 4, 39, 67, 23, 56, 75, 41, 22, 74, 72, 73, 21, 40, 58, 13, 94, 95, 97, 87, 2, 57, 15, 43, 42, 14, 44, 38, 86, 16, 61, 85, 91, 100, 98, 37, 92, 59, 93, 99, 96, 6, 89, 52, 18, 83, 60, 5, 84, 17, 45, 8, 46, 47, 36, 49, 64, 63, 90, 32, 10, 62, 11, 19, 48, 82, 7, 88, 31, 70, 30, 20, 66, 71, 65, 35, 34, 78, 81, 9, 51, 33, 79, 3, 77, 76, 50])
end

main(1000, 0.999, 0.1, 10)
