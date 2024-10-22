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
    objects[i] = {}
    objects[i]['value'] = parts[1].to_i
    objects[i]['weight'] = parts[2].to_i
  end
  max_sum = lines[n+1].strip.to_i
  [n, max_sum, objects]
end
