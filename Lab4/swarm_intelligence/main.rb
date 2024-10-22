class Particle
  attr_accessor :position, :fitness, :speed, :best

  def initialize(position, speed)
    @position = position
    @speed = speed
    @fitness = calculate_fitness(position)
    @best = position
  end

  # def calculate_fitness(position)
  #   n = position.length
  #   fit = 0
  #   (0..n - 1).each do |i|
  #     fit += position[i] ** 2
  #   end
  #   fit
  # end

  def update_fitness
    @fitness = calculate_fitness(position)
  end
end

def calculate_fitness(position)
  n = position.length
  fit = 0
  (0..n - 1).each do |i|
    fit += position[i] ** 2
  end
  fit
end

def generate_initial_speed(n)
  speed = []
  n.times do
    speed << rand(-1.0..1.0)
  end
  speed
end

def generate_random_position(n)
  x = []
  n.times do
    x << rand(-5.12..5.12)
  end
  x
end

def generate_population(population_size, n)
  population = []
  population_size.times do
    population << Particle.new(generate_random_position(n), generate_initial_speed(n))
  end
  population
end

def pso(population_size, n, generation_number, w, c1, c2, v_max)
  population = generate_population(population_size, n)
  generation = 0
  generation_number.times do
    generation += 1
    best_fit = population.first.fitness
    global_best = nil
    population.each do |particle|
      curr_fit = particle.fitness
      if curr_fit < best_fit
        best_fit = curr_fit
        global_best = particle.position
      end
    end
    p calculate_fitness(global_best)

    population.each do |particle|
      pos = []
      speed = []
      p_best = particle.best
      p_speed = particle.speed
      p_pos = particle.position
      (0..n - 1).each do |i|
        speed[i] = w * p_speed[i] + c1 * rand * (p_best[i] - p_pos[i]) + c2 * rand * (global_best[i] - p_pos[i])
        if speed[i] > v_max
          speed[i] = v_max
        elsif speed[i] < -v_max
          speed[i] = -v_max
        end
        pos[i] = p_pos[i] + speed[i]
        if pos[i] > 5.12
          pos[i] = 5.12
        elsif pos[i] < -5.12
          pos[i] = -5.12
        end
      end
      particle.speed = speed
      previous_fit_for_p_best = calculate_fitness(particle.best)
      particle.position = pos
      particle.update_fitness
      if previous_fit_for_p_best > particle.fitness
        particle.best = pos
      end
    end
  end
end

def main
  pso(50, 5, 100, 1, 2, 2, 6)
end

main
