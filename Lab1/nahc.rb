# Next Ascent Hill Climbing
require 'csv'
require_relative 'generate_random_solution'
require_relative 'read_config_file'

# n - integer, total number of objects
# k - integer, the number of randomly generated solutions
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# @return - array
def generate_best_solution(n, objects, k, max_sum)
  i = 1
  best_solution = []
  best_solution_fitness = 0
  while i <= k
    c = generate_random_solution(n, objects, max_sum)
    c_fitness = eval(n, c, objects)
    new_try = c
    j = 1
    while j <= n
      if new_try[j] == 0
        new_try[j] = 1
        new_try_fitness = eval(n, new_try, objects)
        if is_solution(n, new_try, objects, max_sum) && c_fitness < new_try_fitness
          c = new_try
          c_fitness = new_try_fitness
        else
          new_try[j] = 0
        end
      end
      j += 1
    end
    if c_fitness > best_solution_fitness
      best_solution = c
      best_solution_fitness = c_fitness
    end
    i += 1
  end
  [best_solution_fitness, best_solution]
end

def write_data(n, objects, k, max_sum, repeat: 10)
  i = 1
  all_sol = []
  all_fit = []
  t0 = Time.now
  while i <= repeat
    sol = generate_best_solution(n, objects, k, max_sum)
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
  File.write("nahc_#{n}_solutions_k_#{k}.csv", all_sol.map(&:to_csv).join)
end

# k - integer, the number of randomly generated solutions
def main(k)
  values = read_config_file('input_file_200.txt')
  n = values[0]
  max_sum = values[1]
  objects = values[2]
  write_data(n, objects, k, max_sum)
end

main(100000)
