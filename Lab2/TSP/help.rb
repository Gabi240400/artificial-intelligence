def distance(a, b)
  dif1 = (a['x'] - b['x']) * (a['x'] - b['x'])
  dif2 = (a['y'] - b['y']) * (a['y'] - b['y'])
  Math.sqrt(dif1 + dif2).round
end

def fitness(n, objects, solution)
  fit = 0
  (0..n-2).each do |i|
    fit += distance(objects[solution[i] - 1], objects[solution[i+1] - 1])
  end
  fit + distance(objects[solution[n-1] - 1], objects[solution[0] - 1])
end

def get_closest_city(poz, cities, objects)
  closest_city_distance = 999999
  closest_city_poz = -1
  home = objects[poz]
  cities.each do |city|
    dist = distance(home, city)
    if dist < closest_city_distance
      closest_city_distance = dist
      closest_city_poz = city['poz'] - 1
    end
  end
  closest_city_poz
end

def greedy(n, objects)
  start_poz = rand(n-1)
  obj = []
  objects.each{|e| obj << e.dup}
  obj.delete_at(start_poz)
  solution = []
  curr_object_poz = objects[start_poz]['poz'] - 1
  solution << objects[start_poz]['poz']
  until obj.empty?
    closest_city_poz = get_closest_city(curr_object_poz, obj, objects)
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
