function minMaxAvg()
  print("Enter size of data set (>1): ");
  count = parse(Int32, readline());
  println("Input numbers, one per line:");
  num = parse(Float64, readline());
  max = num;
  min = num;
  sum = num;
  for i = 1:count-1
    num = parse(Float64, readline());
    if (max < num)
      max = num;
    elseif (min > num)
      min = num;
    end
    sum += num;
  end
  avg = sum/count;
  println("Min: $min, Max: $max, Average: $avg");
end

minMaxAvg();