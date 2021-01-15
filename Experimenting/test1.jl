function readNum()
  print("Enter a number: ")
  val = parse(Float64, readline())
  println("Your number is: $val")
  return nothing
end

readNum()