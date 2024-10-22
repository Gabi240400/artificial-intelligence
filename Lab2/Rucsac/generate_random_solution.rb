# n - integer, total number of objects
# rand_arr - array, a possible solution
# objects - array of hashes, contains value and weight for each object
# max_sum - integer, maximum weight that fits in the backpack
# @return - boolean
def is_solution(n, rand_arr, objects, max_sum)
  sum = 0
  (1..n).each do |i|
    sum += objects[i]['weight']*rand_arr[i]
  end
  return true if sum <= max_sum
  false
end

# n - integer, total number of objects
# @return - array
def generate_random_array(n)
  rand_solution = []
  (1..n).each do |i|
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
  (1..n).each do |i|
    sum += objects[i]['value']*solution[i]
  end
  sum
end

def greedy(n, objects, max_sum)
  solution = []
  (1..n).each do |i|
    solution[i] = 1
  end
  obj = []
  objects.each{|e| obj << e.dup}
  obj_cpy = []
  obj[0] = {'value' => 10000, 'weight' => 10000}
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
