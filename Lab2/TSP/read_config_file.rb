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
