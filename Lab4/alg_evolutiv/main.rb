class Chromosome
  attr_reader :solution, :fitness

  def initialize(solution)
    @solution = solution
    @fitness = calculate_fitness
  end

  private

  def calculate_fitness
    n = solution.length
    fit = 0
    (0..n - 1).each do |i|
      fit += solution[i] ** 2
    end
    fit
  end
end

def generate_random_x(n)
  x = []
  (0..n - 1).each do |i|
    x << rand(-5.12..5.12)
  end
  x
end

def generate_random_population(population_size, n)
  population = []
  (1..population_size).each do
    population << Chromosome.new(generate_random_x(n))
  end
  population
end

def generate_parents(parents_size, population)
  parents = []
  pop_size = population.length
  (1..parents_size).each do
    best_fit = 9999999
    c = nil
    3.times do
      curr_c = population[rand(pop_size - 1)]
      curr_fit = curr_c.fitness
      if curr_fit < best_fit
        best_fit = curr_fit
        c = curr_c
      end
    end
    parents << c
  end
  parents
end

def crossover(parents, n)
  children = []
  i = 0
  (parents.length / 2).times do
    p1 = parents[i]
    p2 = parents[i + 1]
    c = get_child(p1.solution, p2.solution, n)
    children << Chromosome.new(c)
    i += 2
  end
  children
end

# incrucisare medie completa
def get_child(p1, p2, n)
  c = []
  (0..n - 1).each do |i|
    c << (p1[i] + p2[i]) / 2
  end
  c
end

def mutate_children(children, n)
  mutated_children = []
  children.each do |child|
    curr_sol = child.solution
    rand_pos = rand(n - 1)
    new_gene = rand(-5.12..5.12)
    mutation = []
    (0..n - 1).each do |i|
      if i == rand_pos
        mutation << new_gene
      else
        mutation << curr_sol[i]
      end
    end
    mutated_children << Chromosome.new(mutation)
  end
  mutated_children
end

def select_survivors(children, mutated_children, population_size)
  survivors = []
  children.each { |p| survivors << p}
  mutated_children.each { |p| survivors << p}
  survivors.sort_by! { |s| s.fitness }
  survivors.first(population_size)
end

def genetic_alg(n, population_size, parents_size, generation_number)
  population = generate_random_population(population_size, n)
  gen = 0
  all_best_fit = []
  all_best_fit << population.min_by { |p| p.fitness }.fitness
  generation_number.times do
    gen += 1
    parents = generate_parents(parents_size, population)
    children = crossover(parents, n)
    mutated_children = mutate_children(children, n)
    population = select_survivors(children, mutated_children, population_size)
    all_best_fit << population.first.fitness
  end
  all_best_fit
end

def main
  all_data = []
  only_best_fit = []
  10.times do
    t0 = Time.now
    best_fit = genetic_alg(50, 200, 400, 1000)
    all_data << best_fit.to_s
    only_best_fit << best_fit.last
    all_data << (Time.now - t0).to_s
  end
  all_data << "Best fit: #{only_best_fit.min}"
  all_data << "Worst fit: #{only_best_fit.max}"
  all_data << "Average fit: #{only_best_fit.sum/10}"
  write_data = all_data.join("\n")
  File.open("pop_200_gen_1000_n_50", "w") { |f| f.write write_data }
end

main
